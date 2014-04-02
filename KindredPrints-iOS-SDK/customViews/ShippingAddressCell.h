//
//  ShippingAddressCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/8/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAddress.h"

static NSString * const ADDRESS_CELL_IDENTIFIER = @"kp_address_cell";

@protocol ShippingAddressDelegate <NSObject>

@optional
- (void)userChangedSelection:(BOOL)selected andAddress:(BaseAddress *)address;
- (void)userRequestedEditOfAddress:(BaseAddress *)address;
@end

@interface ShippingAddressCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andAddress:(BaseAddress *)address andWidth:(NSInteger)width;
- (void)updateViewWithAddress:(BaseAddress *)address;

@property (nonatomic, strong) id <ShippingAddressDelegate> delegate;

@end
