//
//  BaseImage.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *SERVER_ID_NONE = @"kp_no_id";
static NSString *LOCAL_IMAGE_URL = @"kp_local_image";

static NSString *PICTURE_ID = @"picture_id";
static NSString *PICTURE_SERVER_ID = @"picture_server_id";
static NSString *PICTURE_URL = @"picture_url";
static NSString *PICTURE_THUMB_URL = @"picture_thumb_url";
static NSString *PICTURE_CROP_OFFSET = @"picture_crop_offset";
static NSString *PICTURE_WIDTH = @"picture_width";
static NSString *PICTURE_HEIGHT = @"picture_height";
static NSString *PICTURE_SERVER_INIT = @"picture_server_init";
static NSString *PICTURE_UPLOAD_INIT = @"picture_upload_init";
static NSString *PICTURE_LOCAL_CACHED = @"picture_local_cache";
static NSString *PICTURE_THUMB_LOCAL_CACHED = @"picture_thumb_local_cache";

@interface BaseImage : NSObject

@property (nonatomic, assign) NSString *pid;
@property (nonatomic, assign) NSString *pServerId;
@property (nonatomic, assign) NSString *pThumbUrl;
@property (nonatomic, assign) NSString *pUrl;
@property (nonatomic) CGFloat pCropOffset;
@property (nonatomic) CGFloat pWidth;
@property (nonatomic) CGFloat pHeight;
@property (nonatomic) BOOL pLocalCached;
@property (nonatomic) BOOL pThumbLocalCached;
@property (nonatomic) BOOL pServerInit;
@property (nonatomic) BOOL pUploadComplete;

- (BaseImage *)initWithUrl:(NSString *)url andThumbUrl:(NSString *)thumbUrl;
- (BaseImage *)initWithImage;

- (BaseImage *) initWithPackedImage:(NSDictionary *)savedObject;
- (NSDictionary *) packImage;

- (BaseImage *)copy;

@end
