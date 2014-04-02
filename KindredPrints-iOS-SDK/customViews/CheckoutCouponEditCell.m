//
//  CheckoutCouponEditCellTableViewCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/21/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "CheckoutCouponEditCell.h"
#import "UserPreferenceHelper.h"
#import "InterfacePreferenceHelper.h"
#import "RoundedTextButton.h"

@interface CheckoutCouponEditCell()

@property (strong, nonatomic) UITextField *txtCouponLabel;
@property (strong, nonatomic) RoundedTextButton *cmdApplyCoupon;

@end

@implementation CheckoutCouponEditCell

static CGFloat PADDING = 10.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect screenBounds = [self bounds];
        screenBounds.size.width = width;
        
        [self setBackgroundColor:[UIColor clearColor]];

        CGFloat buttonHeight = [InterfacePreferenceHelper getCheckoutEditHeight];
        self.cmdApplyCoupon = [[RoundedTextButton alloc] initWithFrame:CGRectMake(screenBounds.size.width-[InterfacePreferenceHelper getCheckoutSpecialPadding]-[InterfacePreferenceHelper getCheckoutEditWidth]-PADDING, (screenBounds.size.height-buttonHeight)/2, [InterfacePreferenceHelper getCheckoutEditWidth], buttonHeight) withStrokeColor:[UIColor whiteColor] withBaseFillColor:[UIColor clearColor] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"APPLY" andFontSize:OrderViewFontSize];
        [self.cmdApplyCoupon addTarget:self action:@selector(clickedApply) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cmdApplyCoupon];

        self.txtCouponLabel =  [[UITextField alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCheckoutSpecialPadding], (screenBounds.size.height-[InterfacePreferenceHelper getCheckoutSpecialRowHeight])/2, screenBounds.size.width-2*[InterfacePreferenceHelper getCheckoutSpecialPadding]-PADDING-self.cmdApplyCoupon.frame.size.width, [InterfacePreferenceHelper getCheckoutSpecialRowHeight])];
        [self.txtCouponLabel setBackgroundColor:[UIColor clearColor]];
        [self.txtCouponLabel setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self.txtCouponLabel setTextColor:[UIColor whiteColor]];
        [self.txtCouponLabel setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter coupon here" attributes:@{NSForegroundColorAttributeName:[InterfacePreferenceHelper getColor:ColorOrderGreyDiv],NSFontAttributeName:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]}]];
        [self.txtCouponLabel setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
        [self.txtCouponLabel setReturnKeyType:UIReturnKeyDone];
        [self.txtCouponLabel addTarget:self
                                      action:@selector(clickedApply)
                      forControlEvents:UIControlEventEditingDidEndOnExit];
        
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        numberToolbar.barStyle = UIBarStyleBlackTranslucent;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeKeyboard)],
                               nil];
        
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCheckoutSpecialPadding], self.txtCouponLabel.frame.origin.y+self.txtCouponLabel.frame.size.height-PADDING, self.txtCouponLabel.frame.size.width, 1)];
        [borderView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:borderView];
        self.txtCouponLabel.inputAccessoryView = numberToolbar;
        [self addSubview:self.txtCouponLabel];
    }
    return self;
}

- (void) clickedApply {
    [self.txtCouponLabel resignFirstResponder];
    if (self.txtCouponLabel.text && [self.txtCouponLabel.text length] > 0) {
        [self.delegate userRequestedApplyCoupon:self.txtCouponLabel.text];
    }
}

-(void)closeKeyboard {
    [self.txtCouponLabel resignFirstResponder];
}

@end
