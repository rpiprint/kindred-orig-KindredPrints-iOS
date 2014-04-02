//
//  KPCartPageModel.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPCartPageModel.h"
#import "UserPreferenceHelper.h"
#import "KPEmptyCartViewController.h"
#import "BaseImage.h"
#import "OrderManager.h"

@interface KPCartPageModel() <KPCartEditorDelegate, OrderManagerDelegate>

@property (nonatomic) NSInteger orderTotal;

@property (strong, nonatomic) OrderManager *orderManager;

@end

@implementation KPCartPageModel

- (void)setOrderTotal:(NSInteger)orderTotal {
    _orderTotal = orderTotal;
    [self.delegate updateOrderTotal:self.orderTotal];
}

- (OrderManager *)orderManager {
    if (!_orderManager) {
        _orderManager = [OrderManager getInstance];
    }
    return _orderManager;
}

- (void) initOrderTotal {
    NSInteger tempTotal = 0;
    for (int i = 0; i < [self.orderManager countOfOrders]; i++) {
        OrderImage *order = [self.orderManager getOrderForIndex:i];
        for (PrintableSize *product in order.printProducts) {
            tempTotal = tempTotal + product.sQuantity * product.sPrice;
        }
    }
    self.orderTotal = tempTotal;
}

- (OrderImage *)orderImageAtIndex:(NSUInteger)index {
    if (([self.orderManager countOfOrders] == 0) || (index >= [self.orderManager countOfOrders])) {
        return nil;
    }
    return [self.orderManager getOrderForIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    // Return the data view controller for the given index.
    if (([self.orderManager countOfOrders] == 0) || (index >= [self.orderManager countOfOrders])) {
        KPEmptyCartViewController *emptyVC = [[KPEmptyCartViewController alloc] init];
        return emptyVC;
    }
    OrderImage *order = [self.orderManager getOrderForIndex:index];
    KPCartEditorViewController *pageVC = [[KPCartEditorViewController alloc] initWithNibName:@"KPCartEditorViewController" andImage:order];
    pageVC.index = index;
    pageVC.delegate = self;
    return pageVC;
}

- (NSUInteger)indexOfViewController:(KPCartEditorViewController *)viewController {
    for (int i = 0; i < [self.orderManager countOfOrders]; i++) {
        NSString *pid = ((OrderImage *)[self.orderManager getOrderForIndex:i]).image.pid;
        if ([pid isEqualToString:viewController.image.image.pid])
            return i;
    }
    
    return 0;
}

- (NSInteger)maxPages {
    return [self.orderManager countOfOrders];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(KPCartEditorViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(KPCartEditorViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.orderManager countOfOrders]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark KPCART DELEGATE

- (void)userRequestedDeleteOfCurrentPage:(NSInteger)index {
    OrderImage *order = [[self.orderManager getOrderImages] objectAtIndex:index];
    NSInteger deltaPrice = 0;
    for (PrintableSize *product in order.printProducts) {
        deltaPrice = deltaPrice - product.sQuantity * product.sPrice;
    }
    [self userChangedQuantityByDeltaPrice:deltaPrice];
    [self.orderManager deleteOrderImageAtIndex:index];
    [self.delegate refreshView];
}

- (void)userChangedQuantityByDeltaPrice:(NSInteger)deltaPrice {
    self.orderTotal = self.orderTotal + deltaPrice;
}

- (void)userRequestedGoForwardAPage {
    if (self.delegate) [self.delegate userRequestedGoForwardAPage];
}
- (void)userRequestedGoBackAPage {
    if (self.delegate) [self.delegate userRequestedGoBackAPage];
}


@end
