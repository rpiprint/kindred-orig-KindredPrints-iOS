//
//  BaseAddress.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/8/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const ADDRESS_NO_VALUE = @"kp_address_no_value";
static NSString * const ADDRESS_ID = @"kp_address_id";
static NSString * const ADDRESS_NAME = @"kp_address_name";
static NSString * const ADDRESS_STREET = @"kp_address_street";
static NSString * const ADDRESS_CITY = @"kp_address_city";
static NSString * const ADDRESS_STATE = @"kp_address_state";
static NSString * const ADDRESS_ZIP = @"kp_address_zip";
static NSString * const ADDRESS_COUNTY = @"kp_address_country";
static NSString * const ADDRESS_PHONE = @"kp_address_phone";
static NSString * const ADDRESS_EMAIL = @"kp_address_email";
static NSString * const ADDRESS_SHIP_METHOD = @"kp_ship_method";

@interface BaseAddress : NSObject

@property (strong, nonatomic) NSString *aId;
@property (strong, nonatomic) NSString *aName;
@property (strong, nonatomic) NSString *aStreet;
@property (strong, nonatomic) NSString *aCity;
@property (strong, nonatomic) NSString *aState;
@property (strong, nonatomic) NSString *aZip;
@property (strong, nonatomic) NSString *aCountry;
@property (strong, nonatomic) NSString *aPhone;
@property (strong, nonatomic) NSString *aEmail;
@property (strong, nonatomic) NSString *aShipMethod;

- (BaseAddress *)initWithId:(NSString *)aid name:(NSString *)name street:(NSString *)street city:(NSString *)city state:(NSString *)state zip:(NSString *)zip country:(NSString *)country email:(NSString *)email phone:(NSString *)phone;
- (BaseAddress *)initWithPackedAddress:(NSDictionary *)packedAddress;
- (NSDictionary *)packAddress;

@end
