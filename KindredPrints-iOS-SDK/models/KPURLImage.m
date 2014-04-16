//
//  KPURLImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/24/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPURLImage.h"

@implementation KPURLImage

-(id) initWithPartnerId:(NSString *)partnerId andOriginalUrl:(NSString *)origUrl {
    return [self initWithPartnerId:partnerId andPreviewUrl:origUrl andOriginalUrl:origUrl];
}
-(id) initWithPartnerId:(NSString *)parterId andPreviewUrl:(NSString *)previewUrl andOriginalUrl:(NSString *)origUrl {
    self = [super init];
    if (self) {
        self.pId = parterId;
        self.previewUrl = previewUrl;
        self.originalUrl = origUrl;
    }
    return self;
}

@end
