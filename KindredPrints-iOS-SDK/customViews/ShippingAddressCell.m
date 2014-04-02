//
//  ShippingAddressCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/8/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "ShippingAddressCell.h"
#import "CircularCheckbox.h"
#import "InterfacePreferenceHelper.h"
#import "RoundedTextButton.h"

@interface ShippingAddressCell()

@property (strong, nonatomic) BaseAddress *address;

@property (strong, nonatomic) CircularCheckbox *chkSelected;
@property (strong, nonatomic) UILabel *txtTitle;
@property (strong, nonatomic) UILabel *txtSubtitle;

@property (strong, nonatomic) RoundedTextButton *cmdEdit;

@end

@implementation ShippingAddressCell

static CGFloat const PERC_CHECKBOX_HEIGHT = 0.55;
static CGFloat const PERC_EDIT_HEIGHT = 0.45;

static CGFloat const TEXT_PADDING = 10;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andAddress:(BaseAddress *)address andWidth:(NSInteger)width {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.address = address;
        
        CGFloat objHeight = [InterfacePreferenceHelper getAddressRowHeight]*PERC_CHECKBOX_HEIGHT;
        self.chkSelected = [[CircularCheckbox alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getShippingListLeftPadding]*width, ([InterfacePreferenceHelper getAddressRowHeight]-objHeight)/2, objHeight, objHeight)];
        [self.chkSelected drawCircleCheckboxWithCheckedFillColor:[UIColor whiteColor] andOuterStrokeColor:[UIColor whiteColor] andInnerStrokeColor:[InterfacePreferenceHelper getColor:ColorNavBar]];
        [self.chkSelected addTarget:self action:@selector(chkSelectionChanged) forControlEvents:UIControlEventTouchUpInside];

        CGFloat editObjHeight = [InterfacePreferenceHelper getAddressRowHeight]*PERC_EDIT_HEIGHT;
        self.cmdEdit = [[RoundedTextButton alloc] initWithFrame:CGRectMake(width-[InterfacePreferenceHelper getShippingEditWidth]-[InterfacePreferenceHelper getShippingListRightPadding]*width, ([InterfacePreferenceHelper getAddressRowHeight]-editObjHeight)/2, [InterfacePreferenceHelper getShippingEditWidth], editObjHeight) withStrokeColor:[UIColor whiteColor] withBaseFillColor:[UIColor clearColor] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"EDIT" andFontSize:MenuButtonFontSize];
        [self.cmdEdit addTarget:self action:@selector(editThisAddress) forControlEvents:UIControlEventTouchUpInside];
        
        self.txtTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.chkSelected.frame.origin.x+self.chkSelected.frame.size.width+TEXT_PADDING, self.chkSelected.frame.origin.y, self.cmdEdit.frame.origin.x-self.chkSelected.frame.size.width-self.chkSelected.frame.origin.x-TEXT_PADDING, objHeight/2)];
        [self.txtTitle setTextAlignment:NSTextAlignmentLeft];
        [self.txtTitle setBackgroundColor:[UIColor clearColor]];
        [self.txtTitle setTextColor:[UIColor whiteColor]];
        [self.txtTitle setFont:[UIFont fontWithName:FONT_REGULAR size:[InterfacePreferenceHelper getShippingFontMultiplier]*AddressTitleFontSize]];
        
        self.txtSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(self.chkSelected.frame.origin.x+self.chkSelected.frame.size.width+TEXT_PADDING, self.txtTitle.frame.origin.y + self.txtTitle.frame.size.height, self.cmdEdit.frame.origin.x-self.chkSelected.frame.size.width-self.chkSelected.frame.origin.x-TEXT_PADDING, objHeight/2)];
        [self.txtSubtitle setTextAlignment:NSTextAlignmentLeft];
        [self.txtSubtitle setBackgroundColor:[UIColor clearColor]];
        [self.txtSubtitle setTextColor:[UIColor whiteColor]];
        [self.txtSubtitle setFont:[UIFont fontWithName:FONT_LIGHT size:[InterfacePreferenceHelper getShippingFontMultiplier]*AddressSubtitleFontSize]];
        
        [self addSubview:self.cmdEdit];
        [self addSubview:self.chkSelected];
        [self addSubview:self.txtTitle];
        [self addSubview:self.txtSubtitle];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)editThisAddress {
    [self.delegate userRequestedEditOfAddress:self.address];
}

- (void)chkSelectionChanged {
    [self setSelected:!self.selected animated:YES];
    [self.delegate userChangedSelection:self.selected andAddress:self.address];
}

- (void)updateViewWithAddress:(BaseAddress *)address {
    self.address = address;
    
    [self.txtTitle setText:address.aName];
    [self.txtSubtitle setText:[NSString stringWithFormat:@"%@, %@, %@", address.aStreet, address.aCity, address.aState]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.chkSelected setSelected:selected];
}

@end
