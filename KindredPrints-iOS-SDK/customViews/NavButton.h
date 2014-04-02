//
//  NavButton.h
//  KindredPrints
//
//  Created by Alex Austin on 1/5/14.
//  Copyright (c) 2014 Pawprint Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavButton : UIView

@property (strong, nonatomic) UIButton *button;

- (id)initBackButtonWithFrame:(CGRect)frame;
- (id)initForwardButtonWithFrame:(CGRect)frame andText:(NSString *)title;

@end
