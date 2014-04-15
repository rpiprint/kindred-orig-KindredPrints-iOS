//
//  CheckoutStatusCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "LoadingStatusView.h"
#import "InterfacePreferenceHelper.h"
#import "RoundedTextButton.h"

@interface LoadingStatusView()

@property (strong, nonatomic) UILabel *txtMessage;
@property (strong, nonatomic) UIProgressView *progBar;
@property (strong, nonatomic) RoundedTextButton *cmdCancel;
@property (nonatomic) NSInteger currState;

@end

@implementation LoadingStatusView

static NSInteger PADDING = 25;
static NSInteger CANCEL_BUTTON_WIDTH = 100;
static NSInteger CANCEL_BUTTON_HEIGHT = 35;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.7f]];
        
        self.progBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGRect progFrame = self.progBar.frame;
        progFrame.origin.x = PADDING;
        progFrame.size.width = frame.size.width-2*PADDING;
        progFrame.origin.y = (frame.size.height-progFrame.size.height)/2;
        self.progBar.frame = progFrame;
        
        self.txtMessage = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, progFrame.origin.y-MenuButtonFontSize*3, frame.size.width-2*PADDING, MenuButtonFontSize*3)];
        [self.txtMessage setBackgroundColor:[UIColor clearColor]];
        [self.txtMessage setTextAlignment:NSTextAlignmentCenter];
        [self.txtMessage setNumberOfLines:2];
        [self.txtMessage setTextColor:[UIColor whiteColor]];
        [self.txtMessage setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
 
        self.cmdCancel = [[RoundedTextButton alloc] initWithFrame:CGRectMake((frame.size.width-CANCEL_BUTTON_WIDTH)/2, progFrame.origin.y + progFrame.size.height+PADDING, CANCEL_BUTTON_WIDTH, CANCEL_BUTTON_HEIGHT)];
        [self.cmdCancel drawButtonWithStrokeColor:[UIColor whiteColor] withBaseFillColor:[UIColor clearColor] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"CANCEL" andFontSize:MenuButtonFontSize];
        [self.cmdCancel addTarget:self action:@selector(cmdCancelClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.cmdCancel];
        [self addSubview:self.txtMessage];
        [self addSubview:self.progBar];
    }
    return self;
}

- (void) updateStatusCellWithMessage:(NSString *)message andProgress:(CGFloat)progress {
    [self.txtMessage setText:message];
    [self.progBar setProgress:progress animated:YES];
}

- (void) setState:(NSInteger)state {
    self.currState = state;
    if (state == KP_STATUS_STATE_PROCESSING) {
        [self.cmdCancel setTextForTitle:@"CANCEL"];
        [self.progBar setHidden:NO];
        [self.txtMessage setHidden:NO];
        [self.txtMessage setTextColor:[UIColor whiteColor]];
    } else if (state == KP_STATUS_STATE_ERROR) {
        [self.cmdCancel setTextForTitle:@"OK"];
        [self.progBar setHidden:YES];
        [self.txtMessage setHidden:NO];
        [self.txtMessage setTextColor:[UIColor redColor]];
    } else if (state == KP_STATUS_STATE_RETRY) {
        [self.progBar setHidden:YES];
        [self.cmdCancel setTextForTitle:@"RETRY"];
        [self.txtMessage setHidden:NO];
        [self.txtMessage setTextColor:[UIColor redColor]];
    } else {
        [self.progBar setHidden:YES];
        [self.txtMessage setHidden:YES];
    }
}

- (void) cmdCancelClicked {
    [self hide];
    if (self.delegate) [self.delegate clickedButtonAtState:self.currState];
}

- (void) hide {
    [self setHidden:YES];
}

- (void) show {
    [self setHidden:NO];
}

@end
