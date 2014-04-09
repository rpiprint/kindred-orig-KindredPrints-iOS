//
//  DevPreferenceHelper.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreferenceHelper.h"

static BOOL LOG = YES;
static BOOL DEV = NO;

@interface DevPreferenceHelper : PreferenceHelper
+ (BOOL)testForNullValue:(id)object;

+ (NSString *)getAPIServerAddress;
+ (NSString *)getServerAddress;
+ (NSString *)getStripeKey;

+ (BOOL)getIsStripeTest;

+ (void)setAppKey:(NSString *)key;
+ (NSString *)getAppKey;

+ (void)setPartnerName:(NSString *)name;
+ (NSString *)getPartnerName;

+ (NSString *)getPartnerLogoUrl;
+ (void)setPartnerLogoUrl:(NSString *)url;

+ (void)setCurrentSizes:(NSMutableArray *)sizes;
+ (NSMutableArray *)getCurrentSizes;

+ (void)resetPartnerDownloadStatus;
+ (BOOL)needPartnerInfo;

+ (void)resetAddressDownloadStatus;
+ (BOOL)needDownloadAddresses;

+ (void)resetSizeDownloadStatus;
+ (BOOL)needDownloadSizes;

+ (void)resetDownloadCountryStatus;
+ (BOOL)needDownloadCountries;

+ (NSArray *) getCountries;
+ (void) setCountries:(NSArray *)countries;

@end
