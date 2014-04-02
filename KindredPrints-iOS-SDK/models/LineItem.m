//
//  LineItem.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/21/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "LineItem.h"

static NSString *LI_TYPE = @"type";
static NSString *LI_SHIPMETHOD = @"ship_method";
static NSString *LI_QUANTITY = @"quantity";
static NSString *LI_NAME = @"name";
static NSString *LI_COUPON_ID = @"coupon_id";
static NSString *LI_AMOUNT = @"amount";
static NSString *LI_ADDRESS_ID = @"address_id";

@implementation LineItem

- (LineItem *) initWithType:(NSString *)type {
    self.liType = type;
    self.liShipMethod = LINE_ITEM_NO_VALUE;
    self.liQuantity = 0;
    self.liName = LINE_ITEM_NO_VALUE;
    self.liCouponId = LINE_ITEM_NO_VALUE;
    self.liAmount = LINE_ITEM_NO_VALUE;
    self.liAddressId = LINE_ITEM_NO_VALUE;
    
    return self;
}

- (LineItem *) initWithPackedLineItem:(NSDictionary *)savedObject {
    self.liType = [savedObject objectForKey:LI_TYPE];
    self.liShipMethod = [savedObject objectForKey:LI_SHIPMETHOD];
    self.liQuantity = [[savedObject objectForKey:LI_QUANTITY] integerValue];
    self.liName = [savedObject objectForKey:LI_NAME];
    self.liCouponId = [savedObject objectForKey:LI_COUPON_ID];
    self.liAmount = [savedObject objectForKey:LI_AMOUNT];
    self.liAddressId = [savedObject objectForKey:LI_ADDRESS_ID];
    return self;
}
- (NSDictionary *) packLineItem {
    NSMutableDictionary *packedDict = [[NSMutableDictionary alloc] init];
    [packedDict setObject:self.liType forKey:LI_TYPE];
    [packedDict setObject:self.liShipMethod forKey:LI_SHIPMETHOD];
    [packedDict setObject:[NSNumber numberWithInteger:self.liQuantity] forKey:LI_QUANTITY];
    [packedDict setObject:self.liName forKey:LI_NAME];
    [packedDict setObject:self.liCouponId forKey:LI_COUPON_ID];
    [packedDict setObject:self.liAmount forKey:LI_AMOUNT];
    [packedDict setObject:self.liAddressId forKey:LI_ADDRESS_ID];
    return packedDict;
}

@end
