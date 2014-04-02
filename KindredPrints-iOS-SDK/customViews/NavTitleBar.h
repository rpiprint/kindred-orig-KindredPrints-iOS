//
//  NavTitleBar.h
//  KindredPrints
//
//  Created by Alex Austin on 1/5/14.
//  Copyright (c) 2014 Pawprint Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavTitleBar : UIView

@property (strong, nonatomic) NSString *title;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title;

@end
