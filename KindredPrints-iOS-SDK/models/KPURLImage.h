//
//  KPURLImage.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/24/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPImage.h"

@interface KPURLImage : KPImage

-(id) initWithPartnerId:(NSString *)partnerId andOriginalUrl:(NSString *)origUrl;
-(id) initWithPartnerId:(NSString *)partnerId andPreviewUrl:(NSString *)previewUrl andOriginalUrl:(NSString *)origUrl;

@property (strong, nonatomic) NSString *originalUrl;
@property (strong, nonatomic) NSString *previewUrl;

@end
