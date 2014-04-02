//
//  CheckoutCompletePurchaseCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/13/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const CHECK_PURCHASE_CELL_IDENTIFIER = @"kp_checkout_purchase_cell";

@protocol CheckoutCompletePurchaseDelegate <NSObject>

@optional
- (void)userRequestedCheckout;
@end

@interface CheckoutCompletePurchaseCell : UITableViewCell

@property (nonatomic, strong) id <CheckoutCompletePurchaseDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width;

@end
