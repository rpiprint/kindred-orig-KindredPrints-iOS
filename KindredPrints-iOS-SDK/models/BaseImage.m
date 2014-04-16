//
//  BaseImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "BaseImage.h"

@implementation BaseImage


- (BaseImage *)initWithPartnerId:(NSString *)partnerId andUrl:(NSString *)url andThumbUrl:(NSString *)thumbUrl {
    [self initBaseData];
    self.pType = REMOTE_IMAGE_URL;
    self.pPartnerId = partnerId;
    self.pUrl = url;
    self.pThumbUrl = thumbUrl;
    self.pIsTwoSided = NO;
    self.pBackSide = nil;
    
    return self;
}

- (BaseImage *)initForImageWithPartnerId:(NSString *)partnerId {
    [self initBaseData];
    self.pType = LOCAL_IMAGE_URL;
    self.pPartnerId = partnerId;
    self.pIsTwoSided = NO;
    
    return self;
}

- (BaseImage *)initPartnerId:(NSString *)partnerId andType:(NSString *)type andCustomData:(NSString *)customData {
    [self initBaseData];
    self.pPartnerId = partnerId;
    self.pType = type;
    self.pPartnerData = customData;
    self.pIsTwoSided = YES;
    
    return self;
}

- (void) initBaseData {
    NSString *UUID = [[NSUUID UUID] UUIDString];
    self.pid = UUID;
    self.pPartnerId = LOCAL_IMAGE_URL;
    self.pPartnerData = LOCAL_IMAGE_URL;
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
}

- (BaseImage *)copy {
    BaseImage *newCopy = [[BaseImage alloc] initWithPackedImage:[self packImage]];
    return newCopy;
}

- (BaseImage *) initWithPackedImage:(NSDictionary *)savedObject {
    self.pid = [savedObject objectForKey:PICTURE_ID];
    self.pPartnerId = [savedObject objectForKey:PICTURE_PARTNER_ID];
    self.pPartnerData = [savedObject objectForKey:PICTURE_PARTNER_DATA];
    self.pType = [savedObject objectForKey:PICTURE_TYPE];
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
    self.pIsTwoSided = [[savedObject objectForKey:PICTURE_IS_TWO_SIDED] boolValue];
    if (self.pIsTwoSided && [savedObject objectForKey:PICTURE_BACK_SIDE]) {
        self.pBackSide = [[BaseImage alloc] initWithPackedImage:[savedObject objectForKey:PICTURE_BACK_SIDE]];
    } else {
        self.pBackSide = nil;
    }
    return self;
}
- (NSDictionary *) packImage {
    NSMutableDictionary *packedImage = [[NSMutableDictionary alloc] initWithObjects:@[self.pid,
                                                                        self.pPartnerId,
                                                                        self.pPartnerData,
                                                                        self.pType,
                                                                        self.pServerId,
                                                                        self.pUrl,
                                                                        self.pThumbUrl,
                                                                        [NSNumber numberWithFloat:self.pCropOffset],
                                                                        [NSNumber numberWithFloat:self.pHeight],
                                                                        [NSNumber numberWithFloat:self.pWidth],
                                                                        [NSNumber numberWithBool:self.pServerInit],
                                                                        [NSNumber numberWithBool:self.pUploadComplete],
                                                                        [NSNumber numberWithBool:self.pLocalCached],
                                                                        [NSNumber numberWithBool:self.pThumbLocalCached],
                                                                        [NSNumber numberWithBool:self.pIsTwoSided]
                                                                        ]
                                                              forKeys:@[
                                                                        PICTURE_ID,
                                                                        PICTURE_PARTNER_ID,
                                                                        PICTURE_PARTNER_DATA,
                                                                        PICTURE_TYPE,
                                                                        PICTURE_SERVER_ID,
                                                                        PICTURE_URL,
                                                                        PICTURE_THUMB_URL,
                                                                        PICTURE_CROP_OFFSET,
                                                                        PICTURE_HEIGHT,
                                                                        PICTURE_WIDTH,
                                                                        PICTURE_SERVER_INIT,
                                                                        PICTURE_UPLOAD_INIT,
                                                                        PICTURE_LOCAL_CACHED,
                                                                        PICTURE_THUMB_LOCAL_CACHED,
                                                                        PICTURE_IS_TWO_SIDED]];
    if (self.pBackSide) {
        [packedImage setObject:[self packImage] forKey:PICTURE_BACK_SIDE];
    }
    return packedImage;
}

@end
