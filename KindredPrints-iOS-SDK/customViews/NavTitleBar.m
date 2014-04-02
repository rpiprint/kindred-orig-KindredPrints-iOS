//
//  NavTitleBar.m
//  KindredPrints
//
//  Created by Alex Austin on 1/5/14.
//  Copyright (c) 2014 Pawprint Labs, Inc. All rights reserved.
//

#import "NavTitleBar.h"
#import "InterfacePreferenceHelper.h"

@interface NavTitleBar()

@property (strong, nonatomic) UILabel *txtTitle;

@end

@implementation NavTitleBar

- (void)setTitle:(NSString *)title {
    [self.txtTitle setText:title];
    _title = title;
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.txtTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.txtTitle setBackgroundColor:[UIColor clearColor]];
        self.title = title;
        [self.txtTitle setNumberOfLines:1];
        [self.txtTitle setTextColor:[UIColor whiteColor]];
        [self.txtTitle setTextAlignment:NSTextAlignmentCenter];
        [self.txtTitle setFont:[UIFont fontWithName:FONT_HEAVY size:MenuButtonFontSize]];

        [self addSubview:self.txtTitle];
    }
    return self;
}


@end
