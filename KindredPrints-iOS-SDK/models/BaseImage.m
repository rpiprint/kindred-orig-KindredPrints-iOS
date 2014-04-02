//
//  BaseImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "BaseImage.h"

@implementation BaseImage


- (BaseImage *)initWithUrl:(NSString *)url andThumbUrl:(NSString *)thumbUrl {
    NSString *UUID = [[NSUUID UUID] UUIDString];
    self.pid = UUID;
    self.pServerId = SERVER_ID_NONE;
    self.pThumbUrl = thumbUrl;
    self.pUrl = url;
    self.pServerInit = NO;
    self.pUploadComplete = NO;
    self.pWidth = 0;
    self.pHeight = 0;
    self.pCropOffset = -1;
    self.pLocalCached = NO;
    self.pThumbLocalCached = NO;
    
    return self;
}

- (BaseImage *)initWithImage {
    NSString *UUID = [[NSUUID UUID] UUIDString];
    self.pid = UUID;
    self.pServerId = SERVER_ID_NONE;
    self.pThumbUrl = LOCAL_IMAGE_URL;
    self.pUrl = LOCAL_IMAGE_URL;
    self.pServerInit = NO;
    self.pUploadComplete = NO;
    self.pWidth = 0;
    self.pHeight = 0;
    self.pCropOffset = -1;
    self.pLocalCached = NO;
    self.pThumbLocalCached = NO;
    
    return self;
}

- (BaseImage *)copy {
    BaseImage *newCopy = [[BaseImage alloc] initWithPackedImage:[self packImage]];
    return newCopy;
}

- (BaseImage *) initWithPackedImage:(NSDictionary *)savedObject {
    self.pid = [savedObject objectForKey:PICTURE_ID];
    self.pServerId = [savedObject objectForKey:PICTURE_SERVER_ID];
    self.pThumbUrl = [savedObject objectForKey:PICTURE_THUMB_URL];
    self.pUrl = [savedObject objectForKey:PICTURE_URL];
    self.pCropOffset = [[savedObject objectForKey:PICTURE_CROP_OFFSET] floatValue];
    self.pHeight = [[savedObject objectForKey:PICTURE_HEIGHT] floatValue];
    self.pWidth = [[savedObject objectForKey:PICTURE_WIDTH] floatValue];
    self.pServerInit = [[savedObject objectForKey:PICTURE_SERVER_INIT] boolValue];
    self.pUploadComplete = [[savedObject objectForKey:PICTURE_UPLOAD_INIT] boolValue];
    self.pLocalCached = [[savedObject objectForKey:PICTURE_LOCAL_CACHED] boolValue];
    self.pThumbLocalCached = [[savedObject objectForKey:PICTURE_THUMB_LOCAL_CACHED] boolValue];
    return self;
}
- (NSDictionary *) packImage {
    NSDictionary *packedImage = [[NSDictionary alloc] initWithObjects:@[self.pid,
                                                                        self.pServerId,
                                                                        self.pUrl,
                                                                        self.pThumbUrl,
                                                                        [NSNumber numberWithFloat:self.pCropOffset],
                                                                        [NSNumber numberWithFloat:self.pHeight],
                                                                        [NSNumber numberWithFloat:self.pWidth],
                                                                        [NSNumber numberWithBool:self.pServerInit],
                                                                        [NSNumber numberWithBool:self.pUploadComplete],
                                                                        [NSNumber numberWithBool:self.pLocalCached],
                                                                        [NSNumber numberWithBool:self.pThumbLocalCached]]
                                                              forKeys:@[
                                                                        PICTURE_ID,
                                                                        PICTURE_SERVER_ID,
                                                                        PICTURE_URL,
                                                                        PICTURE_THUMB_URL,
                                                                        PICTURE_CROP_OFFSET,
                                                                        PICTURE_HEIGHT,
                                                                        PICTURE_WIDTH,
                                                                        PICTURE_SERVER_INIT,
                                                                        PICTURE_UPLOAD_INIT,
                                                                        PICTURE_LOCAL_CACHED,
                                                                        PICTURE_THUMB_LOCAL_CACHED]];
    return packedImage;
}

@end
