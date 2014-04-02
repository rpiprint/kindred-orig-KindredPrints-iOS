//
//  CheckoutCreditCardCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/13/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const CHECK_CREDIT_CELL_IDENTIFIER = @"kp_checkout_credit_cell";

@protocol CheckoutCreditCardDelegate <NSObject>

@optional
- (void)userRequestedCreditCardEdit;
@end

@interface CheckoutCreditCardCell : UITableViewCell

@property (nonatomic, strong) id <CheckoutCreditCardDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width;
- (void)updateDisplay;

@end
