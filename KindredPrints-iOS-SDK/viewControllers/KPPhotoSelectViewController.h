//
//  KPPhotoSelectViewController.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 4/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPGenericViewController.h"
#import "KPImage.h"
#import "KPURLImage.h"
#import "KPMEMImage.h"
#import "KPCustomImage.h"

@interface KPPhotoSelectViewController : KPGenericViewController

- (id)initWithNibName:(NSString *)nibNameOrNil andImages:(NSArray *)images;


@end
