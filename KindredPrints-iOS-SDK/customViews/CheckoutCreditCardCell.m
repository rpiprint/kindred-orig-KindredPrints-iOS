//
//  CheckoutCreditCardCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/13/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "CheckoutCreditCardCell.h"
#import "UserPreferenceHelper.h"
#import "InterfacePreferenceHelper.h"
#import "RoundedTextButton.h"

@interface CheckoutCreditCardCell()

@property (strong, nonatomic) UILabel *txtPaymentDetails;
@property (strong, nonatomic) RoundedTextButton *cmdEditPayment;

@end

@implementation CheckoutCreditCardCell

static CGFloat PADDING = 10.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect screenBounds = [self bounds];
        screenBounds.size.width = width;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat buttonHeight = [InterfacePreferenceHelper getCheckoutEditHeight];;
        self.cmdEditPayment = [[RoundedTextButton alloc] initWithFrame:CGRectMake(screenBounds.size.width-[InterfacePreferenceHelper getCheckoutSpecialPadding]-[InterfacePreferenceHelper getCheckoutEditWidth]-PADDING, (screenBounds.size.height-buttonHeight)/2, [InterfacePreferenceHelper getCheckoutEditWidth], buttonHeight)];
        [self.cmdEditPayment drawButtonWithStrokeColor:[UIColor whiteColor] withBaseFillColor:[UIColor clearColor] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"EDIT" andFontSize:OrderViewFontSize];
        [self.cmdEditPayment addTarget:self action:@selector(clickedEdit) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cmdEditPayment];
        
        self.txtPaymentDetails = [[UILabel alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCheckoutSpecialPadding], (screenBounds.size.height-[InterfacePreferenceHelper getCheckoutSpecialRowHeight])/2, screenBounds.size.width-2*PADDING-self.cmdEditPayment.frame.size.width, [InterfacePreferenceHelper getCheckoutSpecialRowHeight])];
        [self.txtPaymentDetails setBackgroundColor:[UIColor clearColor]];
        [self.txtPaymentDetails setTextColor:[UIColor whiteColor]];
        [self.txtPaymentDetails setTextAlignment:NSTextAlignmentLeft];
        [self.txtPaymentDetails setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
        [self addSubview:self.txtPaymentDetails];
    
    }
    return self;
}

- (void) updateDisplay {
    UserObject *currUser = [UserPreferenceHelper getUserObject];
    [self.txtPaymentDetails setText:[NSString stringWithFormat:@"%@ xxxx xxxx xxxx %@", currUser.uCreditType, currUser.uLastFour]];
}


- (void) clickedEdit {
    [self.delegate userRequestedCreditCardEdit];
}


@end
