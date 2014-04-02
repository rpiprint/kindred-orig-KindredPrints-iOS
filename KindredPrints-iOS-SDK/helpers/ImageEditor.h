//
//  ImageEditor.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintableSize.h"

@interface ImageEditor : NSObject

+ (NSArray *)getAllowablePrintableSizesForImageSize:(CGSize)size;
+ (PrintableSize *)getDefaultPrintableSizeForImageSize:(CGSize)size;
+ (UIImage *)formatImage:(UIImage *)original offset:(CGFloat)offset scaledSize:(CGSize)size borderSize:(CGFloat)borderSize borderColor:(UIColor *)color;
+ (UIImage *)resizeImage:(UIImage *)original scaledSize:(CGSize)size;

@end
