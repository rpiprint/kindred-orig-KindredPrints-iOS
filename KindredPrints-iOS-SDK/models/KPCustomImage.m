//
//  KPCustomImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 4/16/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPCustomImage.h"

@implementation KPCustomImage

- (id) initWithPartnerId:(NSString *)partnerId andType:(NSString *)type andData:(NSString *)data {
    self = [super init];
    if (self) {
        self.pId = partnerId;
        self.parterType = type;
        self.parterData = data;
    }
    return self;

}

@end
