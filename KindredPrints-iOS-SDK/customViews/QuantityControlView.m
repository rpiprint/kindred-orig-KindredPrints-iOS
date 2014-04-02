//
//  QuantityControlView.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/3/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "QuantityControlView.h"
#import "CircularButton.h"
#import "InterfacePreferenceHelper.h"

@interface QuantityControlView()

@property (strong, nonatomic) UILabel *txtQuantity;
@property (strong, nonatomic) CircularButton *cmdPlus;
@property (strong, nonatomic) CircularButton *cmdMinus;

@end

@implementation QuantityControlView

static CGFloat PADDING_PERC = 0.9;

- (id)initWithFrame:(CGRect)frame andQuantity:(NSInteger)quantity
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = frame.size.width/3;
        CGFloat height = frame.size.height;
        CGFloat paddingStart = (1-PADDING_PERC)*width/2;
        self.cmdMinus = [[CircularButton alloc] initWithFrame:CGRectMake(paddingStart, paddingStart, width*PADDING_PERC, height*PADDING_PERC)];
        [self.cmdMinus drawCircleButtonWithPressedFillColor:[UIColor whiteColor] andBasecolor:[UIColor clearColor] andInnerStrokeColor:[UIColor whiteColor] andOuterStrokeColor:[UIColor whiteColor] andButtonType:MinusButton];
        [self.cmdMinus addTarget:self action:@selector(subFromQuantity) forControlEvents:UIControlEventTouchUpInside];
        
        self.cmdPlus = [[CircularButton alloc] initWithFrame:CGRectMake(2*width + paddingStart, paddingStart, width*PADDING_PERC, height*PADDING_PERC)];
        [self.cmdPlus drawCircleButtonWithPressedFillColor:[UIColor whiteColor] andBasecolor:[UIColor clearColor]  andInnerStrokeColor:[UIColor whiteColor] andOuterStrokeColor:[UIColor whiteColor] andButtonType:PlusButton];
        [self.cmdPlus addTarget:self action:@selector(addToQuantity) forControlEvents:UIControlEventTouchUpInside];
        
        self.txtQuantity = [[UILabel alloc] initWithFrame:CGRectMake(width + paddingStart, 0, width*PADDING_PERC, height)];
        [self.txtQuantity setBackgroundColor:[UIColor clearColor]];
        [self.txtQuantity setTextAlignment:NSTextAlignmentCenter];
        [self.txtQuantity setFont:[UIFont fontWithName:FONT_HEAVY size:QuantityFontSize]];
        [self.txtQuantity setTextColor:[UIColor whiteColor]];
        self.quantity = quantity;
        
        [self addSubview:self.cmdMinus];
        [self addSubview:self.cmdPlus];
        [self addSubview:self.txtQuantity];
    }
    return self;
}

- (void)addToQuantity {
    self.quantity++;
    if (self.delegate) [self.delegate updatedQuantity:self.quantity];
}

- (void)subFromQuantity {
    self.quantity = MAX(0, self.quantity-1);
    if (self.delegate) [self.delegate updatedQuantity:self.quantity];
}

- (void)setQuantity:(NSInteger)quantity {
    _quantity = quantity;
    if (quantity == 0) {
        [self.cmdMinus setEnabled:NO];
    } else {
        [self.cmdMinus setEnabled:YES];
    }
    [self.txtQuantity setText:[NSString stringWithFormat:@"%ld", (long)quantity]];
}

@end
