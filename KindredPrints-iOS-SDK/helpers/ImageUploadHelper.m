//
//  ImageUploadHelper.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "ImageUploadHelper.h"
#import "UserPreferenceHelper.h"
#import "ServerInterface.h"
#import "OrderImage.h"
#import "OrderManager.h"
#import "KindredServerInterface.h"
#import "ImageManager.h"
#import "OrderManager.h"
#import "SelectedOrderImage.h"

@interface ImageUploadHelper() <ServerInterfaceDelegate, OrderManagerDelegate>

@property (strong, nonatomic) UserObject *currUser;

@property (nonatomic) dispatch_semaphore_t finished_sema;
@property (nonatomic) dispatch_semaphore_t processing_sema;
@property (nonatomic) dispatch_semaphore_t printables_sema;

@property (nonatomic) NSInteger currUploadCount;
@property (strong, nonatomic) NSMutableArray *finishedPile;
@property (strong, nonatomic) NSMutableArray *uploadQueue;
@property (strong, nonatomic) NSMutableArray *inprogressList;
@property (strong, nonatomic) NSMutableDictionary *processingBin;

@property (strong, nonatomic) NSMutableArray *pendingPrintables;
@property (strong, nonatomic) NSMutableDictionary *printableMap;

@property (strong, nonatomic) NSMutableDictionary *imageUploadMap;
@property (strong, nonatomic) NSMutableDictionary *imageDataUploadMap;

@property (strong, nonatomic) KindredServerInterface *kInterface;

@property (strong, nonatomic) OrderManager *orderManager;
@property (strong, nonatomic) ImageManager *imManager;

@property (nonatomic) NSInteger retries;
@property (nonatomic) NSInteger needUploadState;

@end

@implementation ImageUploadHelper

static NSInteger const MAX_RETRIES = 3;
static NSInteger const MAX_UPLOADS = 2;

static ImageUploadHelper *uHelper;

+ (ImageUploadHelper *) getInstance {
    if (!uHelper) {
        uHelper = [[ImageUploadHelper alloc] init];
        uHelper.finished_sema = dispatch_semaphore_create(1);
        uHelper.processing_sema = dispatch_semaphore_create(1);
        uHelper.printables_sema = dispatch_semaphore_create(1);
        uHelper.currUploadCount = 0;
    }
    return uHelper;
}

- (OrderManager *)orderManager {
    if (!_orderManager) {
        _orderManager = [OrderManager getInstance];
    }
    return _orderManager;
}

- (ImageManager *)imManager {
    if (!_imManager) _imManager = [ImageManager GetInstance];
    return _imManager;
}

- (NSMutableArray *)uploadQueue {
    if (!_uploadQueue) _uploadQueue = [[NSMutableArray alloc] init];
    return _uploadQueue;
}

- (NSMutableArray *)finishedPile {
    if (!_finishedPile) _finishedPile = [[NSMutableArray alloc] init];
    return _finishedPile;
}
- (NSMutableArray *)inprogressList {
    if (!_inprogressList) _inprogressList = [[NSMutableArray alloc] init];
    return _inprogressList;
}
- (NSMutableDictionary *)processingBin {
    if (!_processingBin) _processingBin = [[NSMutableDictionary alloc] init];
    return _processingBin;
}
- (NSMutableArray *)pendingPrintables {
    if (!_pendingPrintables) _pendingPrintables = [[NSMutableArray alloc] init];
    return _pendingPrintables;
}
- (NSMutableDictionary *)printableMap {
    if (!_printableMap) _printableMap = [[NSMutableDictionary alloc] init];
    return _printableMap;
}
- (NSMutableDictionary *)imageUploadMap {
    if (!_imageUploadMap) _imageUploadMap = [[NSMutableDictionary alloc] init];
    return _imageUploadMap;
}
- (NSMutableDictionary *)imageDataUploadMap {
    if (!_imageDataUploadMap) _imageDataUploadMap = [[NSMutableDictionary alloc] init];
    return _imageDataUploadMap;
}
- (KindredServerInterface *)kInterface {
    if (!_kInterface) {
        _kInterface = [[KindredServerInterface alloc] init];
        _kInterface.delegate = self;
    }
    return _kInterface;
}

- (void) imageReadyForUpload:(BaseImage *)image {
    self.currUser = [UserPreferenceHelper getUserObject];
    if (self.currUser.uId && ![self.currUser.uId isEqualToString:USER_VALUE_NONE]) {
        dispatch_queue_t loaderQ = dispatch_queue_create("kp_upload_queue", NULL);
        dispatch_async(loaderQ, ^{
            [self processImageForServerSync:image];
        });
    }
}
- (void) validateAllOrdersInit {
    self.retries = 0;
    self.currUser = [UserPreferenceHelper getUserObject];
    if (self.currUser.uId && ![self.currUser.uId isEqualToString:USER_VALUE_NONE]) {
        NSArray *selectedOrders = [self.orderManager getSelectedOrderImages];
        for (SelectedOrderImage *selectedImage in selectedOrders) {

            [self processImageForServerSync:selectedImage.oImage];
            if (!selectedImage.oImage.pServerInit) {
                [self addPrintableImageToList:selectedImage];
            } else {
                [self processPrintableImageForServerSync:selectedImage];
            }
        }
    }
}

- (NSString *)getPrintableKey:(SelectedOrderImage *)image {
    return [[image.oImage.pid stringByAppendingString:@"-"] stringByAppendingString:image.oProduct.sid];
}

- (void) processImageForServerSync:(BaseImage *)image {
    if (!image.pServerInit || !image.pUploadComplete) {
        if ([self addImageToQueue:image forKey:image.pid]) {
            if (self.currUploadCount <= MAX_UPLOADS) {
                self.currUploadCount++;
                [self processNextImage];
            }
        }
    } else {
        [self addToFinishedPile:image.pid];
        [self callDelegateAsAppropriate];
    }
}

- (void) processPrintableImageForServerSync:(SelectedOrderImage *)selectedImage {
    if (!selectedImage.oLineItemServerInit || !selectedImage.oServerInit) {
        if ([self addImageToQueue:selectedImage forKey:[self getPrintableKey:selectedImage]]) {
            if (self.currUploadCount < MAX_UPLOADS) {
                self.currUploadCount++;
                dispatch_queue_t loaderQ = dispatch_queue_create("kp_upload_queue", NULL);
                dispatch_async(loaderQ, ^{
                    [self processNextImage];
                });
            }
        }
    } else {
        [self addToFinishedPile:[self getPrintableKey:selectedImage]];
        [self callDelegateAsAppropriate];
    }
}

- (void) addPrintableImageToUploadQueueIfExists:(NSString *)localId andServerId:(NSString *)serverId {
    dispatch_semaphore_wait(self.printables_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self.pendingPrintables count]; i++) {
        NSString *pid = [self.pendingPrintables objectAtIndex:i];
        if ([pid isEqualToString:localId]) {
            NSMutableArray *selectedImages = [self.printableMap objectForKey:localId];
            for (SelectedOrderImage *selectedImage in selectedImages) {
                selectedImage.oImage.pServerId = serverId;
                selectedImage.oImage.pServerInit = YES;
                [self processPrintableImageForServerSync:selectedImage];
            }
            [self.printableMap removeObjectForKey:localId];
            [self.pendingPrintables removeObjectAtIndex:i];

            dispatch_semaphore_signal(self.printables_sema);
            return;
        }
    }
    dispatch_semaphore_signal(self.printables_sema);
}

- (void) addPrintableImageToList:(SelectedOrderImage *)selectedImage {
    dispatch_semaphore_wait(self.printables_sema, DISPATCH_TIME_FOREVER);
    for (NSString *pid in self.pendingPrintables) {
        if ([pid isEqualToString:selectedImage.oImage.pid]) {
            NSMutableArray *selectedImages = [self.printableMap objectForKey:selectedImage.oImage.pid];
            [selectedImages addObject:selectedImage];
            [self.printableMap setObject:selectedImages forKey:selectedImage.oImage.pid];
            dispatch_semaphore_signal(self.printables_sema);
            return;
        }
    }
    [self.pendingPrintables addObject:selectedImage.oImage.pid];
    NSMutableArray *listOfPrintables = [[NSMutableArray alloc] initWithArray:@[selectedImage]];
    [self.printableMap setObject:listOfPrintables forKey:selectedImage.oImage.pid];
    dispatch_semaphore_signal(self.printables_sema);
}

- (BOOL) addImageToQueue:(id)image forKey:(NSString *)key {
    dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);

    for (NSString *pid in self.uploadQueue)
        if ([pid isEqualToString:key]) {
            dispatch_semaphore_signal(self.processing_sema);
            return NO;
        }
    
    
    for (NSString *pid in self.inprogressList)
        if ([pid isEqualToString:key]) {
            dispatch_semaphore_signal(self.processing_sema);
            return NO;
        }
    
    
    [self.processingBin setObject:image forKey:key];
    [self.uploadQueue addObject:key];
    dispatch_semaphore_signal(self.processing_sema);
    return YES;
}

- (void) addToFinishedPile:(NSString *)imageId {
    dispatch_semaphore_wait(self.finished_sema, DISPATCH_TIME_FOREVER);
    for (NSString *pid in self.finishedPile) {
        if ([pid isEqualToString:imageId]) {
            dispatch_semaphore_signal(self.finished_sema);
            return;
        }
    }
    [self.finishedPile addObject:imageId];
    dispatch_semaphore_signal(self.finished_sema);
}

- (void) removeStringFromProcessing:(NSString *)imageId {
    dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self.inprogressList count]; i++)
        if ([[self.inprogressList objectAtIndex:i] isEqualToString:imageId]) {
            [self.inprogressList removeObjectAtIndex:i];
            break;
        }
    dispatch_semaphore_signal(self.processing_sema);
}

- (void) processNextImage {
    self.currUploadCount--;
    dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
    if ([self.uploadQueue count]) {
        self.currUploadCount++;

        NSString *pid = [self.uploadQueue firstObject];
        [self.uploadQueue removeObjectAtIndex:0];
        [self.inprogressList addObject:pid];
        id image = [self.processingBin objectForKey:pid];
        
        dispatch_semaphore_signal(self.processing_sema);

        dispatch_queue_t loaderQ = dispatch_queue_create("kp_upload_queue", NULL);
        dispatch_async(loaderQ, ^{
            if ([image isKindOfClass:[BaseImage class]]) {
                BaseImage *img = image;
                if (!img.pServerInit) {
                    if (!img.pIsTwoSided)
                        [self initImageOnServer:[self.processingBin objectForKey:pid]];
                    else
                        [self initFauxImageOnServer:img];
                } else
                    [self uploadImageFromMemory:image];
            } else {
                SelectedOrderImage *img = image;
                if (!img.oServerInit) {
                    if (!img.oImage.pIsTwoSided)
                        [self initPrintableImageOnServer:img];
                    else
                        [self initCustomPrintableImageOnServer:img];
                } else {
                    [self initOrUpdateLineItemObjectOnServer:img];
                }
            }
        });
        
    } else {
        dispatch_semaphore_signal(self.processing_sema);
    }
}

- (void) initPrintableImageOnServer:(SelectedOrderImage *)selectedImage {
    NSDictionary *postSource = [[NSDictionary alloc]
                                initWithObjects:@[selectedImage.oImage.pServerId]
                                forKeys:@[@"id"]];
    NSDictionary *postOps = [[NSDictionary alloc]
                             initWithObjects:@[postSource, [NSNumber numberWithFloat:[InterfacePreferenceHelper getBorderPercent:selectedImage.oProduct.sBorderPerc]]]
                             forKeys:@[@"source", @"border"]];
    
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:postOps forKey:@"operations"];
    [post setObject:self.currUser.uId forKey:@"user_id"];
    [post setObject:selectedImage.oProduct.sType forKey:@"type"];
    [self.kInterface createPrintableImage:post withIdent:[self getPrintableKey:selectedImage]];
}

- (void) initCustomPrintableImageOnServer:(SelectedOrderImage *)selectedImage {
    NSDictionary *postSource = [[NSDictionary alloc]
                                initWithObjects:@[selectedImage.oImage.pType, selectedImage.oImage.pPartnerData]
                                forKeys:@[@"type", @"data"]];
    NSDictionary *postOps = [[NSDictionary alloc]
                             initWithObjects:@[postSource]
                             forKeys:@[@"custom"]];
    
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:postOps forKey:@"operations"];
    [post setObject:self.currUser.uId forKey:@"user_id"];
    [post setObject:@"custom" forKey:@"type"];
    [self.kInterface createPrintableImage:post withIdent:[self getPrintableKey:selectedImage]];

}

- (void) initOrUpdateLineItemObjectOnServer:(SelectedOrderImage *)selectedImage {
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    if ([selectedImage.oLineItemServerId isEqualToString:SERVER_ID_NONE]) {
        [post setObject:self.currUser.uId forKey:@"user_id"];
        [post setObject:selectedImage.oServerId forKey:@"printableimage_id"];
        [post setObject:selectedImage.oProduct.sid forKey:@"price_id"];
        [post setObject:[NSNumber numberWithInteger:selectedImage.oProduct.sQuantity] forKey:@"quantity"];
        [self.kInterface createLineItem:post withIdent:[self getPrintableKey:selectedImage]];
    } else {
        [post setObject:selectedImage.oLineItemServerId forKey:@"id"];
        [post setObject:[NSNumber numberWithInteger:selectedImage.oProduct.sQuantity] forKey:@"quantity"];
        [self.kInterface updateLineItem:post lineItemId:selectedImage.oLineItemServerId withIdent:[self getPrintableKey:selectedImage]];
    }
}

- (void) initFauxImageOnServer:(BaseImage *)image {
    [self.orderManager imageWasServerInit:image.pid withServerId:image.pid];
    [self.orderManager imageFinishedUploading:image.pid];
    [self addPrintableImageToUploadQueueIfExists:image.pid andServerId:image.pid];
    [self.finishedPile addObject:image.pid];
    [self.processingBin removeObjectForKey:image.pid];
    [self removeStringFromProcessing:image.pid];
    [self processNextImage];
}

- (void) initImageOnServer:(BaseImage *)image {
    NSData *currImage = [self.imManager getFullImage:image];
    UIImage *imgVersion = [[UIImage alloc] initWithData:currImage];
    if (currImage) {
        NSDictionary *metadata = [[NSDictionary alloc]
                                  initWithObjects:@[
                                                    [NSNumber numberWithInt:imgVersion.size.width],
                                                    [NSNumber numberWithInt:imgVersion.size.height],
                                                    [NSNumber numberWithInt:imgVersion.imageOrientation],
                                                    ]
                                  forKeys:@[@"width",
                                            @"height",
                                            @"orient"
                                            ]];

        if ([image.pUrl isEqualToString:LOCAL_IMAGE_URL]) {
            [self.imageDataUploadMap setObject:currImage forKey:image.pid];
            NSDictionary *post = [[NSDictionary alloc]
                                  initWithObjects:@[
                                                    self.currUser.uId,
                                                    @"phone",
                                                    [NSNumber numberWithInteger:[currImage length]],
                                                    metadata]
                                  forKeys:@[
                                            @"user_id",
                                            @"source",
                                            @"file_size",
                                            @"source_metadata"]];
            
            [self.kInterface createImage:post withIdent:image.pid];
        } else {
            NSDictionary *post = [[NSDictionary alloc]
                                  initWithObjects:@[
                                                    self.currUser.uId,
                                                    @"remote",
                                                    image.pUrl,
                                                    metadata]
                                  forKeys:@[
                                            @"user_id",
                                            @"source",
                                            @"remote_url",
                                            @"source_metadata"]];
            [self.kInterface createURLImage:post withIdent:image.pid];
        }
    }
}

- (void) uploadImageFromMemory:(BaseImage *)image {
    NSDictionary *savedUploadParams = [self.imageUploadMap objectForKey:image.pid];
    NSData *imgData = [self.imageDataUploadMap objectForKey:image.pid];
    if (savedUploadParams && imgData) {
        [self.kInterface uploadImage:savedUploadParams image:imgData imageId:image.pid];
    } else {
        imgData = [self.imManager getFullImage:image];
        [self.imageDataUploadMap setObject:imgData forKey:image.pid];
        NSDictionary *post = [[NSDictionary alloc]
                              initWithObjects:@[
                                                [NSNumber numberWithInteger:[imgData length]],
                                                image.pServerId]
                              forKeys:@[@"file_size",
                                        @"id"]];
        [self.kInterface checkStatusOfImage:post image:image.pServerId origId:image.pid];
    }
}

- (void) callDelegateAsAppropriate {
    if (self.delegate && self.retries < MAX_RETRIES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat totalImages = [self.finishedPile count] + [self.uploadQueue count] + [self.inprogressList count];//self.totalUploadsNeeded;
            CGFloat totalFinished = [self.finishedPile count];
            [self.delegate uploadFinishedWithOverallProgress:totalFinished/totalImages processedCount:(NSInteger)totalFinished andTotal:(NSInteger)totalImages];
            if (totalFinished == totalImages) {
                [self.delegate uploadsHaveCompleted];
            }
        });
    }
}

- (void) tellDelegateUploadHasFailed {
    if (self.delegate) {
        dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
        [self.uploadQueue removeAllObjects];
        dispatch_semaphore_signal(self.processing_sema);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate uploadsHaveFailed];
        });
    }
}

- (void) clearAllQueue {
    [self.uploadQueue removeAllObjects];
    [self.inprogressList removeAllObjects];
    [self.finishedPile removeAllObjects];
    [self.processingBin removeAllObjects];
}
#pragma mark Server Interface

- (void)serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];
        NSString *identTag = [returnedData objectForKey:kpServerIdentTag];

        if ([requestTag isEqualToString:REQ_TAG_CREATE_URL_IMAGE]) {
            if (status == 200) {
                NSString *pId = [returnedData objectForKey:@"id"];
                [self.orderManager imageWasServerInit:identTag withServerId:pId];
                [self.orderManager imageFinishedUploading:identTag];
                [self addPrintableImageToUploadQueueIfExists:identTag andServerId:pId];
                [self.finishedPile addObject:identTag];
                [self.processingBin removeObjectForKey:identTag];
            } else if (status < 0) {
                self.retries++;
                if (self.retries < MAX_RETRIES) {
                    [self.uploadQueue addObject:identTag];
                } else {
                    [self tellDelegateUploadHasFailed];
                }
            } else {
                [self.uploadQueue addObject:identTag];
            }
            [self removeStringFromProcessing:identTag];
            [self processNextImage];
        } else if ([requestTag isEqualToString:REQ_TAG_CREATE_IMAGE] || [requestTag isEqualToString:REQ_TAG_GET_IMAGE_STATUS]) {
            if (status == 200) {
                NSString *pId = [returnedData objectForKey:@"id"];
                [self.orderManager imageWasServerInit:identTag withServerId:pId];
                [self addPrintableImageToUploadQueueIfExists:identTag andServerId:pId];
                
                [self.imageUploadMap setObject:[returnedData objectForKey:@"upload"] forKey:identTag];
             
                [self.uploadQueue addObject:identTag];
            } else if (status < 0) {
                self.retries++;
                if (self.retries < MAX_RETRIES) {
                    [self.uploadQueue addObject:identTag];
                } else {
                    [self tellDelegateUploadHasFailed];
                }
            }
            [self removeStringFromProcessing:identTag];
            [self processNextImage];
        } else if ([requestTag isEqualToString:REQ_TAG_UPLOAD_IMAGE]) {
            if (status == 200) {
                [self.orderManager imageFinishedUploading:identTag];
                [self.finishedPile addObject:identTag];
                [self.processingBin removeObjectForKey:identTag];
            } else if (status < 0) {
                self.retries++;
                if (self.retries < MAX_RETRIES) {
                    [self.uploadQueue addObject:identTag];
                } else {
                    [self tellDelegateUploadHasFailed];
                }
            } else {
                [self.uploadQueue addObject:identTag];
            }
            [self.imageUploadMap removeObjectForKey:identTag];
            [self.imageDataUploadMap removeObjectForKey:identTag];
            [self removeStringFromProcessing:identTag];
            [self processNextImage];
        } else if ([requestTag isEqualToString:REQ_TAG_CREATE_PRINTABLE_IMAGE]) {
            if (status == 200) {
                NSString *pId = [returnedData objectForKey:@"id"];
                [self.orderManager selectedImageWasServerInit:identTag withServerId:pId];
                SelectedOrderImage *selectedImage = [self.processingBin objectForKey:identTag];
                selectedImage.oServerId = pId;
                selectedImage.oServerInit = YES;
                if (!selectedImage.oLineItemServerInit) {
                    [self.uploadQueue addObject:identTag];
                }
                [self.processingBin setObject:selectedImage forKey:identTag];
            } else {
                self.retries++;
                if (self.retries < MAX_RETRIES) {
                    [self.uploadQueue addObject:identTag];
                } else {
                    [self tellDelegateUploadHasFailed];
                }
            }
            
            [self removeStringFromProcessing:identTag];
            [self processNextImage];
        } else if ([requestTag isEqualToString:REQ_TAG_CREATE_LINE_ITEM] || [requestTag isEqualToString:REQ_TAG_UPDATE_LINE_ITEM]) {
            if (status == 200) {
                NSString *pId = [returnedData objectForKey:@"id"];
                [self.orderManager selectedImageWasServerLineItemInit:identTag withServerId:pId];
                [self.finishedPile addObject:identTag];
                [self.processingBin removeObjectForKey:identTag];
            } else {
                self.retries++;
                if (self.retries < MAX_RETRIES) {
                    [self.uploadQueue addObject:identTag];
                } else {
                    [self tellDelegateUploadHasFailed];
                }
            }
            [self removeStringFromProcessing:identTag];
            [self processNextImage];
        }
        [self callDelegateAsAppropriate];
    }
}

@end
