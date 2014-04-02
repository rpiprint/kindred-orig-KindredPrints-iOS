//
//  KPLoadingScreenViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPLoadingScreenViewController.h"
#import "InterfacePreferenceHelper.h"
#import "BackgroundGradientHelper.h"

@interface KPLoadingScreenViewController ()

@end

@implementation KPLoadingScreenViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *bgLayer = [BackgroundGradientHelper GetBackgroundBaseGradient];
    bgLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer:bgLayer];
    CAGradientLayer *bgMidLayer = [BackgroundGradientHelper GetBackgroundMidGradient];
    bgMidLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer:bgMidLayer];

    
    
    [self.view bringSubviewToFront:self.progView];
    [self.view bringSubviewToFront:self.txtLoadingMessage];
}

- (IBAction)cmdCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
