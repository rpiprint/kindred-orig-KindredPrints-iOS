//
//  InterfacePreferenceHelper.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "InterfacePreferenceHelper.h"

static NSString *KEY_BORDER_DISABLED = @"kp_border_disabled";
static NSString *KEY_BORDER_COLOR = @"kp_border_color";

@implementation InterfacePreferenceHelper

+ (UIColor *)getColor:(NSInteger)scheme {
    if (scheme == ColorNavBar) {
        return [UIColor colorWithRed:124.0/255.0 green:126.0/255.0 blue:133.0/255.0 alpha:1];
    } else if (scheme == ColorNavBarNextButton) {
        return [UIColor colorWithRed:82.0/255.0 green:204.0/255.0 blue:239.0/255.0 alpha:1.0];
    } else if (scheme == ColorOrderTotal) {
        return [UIColor colorWithRed:122.0/255.0 green:126.0/255.0 blue:130.0/255.0 alpha:1];
    } else if (scheme == ColorOrderTotalLabel) {
        return [UIColor colorWithRed:160.0/255.0 green:169.0/255.0 blue:171.0/255.0 alpha:1];
    } else if (scheme == ColorLoginHeader) {
        return [UIColor colorWithRed:168.0/255.0 green:162.0/255.0 blue:162.0/255.0 alpha:1];
    } else if (scheme == ColorOrderGreyDiv) {
        return [UIColor colorWithRed:175.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1];
    } else if (scheme == ColorOrderWhiteDiv) {
        return [UIColor whiteColor];
    } else if (scheme == ColorDarkGrayTrans) {
        return [UIColor colorWithRed:49.0/255.0 green:49.0/255.0 blue:50.0/255.0 alpha:0.7];
    } else if (scheme == ColorCompleteOrderButton) {
        return [UIColor colorWithRed:82.0/255.0 green:204.0/255.0 blue:239.0/255.0 alpha:1.0];
    } else if (scheme == ColorDivider) {
        return [UIColor colorWithRed:172.0/255.0 green:172.0/255.0 blue:172.0/255.0 alpha:1.0];
    } else if (scheme == ColorError) {
        return [UIColor colorWithRed:103.0/255.0 green:26.0/255.0 blue:17.0/255.0 alpha:1.0];
    } else if (scheme == ColorButtonDisabled) {
        return [UIColor colorWithRed:174.0/255.0 green:176.0/255.0 blue:183.0/255.0 alpha:1.0];
    }
    return nil;
}

+ (BOOL)isBorderDisabled {
    return [InterfacePreferenceHelper readBoolFromDefaults:KEY_BORDER_DISABLED];
}

+ (void)setBorderDisabled:(BOOL)disabled {
    [InterfacePreferenceHelper writeBoolToDefaults:KEY_BORDER_DISABLED value:disabled];
}

+ (CGFloat)getBorderPercent:(CGFloat)borderPercent {
    if ([self isBorderDisabled]) {
        return 0.0f;
    } else {
        return borderPercent;
    }
}

+ (CGFloat)getBorderWidth:(CGFloat)borderPercent onSize:(CGSize)size {
    if ([self isBorderDisabled]) {
        return 0.0f;
    } else {
        if (size.height > size.width) {
            return borderPercent * size.height;
        } else {
            return borderPercent * size.width;
        }
    }
}

+ (UIColor *)getBorderColor {
    NSData *data = (NSData *)[InterfacePreferenceHelper readObjectFromDefaults:KEY_BORDER_COLOR];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        return [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    }
    
}
+ (void)setBorderColor:(UIColor *)borderColor {
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:borderColor];
    [InterfacePreferenceHelper writeObjectToDefaults:KEY_BORDER_COLOR value:data];
}

+ (CGFloat)getCheckoutEditHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 30.0f;
    } else {
        return 25.0f;
    }
}
+ (CGFloat)getCheckoutEditWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 70.0f;
    } else {
        return 55.0f;
    }
}
+ (CGFloat)getCheckoutQuantityPercent {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 0.08f;
    } else {
        return 0.17f;
    }
}

+ (CGFloat)getCheckoutAmountPercent {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 0.10f;
    } else {
        return 0.25f;
    }
}

+ (CGFloat)getCheckoutPadding {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 200.0f;
    } else {
        return 0.0f;
    }
}

+ (CGFloat)getCheckoutSpecialPadding {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 150.0f;
    } else {
        return 0.0f;
    }
}
+ (CGFloat)getLoginFormFieldWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 390.0f;
    } else {
        return 260.0f;
    }
}

+ (CGFloat)getLoginFormFieldHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 60.0f;
    } else {
        return 40.0f;
    }
}

+ (CGFloat)getShippingFontMultiplier {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 1.5f;
    } else {
        return 1.0f;
    }
}
+ (CGFloat)getShippingEditWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 70.0f;
    } else {
        return 50.0f;
    }
}
+ (CGFloat)getShippingListLeftPadding {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 0.15f;
    } else {
        return 0.05f;
    }
}
+ (CGFloat)getShippingListRightPadding {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 0.15f;
    } else {
        return 0.05f;
    }
}

+ (CGFloat)getCartDeletePadding {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 25.0f;
    } else {
        return 15.0f;
    }
}
+ (CGFloat)getCartDeleteSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 40.0f;
    } else {
        return 30.0f;
    }
}
+ (CGFloat)getCartHeaderSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 45.0f;
    } else {
        return 25.0f;
    }
}
+ (CGFloat)getCartPadding {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 100.0f;
    } else {
        return 15.0f;
    }
}

+ (NSInteger)getPicturePreviewSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 480;
    } else {
        return 240;
    }
}
+ (NSInteger)getPictureThumbSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 160;
    } else {
        return 80;
    }
}

+ (CGFloat)getAddressRowHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 100.0f;
    } else {
        return 60.0f;
    }
}

+ (CGFloat)getOrderTotalRowHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 50.0f;
    } else {
        return 45.0f;
    }
}
+ (CGFloat)getCheckoutRowHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 50.0f;
    } else {
        return 35.0f;
    }
}

+ (CGFloat)getCheckoutBlankRowHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 14.0f;
    } else {
        return 7.0f;
    }
}

+ (CGFloat)getCheckoutSpecialRowHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 75.0f;
    } else {
        return 50.0f;
    }
}


+ (CGFloat)getNegativeSpaceDistance {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        return -16;
    else
        return -6;
}

@end
