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
static NSString *REMOTE_IMAGE_URL = @"kp_remote_image";

static NSString *PICTURE_ID = @"picture_id";

static NSString *PICTURE_PARTNER_ID = @"picture_partner_id";
static NSString *PICTURE_PARTNER_DATA = @"picture_partner_data";
static NSString *PICTURE_TYPE = @"picture_partner_type";

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

static NSString *PICTURE_IS_TWO_SIDED = @"picture_is_two_sided";
static NSString *PICTURE_BACK_SIDE = @"picture_back_side";

@interface BaseImage : NSObject

@property (nonatomic, assign) NSString *pPartnerId;
@property (nonatomic, assign) NSString *pPartnerData;
@property (nonatomic, assign) NSString *pType;

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

@property (nonatomic) BOOL pIsTwoSided;
@property (nonatomic, strong) BaseImage *pBackSide;

- (BaseImage *)initWithPartnerId:(NSString *)partnerId andUrl:(NSString *)url andThumbUrl:(NSString *)thumbUrl;
- (BaseImage *)initForImageWithPartnerId:(NSString *)partnerId;
- (BaseImage *)initPartnerId:(NSString *)partnerId andType:(NSString *)type andCustomData:(NSString *)customData;

- (BaseImage *) initWithPackedImage:(NSDictionary *)savedObject;
- (NSDictionary *) packImage;

- (BaseImage *)copy;

@end
