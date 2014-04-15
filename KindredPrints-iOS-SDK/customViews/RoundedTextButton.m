//
//  RoundedTextButton.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/11/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "RoundedTextButton.h"
#import "InterfacePreferenceHelper.h"

@interface RoundedTextButton()

@property (strong, nonatomic) CAShapeLayer *buttonLayer;
@property (strong, nonatomic) UIColor *baseFillColor;
@property (strong, nonatomic) UIColor *pressedFillColor;
@property (strong, nonatomic) UILabel *txtTitle;

@end

@implementation RoundedTextButton

static CGFloat ROUNDED_CORNER_RADIUS = 10;

- (id)initWithFrame:(CGRect)frame withStrokeColor:(UIColor *)strokeColor withBaseFillColor:(UIColor *)baseFillColor andPressedFillColor:(UIColor *)pressedFillColor andTextColor:(UIColor *)color andText:(NSString *)title andFontSize:(CGFloat)size {
    self = [super initWithFrame:frame];
    if (self) {
        [self drawButtonWithStrokeColor:strokeColor withBaseFillColor:baseFillColor andPressedFillColor:pressedFillColor andTextColor:color andText:title andFontSize:size];
    }
    return self;
}

- (void)drawButtonWithStrokeColor:(UIColor *)strokeColor withBaseFillColor:(UIColor *)baseFillColor andPressedFillColor:(UIColor *)pressedFillColor andTextColor:(UIColor *)color andText:(NSString *)title andFontSize:(CGFloat)size {
    [self setBackgroundColor:[UIColor clearColor]];
    self.baseFillColor = baseFillColor;
    self.pressedFillColor = pressedFillColor;
    
    if (self.buttonLayer) {
        [self.buttonLayer removeFromSuperlayer];
    }
    self.buttonLayer = [CAShapeLayer layer];
    
    CGFloat height = [self bounds].size.height;
    CGFloat width = [self bounds].size.width;
    
    [self.buttonLayer setBounds:CGRectMake(0.0f, 0.0f, width, height)];
    [self.buttonLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) cornerRadius:ROUNDED_CORNER_RADIUS];
    [self.buttonLayer setPath:[path CGPath]];
    [self.buttonLayer setFillColor:self.baseFillColor.CGColor];
    [self.buttonLayer setStrokeColor:[strokeColor CGColor]];
    [self.buttonLayer setLineWidth:1.0f];
    
    self.txtTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.txtTitle setBackgroundColor:[UIColor clearColor]];
    [self.txtTitle setTextAlignment:NSTextAlignmentCenter];
    [self.txtTitle setTextColor:color];
    [self.txtTitle setFont:[UIFont fontWithName:FONT_REGULAR size:size]];
    [self.txtTitle setText:title];
    
    [self.layer addSublayer:self.buttonLayer];
    [self addSubview:self.txtTitle];
}

- (void)setTextForTitle:(NSString *)title {
    [self.txtTitle setText:title];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted)
    {
        [self.buttonLayer setFillColor:[self.pressedFillColor CGColor]];
    }
    else
    {
        [self.buttonLayer setFillColor:[self.baseFillColor CGColor]];
    }
}


@end
