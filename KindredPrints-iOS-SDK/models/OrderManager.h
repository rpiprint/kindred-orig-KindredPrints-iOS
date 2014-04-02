//
//  OrderManager.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/18/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImage.h"
#import "OrderImage.h"
#import "SelectedOrderImage.h"

@protocol OrderManagerDelegate <NSObject>

@optional
- (void)ordersHaveAllBeenUpdated;
- (void)ordersHaveBeenUpdatedWithSizes:(BaseImage *)image;
- (void)ordersHaveBeenServerInit:(BaseImage *)image;
- (void)ordersHaveBeenUploaded:(BaseImage *)image;
@end


@interface OrderManager : NSObject

+ (OrderManager *)getInstance;

@property (nonatomic, strong) id <OrderManagerDelegate> delegate;

- (void) updateAllOrdersWithNewSizes;
- (void) imageWasUpdatedWithSizes:(BaseImage *)image andSizes:(NSArray *)fitSizeList;
- (void) imageWasServerInit:(NSString *)localId withServerId:(NSString *)pid;
- (void) imageFinishedUploading:(NSString *)localId;
- (void) selectedImageWasServerInit:(NSString *)localId withServerId:(NSString *)pid;
- (void) selectedImageWasServerLineItemInit:(NSString *)localId withServerId:(NSString *)pid;

- (NSInteger)countOfOrders;
- (NSInteger)countOfSelectedOrders;

- (void) deleteOrderImageAtIndex:(NSInteger)index;
- (void) addOrderImage:(OrderImage *)order;

- (OrderImage *)getOrderForIndex:(NSInteger)index;
- (SelectedOrderImage *)getSelectedOrderForIndex:(NSInteger)index;
- (SelectedOrderImage *)getSelectedOrderForId:(NSString *)pid;

- (NSArray *)getOrderImages;
- (NSArray *)getSelectedOrderImages;
- (void)setSelectedOrderImages:(NSArray *)selectedOrderImages;

- (void) cleanUpCart;

- (NSInteger)getOrderTotal;

@end
