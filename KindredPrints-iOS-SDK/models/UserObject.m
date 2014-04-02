//
//  UserObject.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/6/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "UserObject.h"

@implementation UserObject

- (UserObject *)initWithId:(NSString *)userId andName:(NSString *)name andEmail:(NSString *)email andAuthKey:(NSString *)authKey andPaymentSaved:(BOOL)paymentSaved {
    self.uId = userId;
    self.uEmail = email;
    self.uName = name;
    self.uAuthKey = authKey;
    self.uPaymentSaved = paymentSaved;
    self.uCreditType = @"";
    self.uLastFour = @"";
    
    return self;
}

- (UserObject *) initWithPackedUser:(NSDictionary *)savedObject {
    self.uId = [savedObject objectForKey:USER_ID];
    self.uName = [savedObject objectForKey:USER_NAME];
    self.uEmail = [savedObject objectForKey:USER_EMAIL];
    self.uAuthKey = [savedObject objectForKey:USER_AUTH_KEY];
    self.uPaymentSaved = [[savedObject objectForKey:USER_PAYMENT_SAVED] boolValue];
    self.uCreditType = [savedObject objectForKey:USER_CREDIT_TYPE];
    self.uLastFour = [savedObject objectForKey:USER_LAST_FOUR];
    return self;
}

- (NSDictionary *) packUser {
    NSDictionary *packedUser = [[NSDictionary alloc]
                                initWithObjects:@[
                                                  self.uId,
                                                  self.uName,
                                                  self.uEmail,
                                                  self.uAuthKey,
                                                  self.uCreditType,
                                                  self.uLastFour,
                                                  [NSNumber numberWithBool:self.uPaymentSaved]]
                                forKeys:@[USER_ID,
                                          USER_NAME,
                                          USER_EMAIL,
                                          USER_AUTH_KEY,
                                          USER_CREDIT_TYPE,
                                          USER_LAST_FOUR,
                                          USER_PAYMENT_SAVED]];
    return packedUser;
}


@end
