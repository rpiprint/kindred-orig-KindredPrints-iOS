//
//  OrderImage.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/3/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImage.h"
#import "PrintableSize.h"

static NSString *ORDER_IMAGE = @"order_image";
static NSString *ORDER_PRINTS_LIST = @"order_print_list";
static NSString *ORDER_INIT = @"order_init";

@interface OrderImage : NSObject

- (OrderImage *)initWithOutSize:(BaseImage *)image;
- (OrderImage *)initWithImage:(BaseImage *)image andSize:(CGSize)size;
- (void)updateOrderSizes;

- (OrderImage *) initWithPackedOrder:(NSDictionary *)savedObject;
- (NSDictionary *) packOrder;

@property (strong, nonatomic) BaseImage *image;
@property (strong, nonatomic) NSArray *printProducts;
@property (nonatomic) BOOL printProductsInit;

@end
