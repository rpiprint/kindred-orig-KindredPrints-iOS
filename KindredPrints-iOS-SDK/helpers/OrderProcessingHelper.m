//
//  OrderProcessingHelper.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "OrderProcessingHelper.h"
#import "KindredServerInterface.h"
#import "UserPreferenceHelper.h"
#import "OrderManager.h"
#import "ImageUploadHelper.h"
#import "BaseImage.h"
#import "BaseAddress.h"
#import "OrderImage.h"
#import "SelectedOrderImage.h"
#import "UserObject.h"

@interface OrderProcessingHelper() <ServerInterfaceDelegate, OrderManagerDelegate, ImageUploadDelegate>

@property (strong, nonatomic) UserObject *currUser;

@property (strong, nonatomic) KindredServerInterface *kInterface;
@property (strong, nonatomic) OrderManager *orderManager;
@property (strong, nonatomic) ImageUploadHelper *uploadHelper;

@property (nonatomic) CGFloat currStage;

@property (strong, nonatomic) NSString *orderId;

@property (nonatomic) BOOL doneInitialUpload;

@end

@implementation OrderProcessingHelper

static NSInteger MAX_NAME_LENGTH = 7;

static CGFloat const STEP_ORDERS_INIT = 0;
static CGFloat const STEP_UPLOAD_FINISHED = 1;

static CGFloat const STEP_CHECKOUT_INIT = 0;
static CGFloat const STEP_CHECKOUT_DONE = 1;

static CGFloat const TOTAL_STEPS = 2;

- (UserObject *)currUser {
    if (!_currUser) _currUser = [UserPreferenceHelper getUserObject];
    return _currUser;
}

- (id) init {
    self = [super init];
    if (self) {
        self.orderId = [UserPreferenceHelper getOrderId];
        
        self.kInterface = [[KindredServerInterface alloc] init];
        self.kInterface.delegate = self;
        
        self.orderManager = [OrderManager getInstance];
        
        self.uploadHelper = [ImageUploadHelper getInstance];
        self.uploadHelper.delegate = self;
    }
    return self;
}


- (void) initiateCheckoutSequence {
    self.currStage = STEP_CHECKOUT_INIT;
    
    [self initPaymentObject];
}

- (void) initiateOrderCreateOrUpdateSequence {
    
    self.currStage = STEP_ORDERS_INIT;
    [self.delegate orderProcessingUpdateProgress:self.currStage/TOTAL_STEPS withStatus:@"uploading photos to printer.."];
    
    self.doneInitialUpload = NO;
    [self.uploadHelper validateAllOrdersInit];
}


- (void) initOrderObject {
    if (![UserPreferenceHelper orderIsSame]) {
        NSMutableArray *prints = [[NSMutableArray alloc] init];
        NSMutableArray *destinations = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.orderManager countOfSelectedOrders]; i++) {
            SelectedOrderImage *sOrder = [self.orderManager getSelectedOrderForIndex:i];
            [prints addObject:sOrder.oLineItemServerId];
        }
        NSArray *selAddresses = [UserPreferenceHelper getSelectedAddresses];
        for (BaseAddress *address in selAddresses) {
            NSMutableDictionary *destDict = [[NSMutableDictionary alloc] init];
            [destDict setObject:address.aId forKey:@"address_id"];
            if (![address.aShipMethod isEqualToString:ADDRESS_NO_VALUE]) {
                [destDict setObject:address.aShipMethod forKey:@"ship_method"];
            }
            [destinations addObject:destDict];
        }
        if ([self.orderId isEqualToString:ORDER_NO_VALUE]) {
            NSDictionary *post = [[NSDictionary alloc]
                             initWithObjects:@[prints, self.currUser.uId, destinations]
                             forKeys:@[@"lineitem_ids", @"user_id", @"destinations"]];
            [self.kInterface createOrderObject:post];
        } else {
            NSDictionary *post = [[NSDictionary alloc]
                                  initWithObjects:@[prints, self.orderId, destinations]
                                  forKeys:@[@"lineitem_ids", @"id", @"destinations"]];
            [self.kInterface updateOrderObject:post andOrderId:self.orderId];
        }
    } else {
        [self.delegate orderCreatedAndReturnedLineItems:[UserPreferenceHelper getOrderLineItems]];
    }
    
}

- (void) initPaymentObject {
    self.currStage = STEP_CHECKOUT_INIT;
    [self.delegate orderProcessingUpdateProgress:self.currStage/TOTAL_STEPS withStatus:@"validating payment.."];
    
    NSDictionary *post = [[NSDictionary alloc]
                          initWithObjects:@[self.orderId]
                          forKeys:@[@"order_id"]];
    [self.kInterface checkoutOrder:post andOrderId:self.orderId];
}

- (void) cleanUpCart {
    self.currStage = STEP_CHECKOUT_DONE;
    [self.delegate orderProcessingUpdateProgress:self.currStage/TOTAL_STEPS withStatus:@"feeding hamster.."];
    
    [UserPreferenceHelper setOrderLineItems:[[NSArray alloc] init]];
    [UserPreferenceHelper setOrderId:ORDER_NO_VALUE];
    [UserPreferenceHelper setOrderIsSame:NO];
    [self.orderManager cleanUpCart];
    
    [self.delegate orderProcessingUpdateProgress:TOTAL_STEPS/TOTAL_STEPS withStatus:@"success!"];
    [self.delegate paymentProcessed];
}

- (NSArray *) createLineItemsFromServerObject:(NSArray *)serverItems {
    NSMutableArray *lineItems = [[NSMutableArray alloc] init];
    
    NSMutableArray *allAddresses = [UserPreferenceHelper getAllAddresses];
    NSMutableArray *selAddresses = [UserPreferenceHelper getSelectedAddresses];
    for (int i = 0; i < [serverItems count]; i++) {
        NSDictionary *listItem = [serverItems objectAtIndex:i];
        NSString *type = [listItem objectForKey:@"type"];
        
        LineItem *item = [[LineItem alloc] initWithType:type];
        item.liName = [listItem objectForKey:@"name"];
        item.liAmount = [listItem objectForKey:@"amount"];
        if ([type isEqualToString:LINE_ITEM_TYPE_PRODUCT]) {
            item.liQuantity = [[listItem objectForKey:@"quantity"] integerValue];
        } else if ([type isEqualToString:LINE_ITEM_TYPE_SHIPPING]) {
            item.liAddressId = [listItem objectForKey:@"address_id"];
            NSArray *splitShippingName = [item.liName componentsSeparatedByString:@" "];
            NSString *improvedLabel = [splitShippingName objectAtIndex:0];
            if ([splitShippingName count] > 2 ) {
                improvedLabel = [[[improvedLabel stringByAppendingString:@" "] stringByAppendingString:[splitShippingName objectAtIndex:1]] stringByAppendingString:@" "];
                if ([[splitShippingName objectAtIndex:2] length] > MAX_NAME_LENGTH) {
                    improvedLabel = [improvedLabel stringByAppendingString:[[splitShippingName objectAtIndex:2] substringToIndex:MAX_NAME_LENGTH]];
                } else {
                    improvedLabel = [improvedLabel stringByAppendingString:[splitShippingName objectAtIndex:2]];
                }
                item.liName = [NSString stringWithFormat:@"%@", improvedLabel];
            }
            for (BaseAddress *address in selAddresses) {
                if ([address.aId isEqualToString:item.liAddressId]) {
                    address.aShipMethod = [listItem objectForKey:@"ship_method"];
                }
            }
            for (BaseAddress *address in allAddresses) {
                if ([address.aId isEqualToString:item.liAddressId]) {
                    address.aShipMethod = [listItem objectForKey:@"ship_method"];
                }
            }
            item.liShipMethod = [listItem objectForKey:@"ship_method"];
        } else if ([type isEqualToString:LINE_ITEM_TYPE_TOTAL]) {
            [UserPreferenceHelper setOrderTotal:item.liAmount];
        }
        
        [lineItems addObject:item];
    }
    [UserPreferenceHelper setAllShippingAddresses:allAddresses];
    [UserPreferenceHelper setSelectedShippingAddresses:selAddresses];
    
    return lineItems;
}

#pragma mark SERVER INTERFACE DELEGATE

- (void)serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];
                
        if ([requestTag isEqualToString:REQ_TAG_CREATE_ORDER_OBJ] || [requestTag isEqualToString:REQ_TAG_UPDATE_ORDER_OBJ]) {
            if (status == 200) {
                self.orderId = [returnedData objectForKey:@"id"];
                [UserPreferenceHelper setOrderId:self.orderId];
                
                NSArray *lineItems = [self createLineItemsFromServerObject:[returnedData objectForKey:@"checkout_items"]];
                [UserPreferenceHelper setOrderLineItems:lineItems];
                [UserPreferenceHelper setOrderIsSame:YES];
                
                [self.delegate orderCreatedAndReturnedLineItems:lineItems];
            } else {
                [self.delegate orderFailedToProcess:[returnedData objectForKey:@"message"]];
            }
        } else if ([requestTag isEqualToString:REQ_TAG_CHECKOUT_ORDER]) {
            if (status == 200) {
                [self cleanUpCart];
            } else if (status == 402 || ([returnedData objectForKey:@"status"] && [[returnedData objectForKey:@"status"] boolValue])){
                [self.delegate orderFailedToProcess:@"Could not charge credit card"];
            } else {
                [self.delegate orderFailedToProcess:[returnedData objectForKey:@"message"]];
            }
        }
        
    }
}

#pragma mark UPLOAD HELPER DELEGATE

- (void)uploadsHaveCompleted {
    if (!self.doneInitialUpload) {
        self.currStage = STEP_UPLOAD_FINISHED;
        [self.delegate orderProcessingUpdateProgress:self.currStage/TOTAL_STEPS withStatus:@"negotiating prices.."];
        self.doneInitialUpload = YES;
        [self initOrderObject];
    }
}

- (void)uploadFinishedWithOverallProgress:(CGFloat)progress processedCount:(NSInteger)processed andTotal:(NSInteger)total {
    [self.delegate orderProcessingUpdateProgress:(self.currStage+progress)/TOTAL_STEPS withStatus:[NSString stringWithFormat:@"processing image %d of %d..", (int)(processed+1)/2, (int)total/2]];
}

- (void)uploadsHaveFailed {
    [self.delegate orderFailedToProcess:@"Image upload failed due to poor connection. Please try again."];
}

@end
