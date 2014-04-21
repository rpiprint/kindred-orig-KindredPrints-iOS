//
//  ImageEditor.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintableSize.h"

static NSString *FILTER_NONE = @"kp_no_filter";
static NSString *FILTER_DOUBLESIDE = @"doublesided";

@interface ImageEditor : NSObject

+ (NSArray *)getAllowablePrintableSizesForImageSize:(CGSize)size andFilter:(NSString *)filter;
+ (PrintableSize *)getDefaultPrintableSizeForImageSize:(CGSize)size andFilter:(NSString *)filter;
+ (UIImage *)formatImage:(UIImage *)original offset:(CGFloat)offset scaledSize:(CGSize)size borderSize:(CGFloat)borderSize borderColor:(UIColor *)color;
+ (UIImage *)resizeImage:(UIImage *)original scaledSize:(CGSize)size;
+ (UIImage *)cropAndRotateForThumbnail:(UIImage *)original scaledSize:(CGSize)size;

@end
