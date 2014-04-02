//
//  UserPreferenceHelper.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "PreferenceHelper.h"
#import "BaseImage.h"
#import "UserObject.h"
#import "LineItem.h"

static NSString * ORDER_NO_VALUE = @"order_no_value";

@interface UserPreferenceHelper : PreferenceHelper

+ (UserObject *)getUserObject;
+ (void)setUserObject:(UserObject *)user;

+ (NSString *)getOrderTotal;
+ (void)setOrderTotal:(NSString *)orderTotal;

+ (NSString *)getOrderId;
+ (void)setOrderId:(NSString *)orderId;

+ (BOOL)orderIsSame;
+ (void)setOrderIsSame:(BOOL)same;

+ (NSArray *)getOrderLineItems;
+ (void)setOrderLineItems:(NSArray *)lineItems;

+ (void)setSelectedOrders:(NSMutableArray *)orders;
+ (NSMutableArray *)getSelectedOrders;

+ (void)setAllShippingAddresses:(NSMutableArray *)addresses;
+ (NSMutableArray *)getAllAddresses;

+ (void)setSelectedShippingAddresses:(NSMutableArray *)addresses;
+ (NSMutableArray *)getSelectedAddresses;

+ (void)setCartOrders:(NSMutableArray *)orders;
+ (NSMutableArray *)getCartOrders;

@end
