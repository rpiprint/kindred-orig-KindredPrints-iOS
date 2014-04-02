//
//  CircularButton.m
//  KindredPrints
//
//  Created by Alex Austin on 1/5/14.
//  Copyright (c) 2014 Pawprint Labs, Inc. All rights reserved.
//

#import "CircularButton.h"
#import "PreferenceHelper.h"
#import "InterfacePreferenceHelper.h"

@interface CircularButton()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (strong, nonatomic) UIColor *baseColor;
@property (strong, nonatomic) UIColor *pressedColor;
@property (strong, nonatomic) UIColor *outerStrokeColor;
@property (strong, nonatomic) UIColor *innerStrokeColor;

@end

@implementation CircularButton

static CGFloat PERCENTAGE_OF_SIDE = 0.5;

- (void)drawCircleButtonWithPressedFillColor:(UIColor *)pressedColor andBasecolor:(UIColor *)baseColor andInnerStrokeColor:(UIColor *)innerStrokeColor andOuterStrokeColor:(UIColor *)outerStrokeColor andButtonType:(CircleButtonType)buttonType {
    self.baseColor = baseColor;
    self.pressedColor = pressedColor;
    self.outerStrokeColor = outerStrokeColor;
    self.innerStrokeColor = innerStrokeColor;
    
    CGFloat height = [self bounds].size.height;
    CGFloat width = [self bounds].size.width;
    
    self.circleLayer = [CAShapeLayer layer];
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f, width, height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.circleLayer setPath:[path CGPath]];
    [self.circleLayer setFillColor:self.baseColor.CGColor];
    [self.circleLayer setStrokeColor:[self.outerStrokeColor CGColor]];
    [self.circleLayer setLineWidth:1.0f];
    
    CAShapeLayer *opSymbol;
    if (buttonType == PlusButton)
        opSymbol = [self generatePlus];
    else if (buttonType == MinusButton)
        opSymbol = [self generateMinus];
    else
        opSymbol = [self generateCross];
    [opSymbol setStrokeColor:[self.innerStrokeColor CGColor]];
    [opSymbol setLineWidth:1.0f];
    
    [[self layer] addSublayer:self.circleLayer];
    [[self layer] addSublayer:opSymbol];
    
}

- (CAShapeLayer *)generateCross {
    CGFloat height = [self bounds].size.height;
    CGFloat width = [self bounds].size.width;
    
    CAShapeLayer *cross = [CAShapeLayer layer];
    [cross setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width, [self bounds].size.height)];
    [cross setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat xStep = (PERCENTAGE_OF_SIDE*width/2)*sqrtf(2)/2;
    [path moveToPoint:CGPointMake(width/2-xStep, height/2-xStep)];
    [path addLineToPoint:CGPointMake(width/2+xStep, height/2+xStep)];
    [path moveToPoint:CGPointMake(width/2-xStep, height/2+xStep)];
    [path addLineToPoint:CGPointMake(width/2+xStep,height/2-xStep)];
    
    [cross setPath:[path CGPath]];
    
    return cross;
}

- (CAShapeLayer *)generatePlus {
    CGFloat height = [self bounds].size.height;
    CGFloat width = [self bounds].size.width;
    
    CAShapeLayer *plus = [CAShapeLayer layer];
    [plus setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width, [self bounds].size.height)];
    [plus setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake((1-PERCENTAGE_OF_SIDE)*width/2, height/2)];
    [path addLineToPoint:CGPointMake(PERCENTAGE_OF_SIDE*width+(1-PERCENTAGE_OF_SIDE)*width/2, height/2)];
    [path moveToPoint:CGPointMake(width/2, (1-PERCENTAGE_OF_SIDE)*height/2)];
    [path addLineToPoint:CGPointMake(width/2,PERCENTAGE_OF_SIDE*height+(1-PERCENTAGE_OF_SIDE)*height/2)];

    [plus setPath:[path CGPath]];
    
    return plus;
}

- (CAShapeLayer *)generateMinus {
    CGFloat height = [self bounds].size.height;
    CGFloat width = [self bounds].size.width;
    
    CAShapeLayer *minus = [CAShapeLayer layer];
    [minus setBounds:CGRectMake(0.0f, 0.0f, width, height)];
    [minus setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake((1-PERCENTAGE_OF_SIDE)*width/2, height/2)];
    [path addLineToPoint:CGPointMake(PERCENTAGE_OF_SIDE*width+(1-PERCENTAGE_OF_SIDE)*width/2, height/2)];
    [minus setPath:[path CGPath]];
    
    return minus;
}

- (void)setEnabled:(BOOL)enabled {
    if (!enabled) {
        for (CAShapeLayer *layer in self.layer.sublayers) {
            [layer setStrokeColor:[InterfacePreferenceHelper getColor:ColorButtonDisabled].CGColor];
        }
    } else {
        for (CAShapeLayer *layer in self.layer.sublayers) {
            [layer setStrokeColor:self.outerStrokeColor.CGColor];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted)
    {
        [self.circleLayer setFillColor:self.pressedColor.CGColor];
    }
    else
    {
        [self.circleLayer setFillColor:self.baseColor.CGColor];
    }
}

@end
