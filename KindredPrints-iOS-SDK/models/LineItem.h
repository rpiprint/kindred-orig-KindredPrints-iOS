//
//  LineItem.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/21/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *LINE_ITEM_NO_VALUE = @"no_value";
static NSString *LINE_ITEM_TYPE_PRODUCT = @"lineitem";
static NSString *LINE_ITEM_TYPE_SUBTOTAL = @"subtotal";
static NSString *LINE_ITEM_TYPE_SHIPPING = @"shipping";
static NSString *LINE_ITEM_TYPE_CREDITS = @"credits";
static NSString *LINE_ITEM_TYPE_COUPON = @"coupon";
static NSString *LINE_ITEM_TYPE_TOTAL = @"total";

@interface LineItem : NSObject

@property (nonatomic, assign) NSString *liType;
@property (nonatomic, assign) NSString *liName;
@property (nonatomic, assign) NSString *liAmount;
@property (nonatomic, assign) NSInteger liQuantity;
@property (nonatomic, assign) NSString *liAddressId;
@property (nonatomic, assign) NSString *liShipMethod;
@property (nonatomic, assign) NSString *liCouponId;

- (LineItem *) initWithType:(NSString *)type;
- (LineItem *) initWithPackedLineItem:(NSDictionary *)savedObject;
- (NSDictionary *) packLineItem;

@end
