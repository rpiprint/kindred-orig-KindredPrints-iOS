//
//  OrderTotalView.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/5/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "OrderTotalView.h"
#import "InterfacePreferenceHelper.h"

@interface OrderTotalView()

@property (strong, nonatomic) UILabel *orderTotalView;
@property (nonatomic) NSInteger ypos;
@property (nonatomic) NSInteger height;

@end

@implementation OrderTotalView

static CGFloat ORDER_TOTAL_PERC = 0.28;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = frame.size.height;
        self.ypos = frame.origin.y;
        
        self.orderTotalView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*ORDER_TOTAL_PERC,self.height)];
        [self.orderTotalView setTextColor:[UIColor whiteColor]];
        [self.orderTotalView setBackgroundColor:[InterfacePreferenceHelper getColor:ColorOrderTotal]];
        [self.orderTotalView setFont:[UIFont fontWithName:FONT_HEAVY size:PricingFontSize]];
        [self.orderTotalView setTextAlignment:NSTextAlignmentCenter];
        
        UIView *totalBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*(1-ORDER_TOTAL_PERC), 0, frame.size.width*ORDER_TOTAL_PERC, self.height)];
        [totalBackgroundView setBackgroundColor:[InterfacePreferenceHelper getColor:ColorOrderTotal]];
        [totalBackgroundView addSubview:self.orderTotalView];

        UILabel *viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*(1-ORDER_TOTAL_PERC)-5, self.height)];
        [viewLabel setText:@"Subtotal:"];
        [viewLabel setTextColor:[UIColor whiteColor]];
        [viewLabel setBackgroundColor:[UIColor clearColor]];
        [viewLabel setTextAlignment:NSTextAlignmentRight];
        [viewLabel setFont:[UIFont fontWithName:FONT_LIGHT size:MenuButtonFontSize]];
        
        [self addSubview:viewLabel];
        [self addSubview:totalBackgroundView];
        [self setBackgroundColor:[InterfacePreferenceHelper getColor:ColorOrderTotalLabel]];
        
        self.hidden = YES;
        
    }
    return self;
}

- (void)setOrderTotal:(NSInteger)orderTotal {
    _orderTotal = orderTotal;
    NSString *orderTotString = @"$0";
    if (orderTotal) {
        orderTotString = [NSString stringWithFormat:@"$%.2f", ((CGFloat)orderTotal)/100.0];
    }
    [self.orderTotalView setText:orderTotString];
    if (orderTotal > 0 && self.hidden) {
        [self show];
    } else if (orderTotal == 0 && !self.hidden) {
        [self hide];
    }
}

- (void)show {
    [UIView beginAnimations:@"show" context:nil];
    [UIView setAnimationDuration:0.25];
    
    CGRect newSize = self.frame;
    newSize.origin.y = self.ypos - self.height;
    self.frame = newSize;
    
    [UIView commitAnimations];
    
    self.hidden = NO;
}

- (void)hide {
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(aniDone:finished:context:)];

    CGRect newSize = self.frame;
    newSize.origin.y = self.ypos;
    self.frame = newSize;
    
    [UIView commitAnimations];
}

- (void)aniDone:(NSString *)aniID finished:(BOOL)finished context:(void *)context {
    if ([aniID isEqualToString:@"hide"])
        self.hidden = YES;
}


@end
