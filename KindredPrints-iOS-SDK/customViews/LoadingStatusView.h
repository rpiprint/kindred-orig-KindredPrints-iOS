//
//  CheckoutStatusCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger const KP_STATUS_STATE_PROCESSING = 0;
static NSInteger const KP_STATUS_STATE_ERROR = 1;
static NSInteger const KP_STATUS_STATE_HIDDEN = 2;
static NSInteger const KP_STATUS_STATE_RETRY = 3;

@protocol LoadingStatusViewDelegate <NSObject>

@optional
- (void)clickedButtonAtState:(NSInteger)state;
@end

@interface LoadingStatusView : UIView

@property (nonatomic, strong) id <LoadingStatusViewDelegate> delegate;

- (void) updateStatusCellWithMessage:(NSString *)message andProgress:(CGFloat)progress;
- (void) setState:(NSInteger)state;
- (void) hide;
- (void) show;

@end
