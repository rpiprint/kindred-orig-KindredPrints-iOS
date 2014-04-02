//
//  UserPreferenceHelper.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "UserPreferenceHelper.h"
#import "InterfacePreferenceHelper.h"
#import "SelectedOrderImage.h"
#import "OrderImage.h"
#import "BaseAddress.h"
#import "OrderManager.h"

@implementation UserPreferenceHelper

static NSString * KEY_ALL_ADDRESSES = @"kp_all_addresses";
static NSString * KEY_CART_ADDRESSES = @"kp_cart_addresses";
static NSString * KEY_CART_ORDERS = @"kp_cart_orders";
static NSString * KEY_ORDER_TOTAL = @"kp_order_total";
static NSString * KEY_SELECTED_ORDERS = @"kp_selected_orders";
static NSString * KEY_CURRENT_ORDER_ID = @"kp_order_id";
static NSString * KEY_CURRENT_ORDER_SAME = @"kp_order_same";
static NSString * KEY_CURRENT_LINE_ITEMS = @"kp_order_line_items";
static NSString * KEY_CURRENT_USER = @"kp_current_user";

+ (NSString *)getOrderId {
    NSString *orderId = (NSString *) [UserPreferenceHelper readObjectFromDefaults:KEY_CURRENT_ORDER_ID];
    if (!orderId) {
        orderId = ORDER_NO_VALUE;
    }
    return orderId;
}
+ (void)setOrderId:(NSString *)orderId {
    [UserPreferenceHelper writeObjectToDefaults:KEY_CURRENT_ORDER_ID value:orderId];
}

+ (BOOL)orderIsSame {
    return [UserPreferenceHelper readBoolFromDefaults:KEY_CURRENT_ORDER_SAME];
}
+ (void)setOrderIsSame:(BOOL)same {
    [UserPreferenceHelper writeBoolToDefaults:KEY_CURRENT_ORDER_SAME value:same];
}

+ (NSArray *)getOrderLineItems {
    NSMutableArray *itemsArray = (NSMutableArray *)[UserPreferenceHelper readObjectFromDefaults:KEY_CURRENT_LINE_ITEMS];
    if (!itemsArray)
        itemsArray = [[NSMutableArray alloc] init];
    NSMutableArray *readableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *item in itemsArray) {
        [readableArray addObject:[[LineItem alloc] initWithPackedLineItem:item]];
    }
    return readableArray;

}
+ (void)setOrderLineItems:(NSArray *)lineItems {
    NSMutableArray *storeableArray = [[NSMutableArray alloc] init];
    for (LineItem *item in lineItems) {
        [storeableArray addObject:[item packLineItem]];
    }
    [UserPreferenceHelper writeObjectToDefaults:KEY_CURRENT_LINE_ITEMS value:storeableArray];
}

+ (UserObject *)getUserObject {
    NSDictionary *userDict = (NSDictionary *)[UserPreferenceHelper readObjectFromDefaults:KEY_CURRENT_USER];
    UserObject *userObj;
    if (!userDict) {
        userObj = [[UserObject alloc] init];
        userObj.uPaymentSaved = NO;
        userObj.uName = USER_VALUE_NONE;
        userObj.uId = USER_VALUE_NONE;
        userObj.uEmail = USER_VALUE_NONE;
    } else {
        userObj = [[UserObject alloc] initWithPackedUser:userDict];
    }
    return userObj;
}
+ (void)setUserObject:(UserObject *)user {
    [UserPreferenceHelper writeObjectToDefaults:KEY_CURRENT_USER value:[user packUser]];
}

+ (NSString *)getOrderTotal {
    NSString *orderId = (NSString *) [UserPreferenceHelper readObjectFromDefaults:KEY_ORDER_TOTAL];
    if (!orderId) {
        orderId = ORDER_NO_VALUE;
    }
    return orderId;
}
+ (void)setOrderTotal:(NSString *)orderTotal {
    [UserPreferenceHelper writeObjectToDefaults:KEY_ORDER_TOTAL value:orderTotal];
}

+ (void)setSelectedOrders:(NSMutableArray *)orders {
    NSMutableArray *storeableArray = [[NSMutableArray alloc] init];
    for (SelectedOrderImage *order in orders) {
        [storeableArray addObject:[order packOrder]];
    }
    [UserPreferenceHelper writeObjectToDefaults:KEY_SELECTED_ORDERS value:storeableArray];
}
+ (NSMutableArray *)getSelectedOrders {
    NSMutableArray *ordersArray = (NSMutableArray *)[UserPreferenceHelper readObjectFromDefaults:KEY_SELECTED_ORDERS];
    if (!ordersArray)
        ordersArray = [[NSMutableArray alloc] init];
    NSMutableArray *readableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *order in ordersArray) {
        [readableArray addObject:[[SelectedOrderImage alloc] initWithPackedOrder:order]];
    }
    return readableArray;
}
+ (void)setAllShippingAddresses:(NSMutableArray *)addresses {
    NSMutableArray *storeableArray = [[NSMutableArray alloc] init];
    for (BaseAddress *address in addresses) {
        [storeableArray addObject:[address packAddress]];
    }
    [UserPreferenceHelper writeObjectToDefaults:KEY_ALL_ADDRESSES value:storeableArray];
}
+ (NSMutableArray *)getAllAddresses {
    NSMutableArray *addressArray = (NSMutableArray *)[UserPreferenceHelper readObjectFromDefaults:KEY_ALL_ADDRESSES];
    if (!addressArray)
        addressArray = [[NSMutableArray alloc] init];
    NSMutableArray *readableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *address in addressArray) {
        [readableArray addObject:[[BaseAddress alloc] initWithPackedAddress:address]];
    }
    return readableArray;
}
+ (void)setSelectedShippingAddresses:(NSMutableArray *)addresses {
    NSMutableArray *storeableArray = [[NSMutableArray alloc] init];
    for (BaseAddress *address in addresses) {
        [storeableArray addObject:[address packAddress]];
    }
    [UserPreferenceHelper writeObjectToDefaults:KEY_CART_ADDRESSES value:storeableArray];
}
+ (NSMutableArray *)getSelectedAddresses {
    NSMutableArray *addressArray = (NSMutableArray *)[UserPreferenceHelper readObjectFromDefaults:KEY_CART_ADDRESSES];
    if (!addressArray)
        addressArray = [[NSMutableArray alloc] init];
    NSMutableArray *readableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *address in addressArray) {
        [readableArray addObject:[[BaseAddress alloc] initWithPackedAddress:address]];
    }
    return readableArray;
}
+ (void)setCartOrders:(NSMutableArray *)orders {
    NSMutableArray *storeableArray = [[NSMutableArray alloc] init];
    for (OrderImage *order in orders) {
        [storeableArray addObject:[order packOrder]];
    }
    [UserPreferenceHelper writeObjectToDefaults:KEY_CART_ORDERS value:storeableArray];
}
+ (NSMutableArray *)getCartOrders {
    NSMutableArray *ordersArray = (NSMutableArray *)[UserPreferenceHelper readObjectFromDefaults:KEY_CART_ORDERS];
    if (!ordersArray)
        ordersArray = [[NSMutableArray alloc] init];
    NSMutableArray *readableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *order in ordersArray) {
        [readableArray addObject:[[OrderImage alloc] initWithPackedOrder:order]];
    }
    return readableArray;

}

@end
