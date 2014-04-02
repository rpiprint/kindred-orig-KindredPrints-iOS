//
//  ShippingPicker.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/22/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShippingPickerDelegate <NSObject>

@optional
- (void)pickedShipping:(NSString *)shippingType forAddressId:(NSString *)addressId;
@end

@interface ShippingPicker : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) id <ShippingPickerDelegate> pickerDelegate;

- (void)showWithQuotes:(NSArray *)quotes andSelection:(NSString *)type forAddress:(NSString *)addressId;

@end
