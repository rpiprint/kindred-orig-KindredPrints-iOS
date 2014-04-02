//
//  PrintableSize.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "PrintableSize.h"
#import "InterfacePreferenceHelper.h"

@implementation PrintableSize

- (PrintableSize *) initWithDictionary:(NSDictionary *)serverObject {
    self.sQuantity = 1;
    self.sid = [serverObject objectForKey:PRODUCT_ID];
    self.sTitle = [serverObject objectForKey:PRODUCT_TITLE];
    self.sDescription = [serverObject objectForKey:PRODUCT_DESC];
    self.sTrimmedSize = CGSizeMake([[serverObject objectForKey:PRODUCT_WIDTH] floatValue], [[serverObject objectForKey:PRODUCT_HEIGHT] floatValue]);
    self.sPrice = [[serverObject objectForKey:PRODUCT_PRICE] integerValue];
    self.sBorderPerc = [[serverObject objectForKey:PRODUCT_BORDER_PERCENTAGE] floatValue];
    self.sMinDPI = [[serverObject objectForKey:PRODUCT_MIN_DPI] floatValue];
    self.sWarnDPI = [[serverObject objectForKey:PRODUCT_WARN_DPI] floatValue];
    self.sDPI = self.sWarnDPI+1;
    self.sType = [serverObject objectForKey:PRODUCT_TYPE];
    
    if (self.sTrimmedSize.width >= self.sTrimmedSize.height) {
        self.sThumbSize = CGSizeMake([InterfacePreferenceHelper getPictureThumbSize], [InterfacePreferenceHelper getPictureThumbSize]*self.sTrimmedSize.height/self.sTrimmedSize.width);
        self.sPreviewSize = CGSizeMake([InterfacePreferenceHelper getPicturePreviewSize] , [InterfacePreferenceHelper getPicturePreviewSize]*self.sTrimmedSize.height/self.sTrimmedSize.width);
    } else {
        self.sThumbSize = CGSizeMake([InterfacePreferenceHelper getPictureThumbSize]*self.sTrimmedSize.width/self.sTrimmedSize.height, [InterfacePreferenceHelper getPictureThumbSize]);
        self.sPreviewSize = CGSizeMake([InterfacePreferenceHelper getPicturePreviewSize]*self.sTrimmedSize.width/self.sTrimmedSize.height, [InterfacePreferenceHelper getPicturePreviewSize]);
    }
    return self;
}

- (PrintableSize *)copy {
    PrintableSize *newCopy = [[PrintableSize alloc] initWithPackedSize:[self packSize]];
    return newCopy;
}

- (PrintableSize *) initWithPackedSize:(NSDictionary *)savedObject {
    self.sid = [savedObject objectForKey:PRODUCT_ID];
    self.sTitle = [savedObject objectForKey:PRODUCT_TITLE];
    self.sDescription = [savedObject objectForKey:PRODUCT_DESC];
    self.sTrimmedSize = CGSizeMake([[savedObject objectForKey:PRODUCT_WIDTH] floatValue], [[savedObject objectForKey:PRODUCT_HEIGHT] floatValue]);
    self.sPrice = [[savedObject objectForKey:PRODUCT_PRICE] integerValue];
    self.sQuantity = [[savedObject objectForKey:PRODUCT_QUANTITY] integerValue];
    self.sBorderPerc = [[savedObject objectForKey:PRODUCT_BORDER_PERCENTAGE] floatValue];
    self.sMinDPI = [[savedObject objectForKey:PRODUCT_MIN_DPI] floatValue];
    self.sWarnDPI = [[savedObject objectForKey:PRODUCT_WARN_DPI] floatValue];
    self.sType = [savedObject objectForKey:PRODUCT_TYPE];
    self.sDPI = [[savedObject objectForKey:PRODUCT_DPI] floatValue];

    self.sThumbSize = CGSizeMake([[savedObject objectForKey:PRODUCT_TWIDTH] floatValue], [[savedObject objectForKey:PRODUCT_THEIGHT] floatValue]);
    self.sPreviewSize = CGSizeMake([[savedObject objectForKey:PRODUCT_PWIDTH] floatValue], [[savedObject objectForKey:PRODUCT_PHEIGHT] floatValue]);
    return self;
}

- (NSDictionary *) packSize {
    NSDictionary * packedSize = [[NSDictionary alloc]
                                 initWithObjects:@[
                                                   self.sid,
                                                   self.sTitle,
                                                   self.sDescription,
                                                   [NSNumber numberWithFloat:self.sTrimmedSize.height],
                                                   [NSNumber numberWithFloat:self.sTrimmedSize.width],
                                                   [NSNumber numberWithInteger:self.sPrice],
                                                   [NSNumber numberWithInteger:self.sQuantity],
                                                   [NSNumber numberWithFloat:self.sMinDPI],
                                                   [NSNumber numberWithFloat:self.sWarnDPI],
                                                   [NSNumber numberWithFloat:self.sBorderPerc],
                                                   self.sType,
                                                   [NSNumber numberWithFloat:self.sDPI],
                                                   [NSNumber numberWithFloat:self.sThumbSize.width],
                                                   [NSNumber numberWithFloat:self.sThumbSize.height],
                                                   [NSNumber numberWithFloat:self.sPreviewSize.width],
                                                   [NSNumber numberWithFloat:self.sPreviewSize.height],]
                                 forKeys:@[
                                           PRODUCT_ID,
                                           PRODUCT_TITLE,
                                           PRODUCT_DESC,
                                           PRODUCT_HEIGHT,
                                           PRODUCT_WIDTH,
                                           PRODUCT_PRICE,
                                           PRODUCT_QUANTITY,
                                           PRODUCT_MIN_DPI,
                                           PRODUCT_WARN_DPI,
                                           PRODUCT_BORDER_PERCENTAGE,
                                           PRODUCT_TYPE,
                                           PRODUCT_DPI,
                                           PRODUCT_TWIDTH,
                                           PRODUCT_THEIGHT,
                                           PRODUCT_PWIDTH,
                                           PRODUCT_PHEIGHT]];
    return packedSize;
}

@end
