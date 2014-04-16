//
//  KPCustomImage.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 4/16/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPImage.h"

@interface KPCustomImage : KPImage

- (id) initWithPartnerId:(NSString *)partnerId andType:(NSString *)type andData:(NSString *)data;

@property (strong, nonatomic) NSString *parterType;
@property (strong, nonatomic) NSString *parterData;


@end
