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
#import "KPPhotoOrderController.h"
#import "RoundedTextButton.h"

@interface KPLoadingScreenViewController ()

@property (strong, nonatomic) RoundedTextButton *cmdCancel;

@end

@implementation KPLoadingScreenViewController

static NSInteger CANCEL_BUTTON_WIDTH = 100;
static NSInteger CANCEL_BUTTON_HEIGHT = 35;
static NSInteger PADDING = 25;

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *bgLayer = [BackgroundGradientHelper GetBackgroundBaseGradient];
    bgLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer:bgLayer];
    CAGradientLayer *bgMidLayer = [BackgroundGradientHelper GetBackgroundMidGradient];
    bgMidLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer:bgMidLayer];


    self.cmdCancel = [[RoundedTextButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-CANCEL_BUTTON_WIDTH)/2, self.progView.frame.origin.y + self.progView.frame.size.height+PADDING, CANCEL_BUTTON_WIDTH, CANCEL_BUTTON_HEIGHT)];
    [self.cmdCancel drawButtonWithStrokeColor:[UIColor whiteColor] withBaseFillColor:[UIColor clearColor] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"CANCEL" andFontSize:MenuButtonFontSize];
    [self.cmdCancel addTarget:self action:@selector(cmdCancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.cmdCancel];
    [self.view bringSubviewToFront:self.progView];
    [self.view bringSubviewToFront:self.txtLoadingMessage];
}

- (IBAction)cmdCancelClicked {
    KPPhotoOrderController *navController = (KPPhotoOrderController *)self.navigationController;
    if (navController.orderDelegate) [navController.orderDelegate userDidClickCancel:navController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
