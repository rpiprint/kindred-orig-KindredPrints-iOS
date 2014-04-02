//
//  SelectedOrderImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/5/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "SelectedOrderImage.h"

@implementation SelectedOrderImage

- (SelectedOrderImage *) initWithImage:(BaseImage *)image andProduct:(PrintableSize *)product {
    self.oServerId = SERVER_ID_NONE;
    self.oServerInit = NO;
    self.oLineItemServerId = SERVER_ID_NONE;
    self.oLineItemServerInit = NO;
    self.oImage = [image copy];
    self.oProduct = [product copy];
    
    return self;
}

- (SelectedOrderImage *) initWithPackedOrder:(NSDictionary *)savedObject {
    self = [super init];
    self.oServerId = [savedObject objectForKey:SELECTED_ORDER_SERVER_ID];
    self.oServerInit = [[savedObject objectForKey:SELECTED_ORDER_SERVER_ID] boolValue];
    self.oLineItemServerId = [savedObject objectForKey:SELECTED_ORDER_LINEITEM_SERVER_ID];
    self.oLineItemServerInit = [[savedObject objectForKey:SELECTED_ORDER_LINEITEM_SERVER_INIT] boolValue];
    self.oImage = [[BaseImage alloc] initWithPackedImage:[savedObject objectForKey:SELECTED_ORDER_IMAGE]];
    self.oProduct = [[PrintableSize alloc] initWithPackedSize:[savedObject objectForKey:SELECTED_ORDER_PRINT]];
    return self;
}
- (NSDictionary *) packOrder {
    NSDictionary *packedOrder = [[NSDictionary alloc]
                                 initWithObjects:@[self.oServerId,
                                                   [NSNumber numberWithBool:self.oServerInit],
                                                   self.oLineItemServerId,
                                                   [NSNumber numberWithBool:self.oLineItemServerInit],
                                                   [self.oImage packImage],
                                                   [self.oProduct packSize]]
                                 forKeys:@[SELECTED_ORDER_SERVER_ID,
                                           SELECTED_ORDER_SERVER_INIT,
                                           SELECTED_ORDER_LINEITEM_SERVER_ID,
                                           SELECTED_ORDER_LINEITEM_SERVER_INIT,
                                           SELECTED_ORDER_IMAGE,
                                           SELECTED_ORDER_PRINT]
                                 ];
    return packedOrder;
}

@end
