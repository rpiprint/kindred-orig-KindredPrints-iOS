//
//  KPCartPageModel.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPCartEditorViewController.h"
#import "OrderImage.h"

@protocol KPCartModelDelegate <NSObject>

@optional
- (void)refreshView;
- (void)updateOrderTotal:(NSInteger)orderTotal;
- (void)userRequestedGoForwardAPage;
- (void)userRequestedGoBackAPage;
@end

@interface KPCartPageModel : NSObject <UIPageViewControllerDataSource>

- (void) initOrderTotal;
- (OrderImage *)orderImageAtIndex:(NSUInteger)index;
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(KPCartEditorViewController *)viewController;
- (NSInteger)maxPages;

@property (nonatomic, weak) id <KPCartModelDelegate> delegate;

@end
