//
//  SideArrow.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/27/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "SideArrow.h"

@interface SideArrow()

@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (strong, nonatomic) UIColor *baseColor;

@end

@implementation SideArrow

static CGFloat LINE_THICKNESS = 0.08f;
static CGFloat DIAMETER_PERCENT = 0.4f;

- (void)drawSideArrowOfColor:(UIColor *)color andTrans:(CGFloat)trans andArrowType:(SideArrowType)arrowType {
    self.baseColor = color;
    
    
    CGFloat height = [self bounds].size.height;
    CGFloat width = [self bounds].size.width;
        
    int orient = 1;
    if (arrowType == RightSideArrow)
        orient = -1;
    
    CGFloat side = width * DIAMETER_PERCENT;
    CGFloat halfSide = sqrt(2)*side/2;
    
    self.arrowLayer = [CAShapeLayer layer];
    [self.arrowLayer setBounds:CGRectMake(0.0f, 0.0f, width, height)];
    [self.arrowLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(width/2+orient*halfSide/2, height/2-halfSide)];
    [path addLineToPoint:CGPointMake(width/2-orient*halfSide/2, height/2)];
    [path addLineToPoint:CGPointMake(width/2+orient*halfSide/2,height/2+halfSide)];
    
    [self.arrowLayer setPath:[path CGPath]];
    [self.arrowLayer setFillColor:[UIColor clearColor].CGColor];
    [self.arrowLayer setStrokeColor:[self.baseColor CGColor]];
    [self.arrowLayer setLineWidth:LINE_THICKNESS * width];
    [self.arrowLayer setOpacity:trans];
    
    [[self layer] addSublayer:self.arrowLayer];
}

@end
