//
//  CircularCheckbox.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/8/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularCheckbox : UIButton

- (void) drawCircleCheckboxWithCheckedFillColor:(UIColor *)checkedColor andOuterStrokeColor:(UIColor *)strokeColor andInnerStrokeColor:(UIColor *)innerStrokeColor;

@property (nonatomic) BOOL selected;

@end
