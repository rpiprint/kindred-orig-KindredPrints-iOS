//
//  BackgroundGradientHelper.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/3/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "BackgroundGradientHelper.h"

@implementation BackgroundGradientHelper

+ (CAGradientLayer *) GetBackgroundBaseGradient {
    UIColor *colorOne = [UIColor colorWithRed:85.0/255.0 green:87.0/255.0 blue:88.0/255.0 alpha:1];
    UIColor *colorTwo = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1];
    UIColor *colorThree = [UIColor colorWithRed:123.0/255.0 green:124.0/255.0 blue:133.0/255.0 alpha:1];
    UIColor *colorFour = [UIColor colorWithRed:149.0/255.0 green:159.0/255.0 blue:165.0/255.0 alpha:1];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, (id)colorThree.CGColor, (id)colorFour.CGColor, nil];
    
    NSNumber *stop1 = [NSNumber numberWithFloat:0.0];
    NSNumber *stop2 = [NSNumber numberWithFloat:0.45];
    NSNumber *stop3 = [NSNumber numberWithFloat:0.71];
    NSNumber *stop4 = [NSNumber numberWithFloat:1.0];
    NSArray *locations = [NSArray arrayWithObjects:stop1, stop2, stop3, stop4, nil];
    
    CAGradientLayer *bottomLayer = [CAGradientLayer layer];
    bottomLayer.colors = colors;
    bottomLayer.locations = locations;
    bottomLayer.startPoint = CGPointMake(0.5, 0.0);
    bottomLayer.endPoint = CGPointMake(0.5, 1.0);
    
    return bottomLayer;
}


+ (CAGradientLayer *) GetBackgroundMidGradient {
    UIColor *colorOne = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.1];
    UIColor *colorTwo = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.0];
    UIColor *colorThree = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.1];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, (id)colorThree.CGColor, nil];
    
    NSNumber *stop1 = [NSNumber numberWithFloat:0.0];
    NSNumber *stop2 = [NSNumber numberWithFloat:0.5];
    NSNumber *stop3 = [NSNumber numberWithFloat:1.0];
    NSArray *locations = [NSArray arrayWithObjects:stop1, stop2, stop3, nil];
    
    CAGradientLayer *midLayer = [CAGradientLayer layer];
    midLayer.colors = colors;
    midLayer.locations = locations;
    midLayer.startPoint = CGPointMake(0.5, 0.0);
    midLayer.endPoint = CGPointMake(0.5, 1.0);

    return midLayer;
}
+ (CAGradientLayer *) GetBackgroundTopGradient {
    UIColor *colorOne = [UIColor colorWithRed:121.0/255.0 green:123.0/255.0 blue:133.0/255.0 alpha:1];
    UIColor *colorTwo = [UIColor colorWithRed:136.0/255.0 green:104.0/255.0 blue:107.0/255.0 alpha:1];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
    NSNumber *stop1 = [NSNumber numberWithFloat:0.0];
    NSNumber *stop2 = [NSNumber numberWithFloat:1.0];
    NSArray *locations = [NSArray arrayWithObjects:stop1, stop2, nil];
    
    CAGradientLayer *topLayer = [CAGradientLayer layer];
    topLayer.colors = colors;
    topLayer.locations = locations;
    topLayer.startPoint = CGPointMake(440.0/640.0, 290.0/1136.0);
    topLayer.endPoint = CGPointMake(250.0/640.0, 730.0/1136.0);
    [topLayer setOpacity:0.35];
    
    return topLayer;
}

@end
