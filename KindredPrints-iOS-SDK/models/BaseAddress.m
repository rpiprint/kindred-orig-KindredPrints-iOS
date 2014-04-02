//
//  BaseAddress.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/8/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "BaseAddress.h"
#import "DevPreferenceHelper.h"

@implementation BaseAddress



- (BaseAddress *)initWithId:(NSString *)aid name:(NSString *)name street:(NSString *)street city:(NSString *)city state:(NSString *)state zip:(NSString *)zip country:(NSString *)country email:(NSString *)email phone:(NSString *)phone {
    if (![DevPreferenceHelper testForNullValue:aid]) self.aId = aid;
    else self.aId = @"";
    if (![DevPreferenceHelper testForNullValue:name]) self.aName = name;
    else self.aName = @"";
    if (![DevPreferenceHelper testForNullValue:street]) self.aStreet = street;
    else self.aStreet = @"";
    if (![DevPreferenceHelper testForNullValue:city]) self.aCity = city;
    else self.aCity = @"";
    if (![DevPreferenceHelper testForNullValue:state]) self.aState = state;
    else self.aState = @"";
    if (![DevPreferenceHelper testForNullValue:zip]) self.aZip = zip;
    else self.aZip = @"";
    if (![DevPreferenceHelper testForNullValue:country]) self.aCountry = country;
    else self.aCountry = @"";
    if (![DevPreferenceHelper testForNullValue:email]) self.aEmail = email;
    else self.aEmail = @"";
    if (![DevPreferenceHelper testForNullValue:phone]) self.aPhone = phone;
    else self.aPhone = @"";
    
    self.aShipMethod = ADDRESS_NO_VALUE;
    
    return self;
}

- (BaseAddress *)initWithPackedAddress:(NSDictionary *)packedAddress {
    self = [BaseAddress alloc];
    
    self.aId = [packedAddress objectForKey:ADDRESS_ID];
    self.aName = [packedAddress objectForKey:ADDRESS_NAME];
    self.aStreet = [packedAddress objectForKey:ADDRESS_STREET];
    self.aCity = [packedAddress objectForKey:ADDRESS_CITY];
    self.aState = [packedAddress objectForKey:ADDRESS_STATE];
    self.aZip = [packedAddress objectForKey:ADDRESS_ZIP];
    self.aCountry = [packedAddress objectForKey:ADDRESS_COUNTY];
    self.aEmail = [packedAddress objectForKey:ADDRESS_EMAIL];
    self.aPhone = [packedAddress objectForKey:ADDRESS_PHONE];
    self.aShipMethod = [packedAddress objectForKey:ADDRESS_SHIP_METHOD];
    
    return self;
}
- (NSDictionary *)packAddress {
    NSDictionary *packedAddress = [[NSDictionary alloc]
                                   initWithObjects:@[
                                                     self.aId,
                                                     self.aName,
                                                     self.aStreet,
                                                     self.aCity,
                                                     self.aState,
                                                     self.aZip,
                                                     self.aCountry,
                                                     self.aEmail,
                                                     self.aPhone,
                                                     self.aShipMethod]
                                   forKeys:@[ADDRESS_ID,
                                             ADDRESS_NAME,
                                             ADDRESS_STREET,
                                             ADDRESS_CITY,
                                             ADDRESS_STATE,
                                             ADDRESS_ZIP,
                                             ADDRESS_COUNTY,
                                             ADDRESS_EMAIL,
                                             ADDRESS_PHONE,
                                             ADDRESS_SHIP_METHOD]];
    return packedAddress;
}

@end
