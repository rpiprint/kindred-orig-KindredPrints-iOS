//
//  PrintableSize.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *PRODUCT_ID = @"id";
static NSString *PRODUCT_PRICE = @"price";
static NSString *PRODUCT_TITLE = @"title";
static NSString *PRODUCT_DESC = @"description";
static NSString *PRODUCT_HEIGHT = @"trim_height";
static NSString *PRODUCT_WIDTH = @"trim_width";
static NSString *PRODUCT_BORDER_PERCENTAGE = @"border_percentage";
static NSString *PRODUCT_MIN_DPI = @"min_dpi";
static NSString *PRODUCT_WARN_DPI = @"warn_dpi";
static NSString *PRODUCT_TYPE = @"type";

static NSString *PRODUCT_DPI = @"dpi";
static NSString *PRODUCT_QUANTITY = @"quantity";
static NSString *PRODUCT_PHEIGHT = @"prev_height";
static NSString *PRODUCT_PWIDTH = @"prev_width";
static NSString *PRODUCT_THEIGHT = @"thumb_height";
static NSString *PRODUCT_TWIDTH = @"thumb_width";

@interface PrintableSize : NSObject

- (PrintableSize *) initWithDictionary:(NSDictionary *)serverObject;
- (PrintableSize *) initWithPackedSize:(NSDictionary *)savedObject;
- (NSDictionary *) packSize;

- (PrintableSize *)copy;

@property (nonatomic, assign) NSString *sid;
@property (nonatomic, assign) NSString *sTitle;
@property (nonatomic, assign) NSString *sDescription;
@property (nonatomic) NSInteger sPrice;
@property (nonatomic) CGSize sTrimmedSize;
@property (nonatomic) CGFloat sBorderPerc;
@property (nonatomic) CGFloat sMinDPI;
@property (nonatomic) CGFloat sWarnDPI;
@property (nonatomic, strong) NSString *sType;

@property (nonatomic) CGFloat sDPI;
@property (nonatomic) CGSize sPreviewSize;
@property (nonatomic) CGSize sThumbSize;
@property (nonatomic) NSInteger sQuantity;

@end
