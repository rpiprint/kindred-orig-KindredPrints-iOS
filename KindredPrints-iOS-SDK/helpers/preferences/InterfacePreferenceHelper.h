//
//  InterfacePreferenceHelper.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "PreferenceHelper.h"

typedef NSInteger PictureSize;
typedef NSInteger ColorScheme;
static NSString *const FONT_LIGHT = @"HelveticaNeue-Light";
static NSString * const FONT_REGULAR = @"HelveticaNeue";
static NSString * const FONT_HEAVY = @"HelveticaNeue-Bold";

static CGFloat const STATUS_BAR_HEIGHT = 20.0f;
static CGFloat const BACK_BUTTON_WIDTH = 40.0f;
static CGFloat const NEXT_BUTTON_WIDTH = 60.0f;

@interface InterfacePreferenceHelper : PreferenceHelper

enum FontSize : NSInteger {
    AddressTitleFontSize = 12,
    AddressSubtitleFontSize = 10,
    OrderViewFontSize = 12,
    ImportButtonFontSize = 12,
    MenuButtonFontSize = 16,
    PricingFontSize = 22,
    OrderQuantityFontSize = 24,
    QuantityFontSize = 24,
    OrderDetailFontSize = 12
};

enum PictureSize : NSInteger {
    PreviewPictureType = 0,
    ThumbnailPictureType = 1
};

enum ColorScheme : NSInteger {
    ColorNavBar = 1,
    ColorOrderGreyDiv = 2,
    ColorOrderWhiteDiv = 3,
    ColorDarkGrayTrans = 4,
    ColorNavBarNextButton = 5,
    ColorCompleteOrderButton = 6,
    ColorDivider = 7,
    ColorError = 8,
    ColorLoginHeader = 9,
    ColorOrderTotalLabel = 10,
    ColorOrderTotal = 11,
    ColorButtonDisabled = 12
};

+ (UIColor *)getColor:(NSInteger)scheme;

+ (CGFloat)getSelectImageSide;

+ (CGFloat)getCheckoutEditHeight;
+ (CGFloat)getCheckoutEditWidth;
+ (CGFloat)getCheckoutPadding;
+ (CGFloat)getCheckoutSpecialPadding;
+ (CGFloat)getCheckoutQuantityPercent;
+ (CGFloat)getCheckoutAmountPercent;

+ (CGFloat)getLoginFormFieldWidth;
+ (CGFloat)getLoginFormFieldHeight;

+ (CGFloat)getShippingFontMultiplier;
+ (CGFloat)getShippingEditWidth;
+ (CGFloat)getShippingListLeftPadding;
+ (CGFloat)getShippingListRightPadding;

+ (CGFloat)getCartDeletePadding;
+ (CGFloat)getCartDeleteSize;
+ (CGFloat)getCartPadding;
+ (CGFloat)getCartHeaderSize;

+ (CGFloat)getAddressRowHeight;
+ (CGFloat)getOrderTotalRowHeight;
+ (CGFloat)getCheckoutRowHeight;
+ (CGFloat)getCheckoutBlankRowHeight;
+ (CGFloat)getCheckoutSpecialRowHeight;

+ (NSInteger)getPicturePreviewSize;
+ (NSInteger)getPictureThumbSize;
+ (CGFloat)getNegativeSpaceDistance;
+ (BOOL)isBorderDisabled;
+ (void)setBorderDisabled:(BOOL)disabled;
+ (CGFloat)getBorderWidth:(CGFloat)borderPercent onSize:(CGSize)size;
+ (CGFloat)getBorderPercent:(CGFloat)borderPercent;
+ (UIColor *)getBorderColor;
+ (CGFloat)getStatusBarHeight;
+ (void)setBorderColor:(UIColor *)borderColor;

@end
