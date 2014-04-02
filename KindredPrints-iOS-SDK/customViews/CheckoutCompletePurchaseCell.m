//
//  CheckoutCompletePurchaseCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/13/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "CheckoutCompletePurchaseCell.h"
#import "RoundedTextButton.h"
#import "InterfacePreferenceHelper.h"

@interface CheckoutCompletePurchaseCell()

@property (strong, nonatomic) RoundedTextButton *cmdCompletePurchase;

@end

@implementation CheckoutCompletePurchaseCell

static CGFloat PERC_BUTTON_HEIGHT = 0.8f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect rowBounds = self.bounds;
        rowBounds.size.width = width;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.cmdCompletePurchase = [[RoundedTextButton alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCheckoutSpecialPadding], [InterfacePreferenceHelper getCheckoutSpecialRowHeight]*(1-PERC_BUTTON_HEIGHT)/2, rowBounds.size.width-2*[InterfacePreferenceHelper getCheckoutSpecialPadding], [InterfacePreferenceHelper getCheckoutSpecialRowHeight]*PERC_BUTTON_HEIGHT) withStrokeColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton] withBaseFillColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"COMPLETE ORDER" andFontSize:MenuButtonFontSize];
        [self.cmdCompletePurchase addTarget:self action:@selector(cmdCompletePurchaseClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.cmdCompletePurchase];
    }
    return self;
}

- (void)cmdCompletePurchaseClick {
    [self.delegate userRequestedCheckout];
}

@end
