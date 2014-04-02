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
#import "RoundedTextButton.h"
#import "UserObject.h"

@interface KPOrderCompleteViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *allViews;

@property (strong, nonatomic) UserObject *currUser;

@property (weak, nonatomic) IBOutlet UIImageView *partnerLogo;

@property (weak, nonatomic) IBOutlet RoundedTextButton *cmdDone;
@property (weak, nonatomic) IBOutlet UILabel *txtEmail;
@property (weak, nonatomic) IBOutlet UILabel *txtSupport;

@end

@implementation KPOrderCompleteViewController

- (UserObject *)currUser {
    if (!_currUser) _currUser = [UserPreferenceHelper getUserObject];
    return _currUser;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
