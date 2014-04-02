//
//  SideArrow.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/27/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSInteger SideArrowType;

@interface SideArrow : UIButton

enum SideArrowType {
    LeftSideArrow = 1,
    RightSideArrow = 2
};

- (void)drawSideArrowOfColor:(UIColor *)color andTrans:(CGFloat)trans andArrowType:(SideArrowType)arrowType;

@end
