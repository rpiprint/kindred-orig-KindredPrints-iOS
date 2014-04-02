//
//  OrderProcessingHelper.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OrderProcessingDelegate <NSObject>

@optional
- (void)orderProcessingUpdateProgress:(CGFloat)progress withStatus:(NSString *)message;
- (void)orderFailedToProcess:(NSString *)error;
- (void)orderCreatedAndReturnedLineItems:(NSArray *)lineItems;
- (void)paymentProcessed;
@end


@interface OrderProcessingHelper : NSObject

- (void) initiateOrderCreateOrUpdateSequence;
- (void) initiateCheckoutSequence;

@property (nonatomic, strong) id <OrderProcessingDelegate> delegate;

@end
