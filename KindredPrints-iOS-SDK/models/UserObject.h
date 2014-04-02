//
//  UserObject.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/6/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *USER_VALUE_NONE = @"kp_no_user";

static NSString *USER_ID = @"kp_user_id";
static NSString *USER_NAME = @"kp_user_name";
static NSString *USER_EMAIL = @"kp_user_email";
static NSString *USER_AUTH_KEY = @"kp_user_authkey";
static NSString *USER_CREDIT_TYPE = @"kp_user_credit_type";
static NSString *USER_LAST_FOUR = @"kp_user_last_four";
static NSString *USER_PAYMENT_SAVED = @"kp_user_payment_saved";

@interface UserObject : NSObject

@property (strong, nonatomic) NSString *uId;
@property (strong, nonatomic) NSString *uName;
@property (strong, nonatomic) NSString *uEmail;
@property (strong, nonatomic) NSString *uAuthKey;
@property (strong, nonatomic) NSString *uCreditType;
@property (strong, nonatomic) NSString *uLastFour;
@property (nonatomic) BOOL uPaymentSaved;

- (UserObject *)initWithId:(NSString *)userId andName:(NSString *)name andEmail:(NSString *)email andAuthKey:(NSString *)authKey andPaymentSaved:(BOOL)paymentSaved;
- (UserObject *) initWithPackedUser:(NSDictionary *)savedObject;
- (NSDictionary *) packUser;

@end
