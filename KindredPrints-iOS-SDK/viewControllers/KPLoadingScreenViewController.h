//
//  KPLoadingScreenViewController.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPLoadingScreenViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *progView;
@property (weak, nonatomic) IBOutlet UILabel *txtLoadingMessage;

@end
