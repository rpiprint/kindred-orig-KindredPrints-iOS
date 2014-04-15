//
//  CountryPicker.m
//  KindredPrints
//
//  Created by Alex on 7/28/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//

#import "CountryPicker.h"
#import "InterfacePreferenceHelper.h"
#import "DevPreferenceHelper.h"

@interface CountryPicker()

@property (nonatomic, strong) NSArray *countryList;

@end

@implementation CountryPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.countryList = [DevPreferenceHelper getCountries];
        [self selectCountry:@"United States"];
        [self setShowsSelectionIndicator:YES];
    }
    return self;
}

- (void)selectCountry:(NSString *)country {
    NSInteger index = 0;
    for (int i = 0; i < [self.countryList count]; i++)
        if ([[self.countryList objectAtIndex:i] isEqualToString:country]) {
            index = i;
            break;
        }
    self.selectedCountry = country;
    [self selectRow:index inComponent:0 animated:NO];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tView = (UILabel*)view;
    if (!tView) {
        tView = [[UILabel alloc] init];
        [tView setTextAlignment:NSTextAlignmentLeft];
        [tView setBackgroundColor:[InterfacePreferenceHelper getColor:ColorNavBar]];
        [tView setTextColor:[UIColor whiteColor]];
        [tView setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
    }
    [tView setText:[self.countryList objectAtIndex:row]];
    
    return tView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedCountry = [self.countryList objectAtIndex:row];
    [self.pickerDelegate pickedCountry:self.selectedCountry];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.countryList count];
}


@end
