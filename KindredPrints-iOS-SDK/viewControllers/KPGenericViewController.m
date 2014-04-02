//
//  KPGenericViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/7/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPGenericViewController.h"
#import "InterfacePreferenceHelper.h"
#import "BackgroundGradientHelper.h"
#import "NavTitleBar.h"

@interface KPGenericViewController ()


@end

@implementation KPGenericViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer *bgLayer = [BackgroundGradientHelper GetBackgroundBaseGradient];
    bgLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer:bgLayer];
    CAGradientLayer *bgMidLayer = [BackgroundGradientHelper GetBackgroundMidGradient];
    bgMidLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer:bgMidLayer];

    [self initCustomView];
    
    [self initNavBar];
}


- (void) initCustomView {
    // do custom init here
}

- (void) initNavBar {
    [self initNavBarWithTitle:@"Kindred Prints" andNextTitle:@"NEXT"];
}

- (void) initNavBarWithTitle:(NSString *)title andNextTitle:(NSString *)nextTitle {
    [self.navigationController.navigationBar setHidden:NO];
    
    self.cmdNext = [[NavButton alloc] initForwardButtonWithFrame:CGRectMake(320-NEXT_BUTTON_WIDTH, 0, NEXT_BUTTON_WIDTH, self.navigationController.navigationBar.frame.size.height) andText:nextTitle];
    [self.cmdNext.button addTarget:self action:@selector(cmdNextClick) forControlEvents:UIControlEventTouchUpInside];
    self.cmdBack = [[NavButton alloc] initBackButtonWithFrame:CGRectMake(0, 0, BACK_BUTTON_WIDTH, self.navigationController.navigationBar.frame.size.height)];
    [self.cmdBack.button addTarget:self action:@selector(cmdBackClick) forControlEvents:UIControlEventTouchUpInside];
    NavTitleBar *txtTitle = [[NavTitleBar alloc] initWithFrame:CGRectMake(BACK_BUTTON_WIDTH*1.5, 0, 320-BACK_BUTTON_WIDTH*1.5-NEXT_BUTTON_WIDTH, self.navigationController.navigationBar.frame.size.height) withTitle:title];
    
    [self.navigationItem setTitleView:txtTitle];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [negativeSpacer setWidth:[InterfacePreferenceHelper getNegativeSpaceDistance]];
    
    UIBarButtonItem *barNext = [[UIBarButtonItem alloc] initWithCustomView:self.cmdNext];
    [self.navigationItem setRightBarButtonItems:@[negativeSpacer,barNext]];
    
    UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithCustomView:self.cmdBack];
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer,barBack]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)cmdBackClick {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)cmdNextClick {
    
}



@end
