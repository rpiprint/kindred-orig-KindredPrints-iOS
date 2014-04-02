//
//  KPURLImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/24/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPURLImage.h"

@implementation KPURLImage

-(id) initWithOriginalUrl:(NSString *)origUrl {
    return [self initWithPreviewUrl:origUrl andOriginalUrl:origUrl];
}
-(id) initWithPreviewUrl:(NSString *)previewUrl andOriginalUrl:(NSString *)origUrl {
    self = [super init];
    if (self) {
        self.previewUrl = previewUrl;
        self.originalUrl = origUrl;
    }
    return self;
}

@end
