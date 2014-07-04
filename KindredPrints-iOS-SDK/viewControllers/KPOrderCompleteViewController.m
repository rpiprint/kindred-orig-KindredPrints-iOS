//
//  KPOrderCompleteViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/21/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPOrderCompleteViewController.h"
#import "InterfacePreferenceHelper.h"
#import "DevPreferenceHelper.h"
#import "UserPreferenceHelper.h"
#import "KPPhotoOrderController.h"
#import "KPCartPageViewController.h"
#import "RoundedTextButton.h"
#import "UserObject.h"
#import "Mixpanel.h"

@interface KPOrderCompleteViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *allViews;

@property (strong, nonatomic) UserObject *currUser;

@property (weak, nonatomic) IBOutlet UIImageView *partnerLogo;

@property (weak, nonatomic) IBOutlet RoundedTextButton *cmdDone;
@property (weak, nonatomic) IBOutlet UILabel *txtEmail;
@property (weak, nonatomic) IBOutlet UILabel *txtSupport;

@property (strong, nonatomic) Mixpanel *mixpanel;
@property (weak, nonatomic) IBOutlet UIView *baseViewContainer;
@property (weak, nonatomic) IBOutlet UIView *topViewContainer;

@end

@implementation KPOrderCompleteViewController

- (UserObject *)currUser {
    if (!_currUser) _currUser = [UserPreferenceHelper getUserObject];
    return _currUser;
}


- (Mixpanel *)mixpanel {
    if (!_mixpanel) _mixpanel = [Mixpanel sharedInstance];
    return _mixpanel;
}


- (void) initCustomView {
    for (UIView *v in self.allViews)
        [self.view bringSubviewToFront:v];
    
    [self.cmdDone drawButtonWithStrokeColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton] withBaseFillColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"DONE" andFontSize:MenuButtonFontSize];
    
    [self.partnerLogo setContentMode:UIViewContentModeScaleAspectFit];
    dispatch_queue_t loaderQ = dispatch_queue_create("logo_download", NULL);
    dispatch_async(loaderQ, ^{
        NSURL *imageUrl = [NSURL URLWithString:[DevPreferenceHelper getPartnerLogoUrl]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.partnerLogo setImage:[UIImage imageWithData:imageData]];
        });
    });
    
    UITapGestureRecognizer *tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(launchContactForm)];
    [self.txtSupport addGestureRecognizer:tapGestureRecog];
    
    [self.txtEmail setBackgroundColor:[UIColor clearColor]];
    [self.txtSupport setBackgroundColor:[UIColor clearColor]];
    
    [self.txtEmail setText:self.currUser.uEmail];
    
    [self.mixpanel track:@"order_complete_page_view"];
}

- (void)viewDidLayoutSubviews {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self updateContainerViews:[[UIApplication sharedApplication] statusBarOrientation]];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self updateContainerViews:toInterfaceOrientation];
    }
}

- (void) updateContainerViews:(NSInteger)orient {
    CGRect window = [InterfacePreferenceHelper getScreenBounds];

    if (orient == UIInterfaceOrientationPortrait) {
        if (self.topViewContainer && self.baseViewContainer) {
            self.topViewContainer.frame = CGRectMake((window.size.width-self.topViewContainer.frame.size.width)/2, 20, self.topViewContainer.frame.size.width, self.topViewContainer.frame.size.height);
            self.baseViewContainer.frame = CGRectMake(20, 220, self.baseViewContainer.frame.size.width, self.baseViewContainer.frame.size.height);
        }
    } else if (orient == UIInterfaceOrientationLandscapeLeft || orient == UIInterfaceOrientationLandscapeRight) {

        CGFloat startTopX = 20;
        CGFloat startBotX = 320;
        if (self.topViewContainer && self.baseViewContainer) {
            startTopX = (window.size.width-self.topViewContainer.frame.size.width-self.baseViewContainer.frame.size.width)/2;
            startBotX = startTopX+self.topViewContainer.frame.size.width;
            self.topViewContainer.frame = CGRectMake(startTopX, 20, self.topViewContainer.frame.size.width, self.topViewContainer.frame.size.height);
            self.baseViewContainer.frame = CGRectMake(startBotX, 20, self.baseViewContainer.frame.size.width, self.baseViewContainer.frame.size.height);
        }
    }
}


- (void) initNavBar {
    [self.navigationController.navigationBar setHidden:YES];
}

- (void) launchContactForm {
    NSString *supportLink = @"http://kindredprints.com/contact";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:supportLink]];
}

- (IBAction)cmdDoneClick:(id)sender {
    KPPhotoOrderController *navController = (KPPhotoOrderController *)self.navigationController;
    [navController.orderDelegate userDidCompleteOrder:navController];
    [self dismissViewControllerAnimated:YES completion:^{
        KPCartPageViewController *cartVC = [[KPCartPageViewController alloc] initWithNibName:@"KPCartPageViewController" bundle:nil];
        cartVC.isRootController = YES;
        [navController setViewControllers:@[cartVC] animated:YES];
    }];
}

@end
