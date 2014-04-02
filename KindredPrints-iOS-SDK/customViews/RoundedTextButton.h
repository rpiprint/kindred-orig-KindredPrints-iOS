//
//  RoundedTextButton.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/11/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundedTextButton : UIButton

- (id)initWithFrame:(CGRect)frame withStrokeColor:(UIColor *)strokeColor withBaseFillColor:(UIColor *)baseFillColor andPressedFillColor:(UIColor *)pressedFillColor andTextColor:(UIColor *)color andText:(NSString *)title andFontSize:(CGFloat)size;
- (void)drawButtonWithStrokeColor:(UIColor *)strokeColor withBaseFillColor:(UIColor *)baseFillColor andPressedFillColor:(UIColor *)pressedFillColor andTextColor:(UIColor *)color andText:(NSString *)title andFontSize:(CGFloat)size;

@end
