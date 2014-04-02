//
//  SelectedOrderImage.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/5/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImage.h"
#import "PrintableSize.h"

static NSString *SELECTED_ORDER_LINEITEM_SERVER_INIT = @"selected_order_lineitem_server_init";
static NSString *SELECTED_ORDER_LINEITEM_SERVER_ID = @"selected_order_lineitem__server_id";
static NSString *SELECTED_ORDER_SERVER_INIT = @"selected_order_server_init";
static NSString *SELECTED_ORDER_SERVER_ID = @"selected_order_server_id";
static NSString *SELECTED_ORDER_IMAGE = @"selected_order_image";
static NSString *SELECTED_ORDER_PRINT = @"selected_order_print_product";

@interface SelectedOrderImage : NSObject

- (SelectedOrderImage *) initWithImage:(BaseImage *)image andProduct:(PrintableSize *)product;

- (SelectedOrderImage *) initWithPackedOrder:(NSDictionary *)savedObject;
- (NSDictionary *) packOrder;

@property (nonatomic, assign) NSString *oLineItemServerId;
@property (nonatomic) BOOL oLineItemServerInit;
@property (nonatomic, assign) NSString *oServerId;
@property (nonatomic) BOOL oServerInit;
@property (strong, nonatomic) BaseImage *oImage;
@property (strong, nonatomic) PrintableSize *oProduct;

@end
