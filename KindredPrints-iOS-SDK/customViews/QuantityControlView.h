//
//  QuantityControlView.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/3/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuantityControlDelegate <NSObject>

@optional
- (void)updatedQuantity:(NSInteger)quantity;
@end


@interface QuantityControlView : UIView

- (id)initWithFrame:(CGRect)frame andQuantity:(NSInteger)quantity;

@property (nonatomic) NSInteger quantity;

@property (nonatomic, strong) id <QuantityControlDelegate> delegate;

@end
