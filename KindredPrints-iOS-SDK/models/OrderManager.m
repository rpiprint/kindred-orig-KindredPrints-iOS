//
//  OrderManager.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/18/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "OrderManager.h"
#import "UserPreferenceHelper.h"

@interface OrderManager()

@property (nonatomic) dispatch_semaphore_t orders_sema;
@property (nonatomic) dispatch_semaphore_t selorders_sema;
@property (strong, nonatomic) NSMutableArray *orders;
@property (strong, nonatomic) NSMutableArray *selectedOrders;

@end

@implementation OrderManager

static OrderManager *orderManager;

+ (OrderManager *)getInstance {
    if (!orderManager)  {
        orderManager = [[OrderManager alloc] init];
        orderManager.orders_sema = dispatch_semaphore_create(1);
        orderManager.selorders_sema = dispatch_semaphore_create(1);
    }
    return orderManager;
}

- (NSMutableArray *)orders {
    if (!_orders) {
        _orders = [UserPreferenceHelper getCartOrders];
    }
    return _orders;
}

- (NSMutableArray *)selectedOrders {
    if (!_selectedOrders) {
        _selectedOrders = [UserPreferenceHelper getSelectedOrders];
    }
    return _selectedOrders;
}

- (void) updateAllOrdersWithNewSizes {
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfOrders]; i++) {
        [(OrderImage *)[self.orders objectAtIndex:i] updateOrderSizes];
    }
    [UserPreferenceHelper setCartOrders:self.orders];
    dispatch_semaphore_signal(self.orders_sema);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) [self.delegate ordersHaveAllBeenUpdated];
    });
}
- (void) imageWasUpdatedWithSizes:(BaseImage *)image andSizes:(NSArray *)fitSizeList {
    BaseImage *updatedSize;
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfOrders]; i++) {
        if ([((OrderImage *)[self.orders objectAtIndex:i]).image.pid isEqualToString:image.pid]) {
            ((OrderImage *)[self.orders objectAtIndex:i]).image.pWidth = image.pWidth;
            ((OrderImage *)[self.orders objectAtIndex:i]).image.pHeight = image.pHeight;
            ((OrderImage *)[self.orders objectAtIndex:i]).image.pLocalCached = image.pLocalCached;
            ((OrderImage *)[self.orders objectAtIndex:i]).image.pThumbLocalCached = image.pThumbLocalCached;
            if (image.pLocalCached) {
                for (PrintableSize *size in fitSizeList) {
                    if (image.pWidth < image.pHeight) {
                        size.sDPI = image.pWidth/size.sTrimmedSize.width;
                    } else {
                        size.sDPI = image.pHeight/size.sTrimmedSize.height;
                    }
                }
            }
            ((OrderImage *)[self.orders objectAtIndex:i]).printProducts = fitSizeList;
            ((OrderImage *)[self.orders objectAtIndex:i]).printProductsInit = YES;
            updatedSize = ((OrderImage *)[self.orders objectAtIndex:i]).image;
        }
    }
    [UserPreferenceHelper setCartOrders:self.orders];
    dispatch_semaphore_signal(self.orders_sema);

    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfSelectedOrders]; i++) {
        if ([((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oImage.pid isEqualToString:image.pid]) {
            [self.selectedOrders removeObjectAtIndex:i];
            i--;
        }
    }
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    dispatch_semaphore_signal(self.selorders_sema);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) [self.delegate ordersHaveBeenUpdatedWithSizes:updatedSize];
    });

}
- (void) imageWasServerInit:(NSString *)localId withServerId:(NSString *)pid {
    // make sure to update all selected iamges
    BaseImage *updatedServer;
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfOrders]; i++) {
        if ([((OrderImage *)[self.orders objectAtIndex:i]).image.pid isEqualToString:localId]) {
            ((OrderImage *)[self.orders objectAtIndex:i]).image.pServerInit = YES;
            ((OrderImage *)[self.orders objectAtIndex:i]).image.pServerId = pid;
            updatedServer = ((OrderImage *)[self.orders objectAtIndex:i]).image;
        }
    }
    [UserPreferenceHelper setCartOrders:self.orders];
    dispatch_semaphore_signal(self.orders_sema);

    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfSelectedOrders]; i++) {
        if ([((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oImage.pid isEqualToString:localId]) {
            ((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oImage.pServerInit = YES;
            ((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oImage.pServerId = pid;
        }
    }
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    dispatch_semaphore_signal(self.selorders_sema);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) [self.delegate ordersHaveBeenServerInit:updatedServer];
    });
}
- (void) imageFinishedUploading:(NSString *)localId {
    // make sure to update all selected iamges
    BaseImage *updatedServer;
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfOrders]; i++) {
        if ([((OrderImage *)[self.orders objectAtIndex:i]).image.pid isEqualToString:localId]) {
            ((OrderImage *)[self.orders objectAtIndex:i]).image.pUploadComplete = YES;
            updatedServer = ((OrderImage *)[self.orders objectAtIndex:i]).image;
        }
    }
    [UserPreferenceHelper setCartOrders:self.orders];
    dispatch_semaphore_signal(self.orders_sema);

    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfSelectedOrders]; i++) {
        if ([((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oImage.pid isEqualToString:localId]) {
            ((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oImage.pUploadComplete = YES;
        }
    }
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    dispatch_semaphore_signal(self.selorders_sema);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) [self.delegate ordersHaveBeenUploaded:updatedServer];
    });
}
- (void) selectedImageWasServerInit:(NSString *)localId withServerId:(NSString *)pid {
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfSelectedOrders]; i++) {
        SelectedOrderImage *sImage = [self.selectedOrders objectAtIndex:i];
        if ([[[sImage.oImage.pid stringByAppendingString:@"-"] stringByAppendingString:sImage.oProduct.sid] isEqualToString:localId]) {
            ((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oServerId = pid;
            ((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oServerInit = YES;
        }
    }
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    dispatch_semaphore_signal(self.selorders_sema);
}
- (void) selectedImageWasServerLineItemInit:(NSString *)localId withServerId:(NSString *)pid {
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < [self countOfSelectedOrders]; i++) {
        SelectedOrderImage *sImage = [self.selectedOrders objectAtIndex:i];
        if ([[[sImage.oImage.pid stringByAppendingString:@"-"] stringByAppendingString:sImage.oProduct.sid] isEqualToString:localId]) {
            ((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oLineItemServerId = pid;
            ((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oLineItemServerInit = YES;
        }
    }
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    dispatch_semaphore_signal(self.selorders_sema);
}

- (NSInteger)countOfOrders {
    return [self.orders count];
}
- (NSInteger)countOfSelectedOrders {
    return [self.selectedOrders count];
}
- (void) deleteOrderImageAtIndex:(NSInteger)index {
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    OrderImage *order = [self.orders objectAtIndex:index];
    for (int i = 0; i < [self countOfSelectedOrders]; i++) {
        if ([((SelectedOrderImage *)[self.selectedOrders objectAtIndex:i]).oImage.pid isEqualToString:order.image.pid]) {
            [self.selectedOrders removeObjectAtIndex:i];
            i--;
        }
    }
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    dispatch_semaphore_signal(self.selorders_sema);

    [self.orders removeObjectAtIndex:index];
    dispatch_semaphore_signal(self.orders_sema);

    [UserPreferenceHelper setCartOrders:self.orders];
}
- (void) addOrderImage:(OrderImage *)order {
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    for (OrderImage *prevOrder in self.orders)
        if ([prevOrder.image.pid isEqualToString:order.image.pid])
            return;
    [self.orders addObject:order];
    dispatch_semaphore_signal(self.orders_sema);

    [UserPreferenceHelper setCartOrders:self.orders];
}

- (OrderImage *)getOrderForIndex:(NSInteger)index {
    if (index < 0 || index >= [self countOfOrders])
        return nil;
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    OrderImage *img = [self.orders objectAtIndex:index];
    dispatch_semaphore_signal(self.orders_sema);
    return img;
}
- (SelectedOrderImage *)getSelectedOrderForIndex:(NSInteger)index {
    if (index < 0 || index >= [self countOfSelectedOrders])
        return nil;
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    SelectedOrderImage *selImg = [self.selectedOrders objectAtIndex:index];
    dispatch_semaphore_signal(self.selorders_sema);
    return selImg;
}
- (SelectedOrderImage *)getSelectedOrderForId:(NSString *)pid {
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    for (SelectedOrderImage *sOrder in self.selectedOrders) {
        if ([sOrder.oImage.pid isEqualToString:pid]) {
            dispatch_semaphore_signal(self.selorders_sema);
            return sOrder;
        }
    }
    dispatch_semaphore_signal(self.selorders_sema);
    return nil;
}

- (NSArray *)getOrderImages {
    return self.orders;
}
- (NSArray *)getSelectedOrderImages {
    return self.selectedOrders;
}
- (void)setSelectedOrderImages:(NSArray *)selectedOrderImages {
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    self.selectedOrders = [selectedOrderImages mutableCopy];
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    dispatch_semaphore_signal(self.selorders_sema);
}

- (NSInteger)getOrderTotal {
    NSInteger orderTotal = 0;
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    for (SelectedOrderImage *order in self.selectedOrders) {
        orderTotal = orderTotal + order.oProduct.sQuantity*order.oProduct.sPrice;
    }
    dispatch_semaphore_signal(self.selorders_sema);

    return orderTotal;

}

- (void) cleanUpCart {
    dispatch_semaphore_wait(self.orders_sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.selorders_sema, DISPATCH_TIME_FOREVER);
    self.selectedOrders = [[NSMutableArray alloc] init];
    self.orders = [[NSMutableArray alloc] init];
    [UserPreferenceHelper setSelectedOrders:self.selectedOrders];
    [UserPreferenceHelper setCartOrders:self.orders];
    dispatch_semaphore_signal(self.orders_sema);
    dispatch_semaphore_signal(self.selorders_sema);
}

@end
