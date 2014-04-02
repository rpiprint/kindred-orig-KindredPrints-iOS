//
//  DevPreferenceHelper.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 1/31/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "DevPreferenceHelper.h"
#import "PrintableSize.h"

@implementation DevPreferenceHelper

static NSInteger PARTNER_DOWNLOAD_INTERVAL = 60*60*24;
static NSInteger DOWNLOAD_INTERVAL = 60*60*24*7;
static NSString * KEY_IMAGE_SIZES = @"kp_image_sizes";

static NSString * KEY_APP_KEY = @"kp_app_key";
static NSString * KEY_DOWNLOAD_IMAGE_SIZE_DATE = @"kp_image_size_download";
static NSString * KEY_COUNTRIES = @"kp_country_list";
static NSString * KEY_COUNTRY_DOWNLOAD_DATE = @"kp_country_download_date";
static NSString * KEY_ADDRESS_DOWNLOAD_DATE = @"kp_address_download_date";
static NSString * KEY_PARTER_DOWNLOAD_DATE = @"kp_partner_download_date";
static NSString * KEY_PARTER_NAME = @"kp_partner_name";
static NSString * KEY_PARTER_URL = @"kp_partner_url";

+ (BOOL)testForNullValue:(id)object
{
    if(((object==0)||[object isEqual:[NSNull null]]))
    {
        return YES;
    }
    if([object isKindOfClass:[NSString class]])
    {
        if([object length]==0)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (void)setAppKey:(NSString *)key {
    NSData *dKey = [[key stringByAppendingString:@":"] dataUsingEncoding:NSUTF8StringEncoding];
    [DevPreferenceHelper writeObjectToDefaults:KEY_APP_KEY value:[DevPreferenceHelper base64forData:dKey]];
}
+ (NSString *)getAppKey {
    return (NSString *)[DevPreferenceHelper readObjectFromDefaults:KEY_APP_KEY];
}

+ (NSString *)getAPIServerAddress {
    return @"http://apidev.kindredprints.com/";
}

+ (NSString *)getServerAddress {
    if (DEV)
        return @"http://dev.kindredprints.com/";
    else
        return @"http://www.kindredprints.com/";
}

+ (NSString *)getStripeKey {
    if (DEV)
        return @"pk_test_9pMXnrGjrTrJ0mBwflF7lCMK";
    else
        return @"pk_live_InAYJo4PSgFdffdHorYqNLl9";
}

+ (void)setPartnerName:(NSString *)name {
    [DevPreferenceHelper writeObjectToDefaults:KEY_PARTER_NAME value:name];
}
+ (NSString *)getPartnerName {
    return (NSString *)[DevPreferenceHelper readObjectFromDefaults:KEY_PARTER_NAME];
}
+ (void)setPartnerLogoUrl:(NSString *)url {
    [DevPreferenceHelper writeObjectToDefaults:KEY_PARTER_URL value:url];
}
+ (NSString *)getPartnerLogoUrl {
    return (NSString *)[DevPreferenceHelper readObjectFromDefaults:KEY_PARTER_URL];
}
+ (void)setCurrentSizes:(NSMutableArray *)sizes {
    NSMutableArray *storeableArray = [[NSMutableArray alloc] init];
    for (PrintableSize *size in sizes) {
        [storeableArray addObject:[size packSize]];
    }
    [DevPreferenceHelper writeObjectToDefaults:KEY_IMAGE_SIZES value:storeableArray];
}
+ (NSMutableArray *)getCurrentSizes {
    NSMutableArray *sizesArray = (NSMutableArray *)[DevPreferenceHelper readObjectFromDefaults:KEY_IMAGE_SIZES];
    if (!sizesArray)
        sizesArray = [[NSMutableArray alloc] init];
    NSMutableArray *readableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *size in sizesArray) {
        [readableArray addObject:[[PrintableSize alloc] initWithPackedSize:size]];
    }
    return readableArray;
}
+ (void)resetPartnerDownloadStatus {
    [self writeObjectToDefaults:KEY_PARTER_DOWNLOAD_DATE value:[NSDate date]];
}
+ (BOOL)needPartnerInfo {
    NSDate *currDate = [NSDate date];
    NSDate *lastDate = (NSDate *)[self readObjectFromDefaults:KEY_PARTER_DOWNLOAD_DATE];
    
    if (lastDate) {
        NSTimeInterval diff = [currDate timeIntervalSinceDate:lastDate];
        if (diff > PARTNER_DOWNLOAD_INTERVAL)
            return YES;
        else
            return NO;
    }
    
    return YES;
}

+ (void)resetSizeDownloadStatus {
    [self writeObjectToDefaults:KEY_DOWNLOAD_IMAGE_SIZE_DATE value:[NSDate date]];
}

+ (BOOL)needDownloadSizes {
    NSDate *currDate = [NSDate date];
    NSDate *lastDate = (NSDate *)[self readObjectFromDefaults:KEY_DOWNLOAD_IMAGE_SIZE_DATE];
    
    if (lastDate) {
        NSTimeInterval diff = [currDate timeIntervalSinceDate:lastDate];
        if (diff > DOWNLOAD_INTERVAL)
            return YES;
        else
            return NO;
    }
    
    return YES;
}
+ (void)resetAddressDownloadStatus {
    [self writeObjectToDefaults:KEY_ADDRESS_DOWNLOAD_DATE value:[NSDate date]];
}
+ (BOOL)needDownloadAddresses {
    NSDate *currDate = [NSDate date];
    NSDate *lastDate = (NSDate *)[self readObjectFromDefaults:KEY_ADDRESS_DOWNLOAD_DATE];
    
    if (lastDate) {
        NSTimeInterval diff = [currDate timeIntervalSinceDate:lastDate];
        if (diff > DOWNLOAD_INTERVAL)
            return YES;
        else
            return NO;
    }
    
    return YES;
}
+ (void)resetDownloadCountryStatus {
    [self writeObjectToDefaults:KEY_COUNTRY_DOWNLOAD_DATE value:[NSDate date]];
}
+ (BOOL)needDownloadCountries {
    NSDate *currDate = [NSDate date];
    NSDate *lastDate = (NSDate *)[self readObjectFromDefaults:KEY_COUNTRY_DOWNLOAD_DATE];
    
    if (lastDate) {
        NSTimeInterval diff = [currDate timeIntervalSinceDate:lastDate];
        if (diff > DOWNLOAD_INTERVAL)
            return YES;
        else
            return NO;
    }
    
    return YES;
}

+ (NSArray *) getCountries {
    NSArray *val = (NSArray *)[self readObjectFromDefaults:KEY_COUNTRIES];
    if (!val)
        return [[NSArray alloc] init];
    return val;
}
+ (void) setCountries:(NSArray *)countries {
    [self writeObjectToDefaults:KEY_COUNTRIES value:countries];
}

+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
