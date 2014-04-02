//
//  CheckoutLineItemCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/13/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "CheckoutLineItemCell.h"
#import "InterfacePreferenceHelper.h"
#import "RoundedTextButton.h"

@interface CheckoutLineItemCell()

@property (strong, nonatomic) UIView *viewBottomBorder;
@property (strong, nonatomic) UILabel *txtTotal;
@property (strong, nonatomic) UILabel *txtDescription;
@property (strong, nonatomic) UILabel *txtQuantity;
@property (strong, nonatomic) RoundedTextButton *cmdEditShipping;

@property (strong, nonatomic) LineItem *currItem;

@end

@implementation CheckoutLineItemCell

static CGFloat PADDING = 5;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect screenBounds = [self bounds];
        screenBounds.size.width = width;
 
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.txtQuantity = [[UILabel alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCheckoutSpecialPadding], 0, screenBounds.size.width*[InterfacePreferenceHelper getCheckoutQuantityPercent], [InterfacePreferenceHelper getCheckoutRowHeight])];
        [self.txtQuantity setBackgroundColor:[UIColor clearColor]];
        [self.txtQuantity setTextAlignment:NSTextAlignmentCenter];
        [self.txtQuantity setTextColor:[UIColor whiteColor]];
        [self.txtQuantity setFont:[UIFont fontWithName:FONT_HEAVY size:OrderQuantityFontSize]];
        [self addSubview:self.txtQuantity];
    
        CGFloat buttonHeight = [InterfacePreferenceHelper getCheckoutEditHeight];
        self.cmdEditShipping = [[RoundedTextButton alloc]
                                initWithFrame:CGRectMake([InterfacePreferenceHelper getCheckoutSpecialPadding]+PADDING, ([InterfacePreferenceHelper getCheckoutRowHeight]-buttonHeight)/2, self.txtQuantity.frame.size.width, buttonHeight)
                                withStrokeColor:[UIColor whiteColor]
                                withBaseFillColor:[UIColor clearColor]
                                andPressedFillColor:[UIColor whiteColor]
                                andTextColor:[UIColor whiteColor]
                                andText:@"EDIT"
                                andFontSize:OrderViewFontSize];
        [self.cmdEditShipping addTarget:self action:@selector(cmdEditShippingClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cmdEditShipping];
        
    
        self.txtTotal = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width-screenBounds.size.width*[InterfacePreferenceHelper getCheckoutAmountPercent]-[InterfacePreferenceHelper getCheckoutPadding], 0, screenBounds.size.width*[InterfacePreferenceHelper getCheckoutAmountPercent], [InterfacePreferenceHelper getCheckoutRowHeight])];
        [self.txtTotal setBackgroundColor:[UIColor clearColor]];
        [self.txtTotal setTextAlignment:NSTextAlignmentCenter];
        [self.txtTotal setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
        [self addSubview:self.txtTotal];
    
        self.txtDescription = [[UILabel alloc] initWithFrame:CGRectMake(self.txtQuantity.frame.size.width+self.txtQuantity.frame.origin.x, 0, self.txtTotal.frame.origin.x-[InterfacePreferenceHelper getCheckoutPadding]-PADDING-self.txtQuantity.frame.size.width, [InterfacePreferenceHelper getCheckoutRowHeight])];
        [self.txtDescription setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:self.txtDescription];
        
        self.viewBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, [InterfacePreferenceHelper getCheckoutRowHeight], screenBounds.size.width, 1)];

        [self addSubview:self.viewBottomBorder];
    }
    return self;
}

- (void)updateCellForLineItem:(LineItem *)item {
    self.currItem = item;
    [self.cmdEditShipping setHidden:YES];
    if ([item.liType isEqualToString:LINE_ITEM_TYPE_PRODUCT]) {
        [self initOrderItemRowWithQuantity:item.liQuantity andDescription:item.liName andTotal:item.liAmount];
    } else if ([item.liType isEqualToString:LINE_ITEM_TYPE_SUBTOTAL] || [item.liType isEqualToString:LINE_ITEM_TYPE_SHIPPING]) {
        [self initWithDetailRow:item.liAmount withHeader:item.liName];
        if ([item.liType isEqualToString:LINE_ITEM_TYPE_SHIPPING])
            [self.cmdEditShipping setHidden:NO];
    } else if ([item.liType isEqualToString:LINE_ITEM_TYPE_CREDITS] || [item.liType isEqualToString:LINE_ITEM_TYPE_COUPON]) {
        [self initWithCreditCouponRow:item.liAmount withHeader:item.liName];
    } else if ([item.liType isEqualToString:LINE_ITEM_TYPE_TOTAL]) {
        [self initTotalTotalRow:item.liAmount withHeader:item.liName];
    }
}

- (void) initOrderItemRowWithQuantity:(NSInteger)quantity andDescription:(NSString *)description andTotal:(NSString *)total {
    [self.txtDescription setTextColor:[UIColor whiteColor]];
    [self.txtTotal setTextColor:[UIColor whiteColor]];
    [self.txtDescription setFont:[UIFont fontWithName:FONT_LIGHT size:OrderDetailFontSize]];
    [self.txtTotal setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
    
    [self.txtQuantity setHidden:NO];
    [self.cmdEditShipping setHidden:YES];
    
    [self.txtDescription setTextAlignment:NSTextAlignmentLeft];
    [self.txtQuantity setText:[NSString stringWithFormat:@"%ld", (long)quantity]];
    [self.txtDescription setText:description];
    [self.txtTotal setText:total];
    
    [self.viewBottomBorder setBackgroundColor:[InterfacePreferenceHelper getColor:ColorOrderGreyDiv]];
}

- (void) initWithCreditCouponRow:(NSString *)total withHeader:(NSString *)title {
    [self.txtDescription setTextColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton]];
    [self.txtTotal setTextColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton]];
    [self.txtDescription setFont:[UIFont fontWithName:FONT_LIGHT size:OrderDetailFontSize]];
    [self.txtTotal setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
    
    [self.txtQuantity setHidden:YES];
    [self.cmdEditShipping setHidden:YES];
    
    [self.txtDescription setTextAlignment:NSTextAlignmentRight];
    [self.txtDescription setText:title];
    [self.txtTotal setText:total];
    
    [self.viewBottomBorder setBackgroundColor:[InterfacePreferenceHelper getColor:ColorOrderGreyDiv]];
}

- (void) initWithDetailRow:(NSString *)total withHeader:(NSString *)title {
    [self.txtDescription setTextColor:[UIColor whiteColor]];
    [self.txtTotal setTextColor:[UIColor whiteColor]];
    [self.txtDescription setFont:[UIFont fontWithName:FONT_REGULAR size:OrderDetailFontSize]];
    [self.txtTotal setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
    
    [self.txtQuantity setHidden:YES];
    [self.cmdEditShipping setHidden:YES];

    [self.txtDescription setTextAlignment:NSTextAlignmentRight];
    [self.txtDescription setText:title];
    [self.txtTotal setText:total];
    
    [self.viewBottomBorder setBackgroundColor:[InterfacePreferenceHelper getColor:ColorOrderGreyDiv]];
}


- (void) initTotalTotalRow:(NSString *)total withHeader:(NSString *)title {
    [self.txtDescription setTextColor:[UIColor whiteColor]];
    [self.txtTotal setTextColor:[UIColor whiteColor]];
    [self.txtDescription setFont:[UIFont fontWithName:FONT_HEAVY size:MenuButtonFontSize]];
    [self.txtTotal setFont:[UIFont fontWithName:FONT_HEAVY size:MenuButtonFontSize]];
    
    [self.txtQuantity setHidden:YES];
    [self.cmdEditShipping setHidden:YES];
    
    [self.txtDescription setTextAlignment:NSTextAlignmentRight];
    [self.txtDescription setText:title];
    [self.txtTotal setText:total];
    
    [self.viewBottomBorder setBackgroundColor:[UIColor clearColor]];
}

- (void)cmdEditShippingClick {
    [self.delegate userRequestedChangeShippingWithAddressId:self.currItem.liAddressId];
}

@end
