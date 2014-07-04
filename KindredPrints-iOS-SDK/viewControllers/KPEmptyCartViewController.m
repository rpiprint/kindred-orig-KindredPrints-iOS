//
//  KPEmptyCartViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/6/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPEmptyCartViewController.h"
#import "InterfacePreferenceHelper.h"

@interface KPEmptyCartViewController ()

@end

@implementation KPEmptyCartViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[InterfacePreferenceHelper getColor:ColorNavBar]];
    
    CGRect bounds = [InterfacePreferenceHelper getScreenBounds];
    
    UILabel *txtMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, bounds.size.height/2-STATUS_BAR_HEIGHT-self.navigationController.navigationBar.frame.size.height, bounds.size.width, QuantityFontSize*2)];
    [txtMessage setFont:[UIFont fontWithName:FONT_REGULAR size:QuantityFontSize]];
    [txtMessage setTextAlignment:NSTextAlignmentCenter];
    [txtMessage setTextColor:[UIColor whiteColor]];
    [txtMessage setText:@"Your cart is empty."];
    
    [self.view addSubview:txtMessage];
}

@end
