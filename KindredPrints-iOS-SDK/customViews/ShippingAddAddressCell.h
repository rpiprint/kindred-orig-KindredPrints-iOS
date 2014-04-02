//
//  ShippingAddAddressCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/9/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const ADD_ADDRESS_CELL_IDENTIFIER = @"kp_add_address_cell";

@interface ShippingAddAddressCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(NSInteger)width;

@end
