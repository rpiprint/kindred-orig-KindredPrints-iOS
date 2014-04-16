//
//  KPMEMImage.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/24/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPImage.h"

@interface KPMEMImage : KPImage

- (id) initWithPartnerId:(NSString *)partnerId andImage:(UIImage *)image;

@property (strong, nonatomic) UIImage *image;

@end
