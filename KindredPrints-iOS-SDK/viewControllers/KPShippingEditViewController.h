//
//  KPShippingEntryViewController.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/9/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPGenericViewController.h"
#import "BaseAddress.h"


@interface KPShippingEditViewController : KPGenericViewController

@property (strong, nonatomic) BaseAddress *currAddress;

@end
