//
//  CircularCheckbox.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/8/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "CircularCheckbox.h"

@interface CircularCheckbox()

@property (strong, nonatomic) CAShapeLayer *baseLayer;
@property (strong ,nonatomic) CAShapeLayer *checkMarkLayer;
@property (strong, nonatomic) UIColor *checkedColor;
@property (strong, nonatomic) UIColor *uncheckedColor;
@property (strong, nonatomic) UIColor *innerStrokeColor;
@property (strong, nonatomic) UIColor *outerStrokeColor;

@end

@implementation CircularCheckbox

static CGFloat PERCENTAGE_OF_SIDE = 0.55f;
static CGFloat PERCENTAGE_OF_LONG_SIDE = 0.35f;
static CGFloat START_X = 0.4f;
static CGFloat START_Y = 0.7f;

- (void) drawCircleCheckboxWithCheckedFillColor:(UIColor *)checkedColor andOuterStrokeColor:(UIColor *)strokeColor andInnerStrokeColor:(UIColor *)innerStrokeColor {
    self.checkedColor = checkedColor;
    self.uncheckedColor = [UIColor clearColor];
    self.outerStrokeColor = strokeColor;
    self.innerStrokeColor = innerStrokeColor;
    
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    
    self.baseLayer = [CAShapeLayer layer];
    [self.baseLayer setBounds:CGRectMake(0.0f, 0.0f, width, height)];
    [self.baseLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.baseLayer setPath:[path CGPath]];
    [self.baseLayer setFillColor:[self.uncheckedColor CGColor]];
    [self.baseLayer setStrokeColor:[self.outerStrokeColor CGColor]];
    [self.baseLayer setLineWidth:1.0f];

    self.checkMarkLayer = [CAShapeLayer layer];
    [self.checkMarkLayer setBounds:CGRectMake(0.0f, 0.0f, width, height)];
    [self.checkMarkLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    path = [[UIBezierPath alloc] init];
    CGFloat xStart = START_X*width;
    CGFloat yStart = START_Y*height;
    CGFloat longSide = PERCENTAGE_OF_SIDE*width;
    CGFloat shortSide = PERCENTAGE_OF_LONG_SIDE*longSide;
    CGFloat cos45 = sqrtf(2)/2;

    path = [[UIBezierPath alloc] init];
    //[path moveToPoint:CGPointMake(xStart, yStart)];
    [path moveToPoint:CGPointMake(xStart-shortSide*cos45, yStart-shortSide*cos45)];
    [path addLineToPoint:CGPointMake(xStart, yStart)];
    [path addLineToPoint:CGPointMake(xStart+longSide*cos45, yStart-longSide*cos45)];
    [self.checkMarkLayer setPath:[path CGPath]];
    [self.checkMarkLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.checkMarkLayer setStrokeColor:[self.innerStrokeColor CGColor]];
    [self.checkMarkLayer setLineWidth:2.0f];

    [self.baseLayer addSublayer:self.checkMarkLayer];
    
    [[self layer] addSublayer:self.baseLayer];
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        [self.baseLayer setFillColor:[self.checkedColor CGColor]];
        [self.checkMarkLayer setStrokeColor:[self.innerStrokeColor CGColor]];
    } else {
        [self.baseLayer setFillColor:[self.uncheckedColor CGColor]];
        [self.checkMarkLayer setStrokeColor:[[UIColor clearColor] CGColor]];
    }
}

@end
