//
//  ImageManager.m
//  KindredPrints
//
//  Created by Alex Austin on 12/28/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//

#import "ImageManager.h"
#import "KPMEMImage.h"
#import "KPURLImage.h"
#import "FileCache.h"
#import "ImageCache.h"
#import "ImageEditor.h"
#import "UserPreferenceHelper.h"
#import "OrderManager.h"
#import "ImageUploadHelper.h"

@interface ImageManager()

@property (strong, nonatomic) FileCache *fCache;
@property (strong, nonatomic) ImageCache *imCache;

@property (nonatomic) dispatch_semaphore_t processing_sema;
@property (nonatomic) dispatch_semaphore_t waitingview_sema;

@property (nonatomic) NSInteger currOrigDownloads;
@property (strong, nonatomic) NSMutableArray *waitingToDownloadQueue;
@property (strong, nonatomic) NSMutableArray *downloadingQueue;
@property (strong, nonatomic) NSMutableDictionary *imageDetails;
@property (strong, nonatomic) NSMutableDictionary *imageSizes;
@property (strong, nonatomic) NSMutableDictionary *waitingViews;

@end

@implementation ImageManager

static CGFloat COMPRESSION = 0.9f;
static CGFloat MAX_COMPRESSION = 0.1f;
static int MAX_FILE_SIZE = 800*1024;

// STATIC METHODS
static ImageManager *manager;
+ (ImageManager *) GetInstance {
    if (!manager) {
        manager = [[ImageManager alloc] init];
        manager.processing_sema = dispatch_semaphore_create(1);
        manager.waitingview_sema = dispatch_semaphore_create(1);
    }
    return manager;
}

static NSInteger MAX_DOWNLOADS = 3;

static NSString *THUMB_PREFIX = @"thumb_";
static NSString *FULL_PREFIX = @"full_";
static NSString *ORIG_PREFIX = @"orig_";

static const char *PROCESS_QUEUE = "process_queue";
static const char *DOWNLOAD_QUEUE = "downloading_queue";

+ (NSString *)GetFullName:(NSString *)ident {
    return [FULL_PREFIX stringByAppendingString:ident];
}
+ (NSString *)GetThumbName:(NSString *)ident {
    return [THUMB_PREFIX stringByAppendingString:ident];
}
+ (NSString *)GetOrigName:(NSString *)ident {
    return [ORIG_PREFIX stringByAppendingString:ident];
}

// LAZY INSTANIATORS

- (FileCache *)fCache {
    if (!_fCache) _fCache = [FileCache getInstance];
    return _fCache;
}
- (ImageCache *)imCache {
    if (!_imCache) _imCache = [ImageCache getInstance];
    return _imCache;
}
- (NSMutableArray *)waitingToDownloadQueue {
    if (!_waitingToDownloadQueue) _waitingToDownloadQueue = [[NSMutableArray alloc] init];
    return _waitingToDownloadQueue;
}
- (NSMutableArray *)downloadingQueue {
    if (!_downloadingQueue) _downloadingQueue = [[NSMutableArray alloc] init];
    return _downloadingQueue;
}
- (NSMutableDictionary *)imageSizes {
    if (!_imageSizes) _imageSizes = [[NSMutableDictionary alloc] init];
    return _imageSizes;
}
- (NSMutableDictionary *)waitingViews {
    if (!_waitingViews) _waitingViews = [[NSMutableDictionary alloc] init];
    return _waitingViews;
}

- (NSMutableDictionary *)imageDetails {
    if (!_imageDetails) _imageDetails = [[NSMutableDictionary alloc] init];
    return _imageDetails;
}

// FUNCTIONAL INSTANCE METHODS

// public image prefetcher
- (void) startPrefetchingOrigImageToCache:(BaseImage *)image {
    dispatch_queue_t loaderQ = dispatch_queue_create(DOWNLOAD_QUEUE, NULL);
    dispatch_async(loaderQ, ^{
        NSString *origId = [ImageManager GetOrigName:image.pid];
    
        if (![self isOrigImageInProcess:origId] && ![self.fCache hasImageForKey:origId]) {
            // not currently downloading and does not exist in fsystem
        
            [self.imageDetails setObject:image forKey:origId];
            if (self.currOrigDownloads < MAX_DOWNLOADS) {
                self.currOrigDownloads++;
                [self.waitingToDownloadQueue addObject:origId];
                [self startNextOrigDownload];
            } else {
                [self.waitingToDownloadQueue addObject:origId];
            }
        }
    });
}

- (void) cacheOrigImageFromMemory:(BaseImage *)image withImage:(UIImage *)imgData {
    dispatch_queue_t loaderQ = dispatch_queue_create(PROCESS_QUEUE, NULL);
    dispatch_async(loaderQ, ^{
        [self processImageForStorage:image withTag:nil forSize:nil withImage:imgData];
    });
}

// called when a download finishes, to grab the next in the queue
- (void) startNextOrigDownload {
    self.currOrigDownloads--;
    if ([self.waitingToDownloadQueue count] > 0) {
        self.currOrigDownloads++;
        dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);

        NSString *ident = [self.waitingToDownloadQueue lastObject];
        [self.waitingToDownloadQueue removeObjectAtIndex:[self.waitingToDownloadQueue count]-1];
        [self.downloadingQueue addObject:ident];
        
        BaseImage *imageData = [self.imageDetails objectForKey:ident];
        PrintableSize *imageSize = [self.imageSizes objectForKey:ident];
        [self.imageDetails removeObjectForKey:ident];
        [self.imageSizes removeObjectForKey:ident];
        
        dispatch_semaphore_signal(self.processing_sema);
        
        NSString *url = @"";
        if (!imageData.pThumbLocalCached && ![imageData.pUrl isEqualToString:imageData.pThumbUrl])
            url = imageData.pThumbUrl;
        else {
            imageData.pThumbLocalCached = YES;
            url = imageData.pUrl;
        }
        
        [self prefetchAndPrepDisplayImages:url withCallback:^(UIImage *image) {
            if (image) {
                [self processImageForStorage:imageData withTag:url forSize:imageSize withImage:image];
            } else {
                [[OrderManager getInstance] deleteOrderImageForId:imageData.pid];
                dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
                [self.downloadingQueue removeObject:ident];
                dispatch_semaphore_signal(self.processing_sema);
            }
            [self startNextOrigDownload];
        }];
    }
}

// download and predicate declaration
- (void) prefetchAndPrepDisplayImages:(NSString *)url withCallback:(asyncWithImage)predicate {
    [self getImageFromUrl:url predicate:predicate];
}

// add images to their respective caches
- (void) processImageForStorage:(BaseImage *)imageData withTag:(NSString *)tag forSize:(PrintableSize *)size withImage:(UIImage *)image {
    NSMutableArray *sizesToCrop = [[NSMutableArray alloc] init];
    CGFloat imageAspectRatio = image.size.width/image.size.height;
    if (!size) {
        if (imageData.pIsTwoSided)
            [sizesToCrop addObjectsFromArray:[ImageEditor getAllowablePrintableSizesForImageSize:CGSizeMake(image.size.width, image.size.height) andFilter:FILTER_DOUBLESIDE]];
        else
            [sizesToCrop addObjectsFromArray:[ImageEditor getAllowablePrintableSizesForImageSize:CGSizeMake(image.size.width, image.size.height) andFilter:FILTER_NONE]];
        size = [[PrintableSize alloc] init];
        CGFloat scaleFactor = 1;
        if (image.size.width <= image.size.height)
            scaleFactor = [InterfacePreferenceHelper getPicturePreviewSize] /image.size.height;
        else
            scaleFactor = [InterfacePreferenceHelper getPicturePreviewSize] /image.size.width;
        CGFloat width = image.size.width*scaleFactor;
        CGFloat height = image.size.height*scaleFactor;
        size.sPreviewSize = CGSizeMake(width, height);
    }
    else [sizesToCrop addObject:size];
    
    if ([sizesToCrop count] > 0) {
        PrintableSize *maxSize = [sizesToCrop objectAtIndex:0];
        for (PrintableSize *pSize in sizesToCrop) {
            if (pSize.sTrimmedSize.height > maxSize.sTrimmedSize.height || pSize.sTrimmedSize.width > maxSize.sTrimmedSize.width)
                maxSize = pSize;
        }

        for (PrintableSize *pSize in sizesToCrop) {
            CGSize cropSize = CGSizeMake(pSize.sThumbSize.width*pSize.sTrimmedSize.width/maxSize.sTrimmedSize.width, pSize.sThumbSize.height*pSize.sTrimmedSize.height/maxSize.sTrimmedSize.height);
            if (imageAspectRatio < 1) {
                cropSize = CGSizeMake(cropSize.height, cropSize.width);
            }
            UIImage *thumb = [ImageEditor
                                formatImage:image
                                offset:imageData.pCropOffset
                                scaledSize:cropSize
                                borderSize:[InterfacePreferenceHelper
                                            getBorderWidth:pSize.sBorderPerc
                                            onSize:cropSize]
                                borderColor:[InterfacePreferenceHelper getBorderColor]];
            pSize.sThumbSize = cropSize;
            NSString *thumbFname = [[pSize.sid stringByAppendingString:@"_"] stringByAppendingString:[ImageManager GetThumbName:imageData.pid]];
        
            [self.fCache addImage:thumb forKey:thumbFname];
            [self.imCache addImage:thumb forKey:thumbFname];
            
            cropSize = CGSizeMake(pSize.sPreviewSize.width*pSize.sTrimmedSize.width/maxSize.sTrimmedSize.width, pSize.sPreviewSize.height*pSize.sTrimmedSize.height/maxSize.sTrimmedSize.height);
            if (imageAspectRatio < 1) {
                cropSize = CGSizeMake(cropSize.height, cropSize.width);
            }
            pSize.sPreviewSize = cropSize;
            UIImage *preview = [ImageEditor
                                formatImage:image
                                offset:imageData.pCropOffset
                                scaledSize:cropSize
                                borderSize:[InterfacePreferenceHelper
                                            getBorderWidth:pSize.sBorderPerc
                                            onSize:cropSize]
                                borderColor:[InterfacePreferenceHelper getBorderColor]];
            NSString *previewFname = [[pSize.sid stringByAppendingString:@"_"] stringByAppendingString:[ImageManager GetFullName:imageData.pid]];
            
            if (!tag || [tag isEqualToString:imageData.pUrl]) {
                if (image.size.width > image.size.height)
                    pSize.sDPI = image.size.width/pSize.sTrimmedSize.width;
                else
                    pSize.sDPI = image.size.height/pSize.sTrimmedSize.height;
            }
            
            [self.fCache addImage:preview forKey:previewFname];
            [self.imCache addImage:preview forKey:previewFname];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self assignAnyWaitingViewsForId:thumbFname];
                [self assignAnyWaitingViewsForId:previewFname];
            });
        }
    }
    
    UIImage *preview = [ImageEditor resizeImage:image scaledSize:size.sPreviewSize];
    
    NSString *origFname = [ImageManager GetOrigName:imageData.pid];
    NSString *fullFname = [ImageManager GetFullName:imageData.pid];
    [self.fCache addImage:image forKey:origFname];
    [self.fCache addImage:preview forKey:fullFname];
    [self.imCache addImage:preview forKey:fullFname];
    
    imageData.pWidth = image.size.width;
    imageData.pHeight = image.size.height;
    if (tag) {
        if ([tag isEqualToString:imageData.pThumbUrl] && !imageData.pThumbLocalCached) {
            imageData.pThumbLocalCached = YES;
        } else {
            imageData.pLocalCached = YES;
        }
    } else {
        imageData.pThumbLocalCached = YES;
        imageData.pLocalCached = YES;
    }
    [[OrderManager getInstance] imageWasUpdatedWithSizes:imageData andSizes:sizesToCrop];
    [[ImageUploadHelper getInstance] imageReadyForUpload:imageData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self assignAnyWaitingViewsForId:fullFname];
    });

    dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
    [self.downloadingQueue removeObject:origFname];
    dispatch_semaphore_signal(self.processing_sema);
    if (!imageData.pLocalCached && ![self isOrigImageInProcess:[ImageManager GetOrigName:imageData.pid]]) {
        [self startPrefetchingOrigImageToCache:imageData];
    }
}


// returns yes if the image download is in process or if the file cache contains the full image
- (BOOL) isOrigImageInProcess:(NSString *)uniqueId {
    dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
    if ([self.waitingToDownloadQueue containsObject:uniqueId] || [self.downloadingQueue containsObject:uniqueId]) {
        dispatch_semaphore_signal(self.processing_sema);
        return YES;
    }
    dispatch_semaphore_signal(self.processing_sema);
    return NO;
}

// scan through the waiting views, looking if there are any that need images
- (void) assignAnyWaitingViewsForId:(NSString *)name {
    dispatch_semaphore_wait(self.waitingview_sema, DISPATCH_TIME_FOREVER);
    UIImageView *view = [self.waitingViews objectForKey:name];
    if (view) {
        [view setImage:[self.imCache getImageForKey:name]];
        if (self.delegate) [self.delegate imageInserted];
        [self.waitingViews removeObjectForKey:name];
    }
    dispatch_semaphore_signal(self.waitingview_sema);
}
// sets the image to the view async
- (void) setImageAsync:(UIImageView *)view withImage:(BaseImage *)image displaySize:(PictureSize)displaySize atSize:(PrintableSize *)size {
    NSString *fname = nil;
    if (displaySize == ThumbnailPictureType && size) {
        fname = [[size.sid stringByAppendingString:@"_"] stringByAppendingString:[ImageManager GetThumbName:image.pid]];
    } else if (size) {
        fname = [[size.sid stringByAppendingString:@"_"] stringByAppendingString:[ImageManager GetFullName:image.pid]];
    } else
        fname = [ImageManager GetFullName:image.pid];

    if ([self.imCache hasImage:fname]) {
        UIImage *image = [self.imCache getImageForKey:fname];
        [view setImage:image];
        if (self.delegate) [self.delegate imageInserted];
    } else {
        dispatch_queue_t loaderQ = dispatch_queue_create(DOWNLOAD_QUEUE, NULL);
        dispatch_async(loaderQ, ^{
            if ([self.fCache hasImageForKey:fname]) {
                UIImage *im = [self.fCache getImageForKey:fname];
                [self.imCache addImage:im forKey:fname];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view setImage:im];
                    if (self.delegate) [self.delegate imageInserted];
                    [self assignAnyWaitingViewsForId:fname];
                });
            } else {
                dispatch_semaphore_wait(self.waitingview_sema, DISPATCH_TIME_FOREVER);
                [self.waitingViews setObject:view forKey:fname];
                dispatch_semaphore_signal(self.waitingview_sema);
                if (![self isOrigImageInProcess:[ImageManager GetOrigName:image.pid]]) {
                    [self startPrefetchingOrigImageToCache:image];
                }
            }
        });
    }
}

- (void) setImageAsync:(UIImageView *)view andProgressView:(UIActivityIndicatorView *)progView withImage:(KPImage *)image andIndex:(NSInteger)index {
    NSString *cacheName = [NSString stringWithFormat:@"%d", index];
    if ([self.imCache hasImage:cacheName]) {
        UIImage *image = [self.imCache getImageForKey:cacheName];
        [view setImage:image];
    } else {
        if ([image isKindOfClass:[KPMEMImage class]]) {
            KPMEMImage *img = (KPMEMImage *)image;
            UIImage *croppedImg = [ImageEditor cropAndRotateForThumbnail:img.image scaledSize:CGSizeMake(view.frame.size.width, view.frame.size.height)];
            [self.imCache addImage:croppedImg forKey:cacheName];
            [view setImage:croppedImg];
        } else if ([image isKindOfClass:[KPURLImage class]]) {
            KPURLImage *img = (KPURLImage *)image;
            NSLog(@"pulling image from web at index %d", index);
            [progView startAnimating];

            dispatch_queue_t loaderQ = dispatch_queue_create(DOWNLOAD_QUEUE, NULL);
            dispatch_async(loaderQ, ^{
                [self getImageFromUrl:img.previewUrl predicate:^(UIImage *image) {
                    UIImage *img = [ImageEditor cropAndRotateForThumbnail:image scaledSize:CGSizeMake(view.frame.size.width, view.frame.size.height)];
                    [self.imCache addImage:img forKey:cacheName];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [view setImage:img];
                        [progView stopAnimating];
                    });
                }];
            });
        }
    }
}

// gets an image from the web
- (void) getImageFromUrl:(NSString *)url predicate:(asyncWithImage)predicate {
    NSURL *imageUrl = [NSURL URLWithString:url];
    NSData *imgData = [NSData dataWithContentsOfURL:imageUrl];
    if (imgData) {
        UIImage *img = [UIImage imageWithData:imgData];
        predicate(img);
    } else {
        predicate(nil);
    }
}

// grab the full size UIImage from memory for uploading and such
- (NSData *)getFullImage:(BaseImage *)image {
    NSString *fname = [ImageManager GetOrigName:image.pid];
    UIImage *img = [self.fCache getImageForKey:fname];
    NSData *imageData = nil;
    if (img) {
        CGFloat compression = COMPRESSION;
        
        imageData = UIImageJPEGRepresentation(img, compression);
        
        while ([imageData length] > MAX_FILE_SIZE && compression > MAX_COMPRESSION)
        {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(img, compression);
        }
    }
    return imageData;
}


@end
