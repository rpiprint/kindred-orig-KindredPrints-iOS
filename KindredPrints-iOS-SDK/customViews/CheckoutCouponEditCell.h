//
//  CheckoutCouponEditCellTableViewCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 3/21/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const CHECK_COUPON_CELL_IDENTIFIER = @"kp_coupon_cell";

@protocol CouponApplyDelegate <NSObject>

@optional
- (void)userRequestedApplyCoupon:(NSString *)couponId;
@end

@interface CheckoutCouponEditCell : UITableViewCell

@property (nonatomic, strong) id <CouponApplyDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width;

@end
