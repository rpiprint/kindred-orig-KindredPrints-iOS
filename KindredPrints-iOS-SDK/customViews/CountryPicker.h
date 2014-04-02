//
//  CountryPicker.h
//  KindredPrints
//
//  Created by Alex on 7/28/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol CountryPickerDelegate <NSObject>

@optional
- (void)pickedCountry:(NSString *)country;
@end


@interface CountryPicker : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSString *selectedCountry;

- (void)selectCountry:(NSString *)country;

@property (nonatomic, strong) id <CountryPickerDelegate> pickerDelegate;

@end
