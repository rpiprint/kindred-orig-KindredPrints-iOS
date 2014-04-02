//
//  CheckoutLineItemCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/13/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineItem.h"

static NSString * const CHECK_LINE_CELL_IDENTIFIER = @"kp_checkout_litem_cell";

@protocol CheckoutLineItemDelegate <NSObject>

@optional
- (void)userRequestedChangeShippingWithAddressId:(NSString *)aid;
@end

@interface CheckoutLineItemCell : UITableViewCell

@property (nonatomic, strong) id <CheckoutLineItemDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width;
- (void)updateCellForLineItem:(LineItem *)item;


@end
