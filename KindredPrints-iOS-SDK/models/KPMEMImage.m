//
//  KPMEMImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/24/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPMEMImage.h"

@implementation KPMEMImage

- (id) initWithPartnerId:(NSString *)partnerId andImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.pId = partnerId;
        self.image = image;
    }
    return self;
}

@end
