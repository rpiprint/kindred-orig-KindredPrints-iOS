//
//  KPGenericViewController.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/7/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavButton.h"

@interface KPGenericViewController : UIViewController

@property (strong, nonatomic) NavButton *cmdNext;
@property (strong, nonatomic) NavButton *cmdBack;

- (void) initNavBarWithTitle:(NSString *)title andNextTitle:(NSString *)nextTitle;


@end
