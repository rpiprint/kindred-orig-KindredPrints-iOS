//
//  ShippingPicker.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/22/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "ShippingPicker.h"
#import "InterfacePreferenceHelper.h"
#import "DevPreferenceHelper.h"
#import "UserPreferenceHelper.h"

@interface ShippingPicker()

@property (nonatomic, strong) NSArray *quoteList;
@property (nonatomic, strong) NSArray *shippingList;
@property (nonatomic, strong) NSString *addressId;

@end

@implementation ShippingPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        [self setShowsSelectionIndicator:YES];
        [self setBackgroundColor:[InterfacePreferenceHelper getColor:ColorNavBar]];
    }
    return self;
}

- (void)showWithQuotes:(NSArray *)quotes andSelection:(NSString *)type forAddress:(NSString *)addressId {
    self.quoteList = quotes;
    self.addressId = addressId;
    
    NSMutableArray *finList = [[NSMutableArray alloc] init];
    NSInteger selRow = -1;
    for (int i = 0; i < [quotes count]; i++) {
        NSDictionary *quote = [quotes objectAtIndex:i];
        if ([type isEqualToString:[quote objectForKey:@"name"]]) {
            selRow = i;
        }
        
        NSString *priceStr = @"$%.2f";
        if ([[quote objectForKey:@"price"] integerValue]%100 == 0) {
            priceStr = @"$%.0f";
        }
        
        NSString *rowTitle = [[[quote objectForKey:@"speed"] stringByAppendingString:@" for "] stringByAppendingString:[NSString stringWithFormat:priceStr, ((CGFloat)[[quote objectForKey:@"price"] integerValue])/100.0f]];
        [finList addObject:rowTitle];
    }
    self.shippingList = finList;
    [self reloadAllComponents];
    [self selectRow:selRow inComponent:0 animated:NO];
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
    NSString *title = [self.shippingList objectAtIndex:row];
    [tView setText:title];
    
    return tView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDictionary *quote = [self.quoteList objectAtIndex:row];
    [self.pickerDelegate pickedShipping:[quote objectForKey:@"name"] forAddressId:self.addressId];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.shippingList count];
}

@end
