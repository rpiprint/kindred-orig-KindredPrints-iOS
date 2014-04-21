//
//  NavButton.m
//  KindredPrints
//
//  Created by Alex Austin on 1/5/14.
//  Copyright (c) 2014 Pawprint Labs, Inc. All rights reserved.
//

#import "NavButton.h"
#import "InterfacePreferenceHelper.h"
#import "SideArrow.h"

@implementation NavButton

static CGFloat IMAGE_PERCENTAGE = 0.65f;

- (id)initBackButtonWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            self.button = [UIButton buttonWithType:UIButtonTypeSystem];
        } else {
            self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        }

        [self.button setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.button setBackgroundColor:[UIColor clearColor]];

        SideArrow *leftArrow = [[SideArrow alloc] initWithFrame:CGRectMake(frame.size.width*(1-IMAGE_PERCENTAGE)/2, frame.size.height*(1-IMAGE_PERCENTAGE)/2, IMAGE_PERCENTAGE*frame.size.width, IMAGE_PERCENTAGE*frame.size.height)];
        [leftArrow drawSideArrowOfColor:[UIColor whiteColor] andTrans:1.0f andArrowType:LeftSideArrow];
        
        [self addSubview:leftArrow];
        [self addSubview:self.button];
    }
    return self;
}

- (id)initForwardButtonWithFrame:(CGRect)frame andText:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            self.button = [UIButton buttonWithType:UIButtonTypeSystem];
        } else {
            self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        }
        
        [self.button setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.button setBackgroundColor:[UIColor clearColor]];
        [self.button setTitle:title forState:UIControlStateNormal];
        [self.button setTitleColor:[InterfacePreferenceHelper getColor:ColorNavBarNextButton] forState:UIControlStateNormal];
        [self.button.titleLabel setFont:[UIFont fontWithName:FONT_LIGHT size:MenuButtonFontSize]];
        
        [self addSubview:self.button];
    }
    return self;
}

- (void) setEnabled {
    [self.button setEnabled:YES];
    [self.button setTitleColor:[InterfacePreferenceHelper getColor:ColorNavBarNextButton] forState:UIControlStateNormal];
}
- (void) setDisabled {
    [self.button setEnabled:YES];
    [self.button setTitleColor:[InterfacePreferenceHelper getColor:ColorOrderGreyDiv] forState:UIControlStateNormal];
}

@end
