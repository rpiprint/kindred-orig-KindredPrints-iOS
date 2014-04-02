//
//  CircularButton.h
//  KindredPrints
//
//  Created by Alex Austin on 1/5/14.
//  Copyright (c) 2014 Pawprint Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSInteger CircleButtonType;

@interface CircularButton : UIButton

enum CircleButtonType {
    MinusButton = 1,
    PlusButton = 2,
    DeleteButton = 3
};

- (void)drawCircleButtonWithPressedFillColor:(UIColor *)pressedColor andBasecolor:(UIColor *)baseColor andInnerStrokeColor:(UIColor *)innerStrokeColor andOuterStrokeColor:(UIColor *)outerStrokeColor andButtonType:(CircleButtonType)buttonType;

@end
