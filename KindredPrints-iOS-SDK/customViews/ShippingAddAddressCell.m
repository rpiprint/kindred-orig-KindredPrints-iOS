//
//  ShippingAddAddressCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/9/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "ShippingAddAddressCell.h"
#import "InterfacePreferenceHelper.h"
#import "UserPreferenceHelper.h"
#import "CircularButton.h"

@interface ShippingAddAddressCell()

@property (strong, nonatomic) CircularButton *addButton;
@property (strong, nonatomic) UILabel *txtTitle;

@end

@implementation ShippingAddAddressCell

static CGFloat const PERC_BUTTON_HEIGHT = 0.55;
static CGFloat const TEXT_PADDING = 15;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat objHeight = [InterfacePreferenceHelper getAddressRowHeight]*PERC_BUTTON_HEIGHT;
        CGRect frame = CGRectMake([InterfacePreferenceHelper getShippingListLeftPadding]*width, ([InterfacePreferenceHelper getAddressRowHeight]-objHeight)/2, objHeight, objHeight);
        self.addButton = [[CircularButton alloc] initWithFrame:frame];
        [self.addButton drawCircleButtonWithPressedFillColor:[UIColor whiteColor] andBasecolor:[UIColor clearColor] andInnerStrokeColor:[UIColor whiteColor] andOuterStrokeColor:[UIColor whiteColor] andButtonType:PlusButton];
        [self.addButton setUserInteractionEnabled:NO];
        
        self.txtTitle = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+frame.size.width+TEXT_PADDING, frame.origin.y, width-frame.origin.x-frame.size.width-TEXT_PADDING, objHeight)];
        if ([[UserPreferenceHelper getAllAddresses] count] > 0) {
            [self.txtTitle setText:@"Add another shipping address"];
        } else {
            [self.txtTitle setText:@"Add shipping address"];
        }
        [self.txtTitle setTextAlignment:NSTextAlignmentLeft];
        [self.txtTitle setBackgroundColor:[UIColor clearColor]];
        [self.txtTitle setTextColor:[UIColor whiteColor]];
        [self.txtTitle setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
        
        UIView *viewDivider = [[UIView alloc] initWithFrame:CGRectMake(0, [InterfacePreferenceHelper getAddressRowHeight], width, 1)];
        [viewDivider setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:viewDivider];
        [self addSubview:self.addButton];
        [self addSubview:self.txtTitle];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    return self;
}

- (void)refreshView {
    
}

@end
