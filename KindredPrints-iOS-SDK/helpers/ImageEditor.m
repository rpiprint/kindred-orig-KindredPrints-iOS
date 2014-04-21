//
//  ImageEditor.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "ImageEditor.h"
#import "DevPreferenceHelper.h"

@implementation ImageEditor

static CGFloat SQUARE_TOLERANCE = 0.15f;


+ (NSArray *)getAllowablePrintableSizesForImageSize:(CGSize)size andFilter:(NSString *)filter {
    NSArray *sizes = [DevPreferenceHelper getCurrentSizes];
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    for (PrintableSize *savedSize in sizes) {
        if ([self isSquare:size] && savedSize.sTrimmedSize.width == savedSize.sTrimmedSize.height && [self matchesFilter:savedSize filter:filter]) {
            [outputArray addObject:savedSize];
        } else if (![self isSquare:size] && savedSize.sTrimmedSize.height != savedSize.sTrimmedSize.width && [self matchesFilter:savedSize filter:filter]) {
            [outputArray addObject:savedSize];
        }
    }
    return outputArray;
}

+ (PrintableSize *)getDefaultPrintableSizeForImageSize:(CGSize)size andFilter:(NSString *)filter{
    NSArray *sizes = [ImageEditor getAllowablePrintableSizesForImageSize:size andFilter:filter];
    
    PrintableSize *maxDPISize;
    CGFloat maxDPI = 0;
    for (PrintableSize *savedSize in sizes) {
        if (size.height/savedSize.sTrimmedSize.height > maxDPI) {
            maxDPI = size.height/savedSize.sTrimmedSize.height;
            maxDPISize = savedSize;
        }
    }
    
    return maxDPISize;
}

+ (BOOL)matchesFilter:(PrintableSize *)printProduct filter:(NSString *)filter {
    if ([filter isEqualToString:FILTER_NONE]) {
        if ([printProduct.sType rangeOfString:FILTER_DOUBLESIDE].location != NSNotFound) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return [printProduct.sType rangeOfString:FILTER_DOUBLESIDE].location != NSNotFound;
    }
}

+ (BOOL)isSquare:(CGSize) size {
    CGFloat delta = fabsf(size.width-size.height);
    float tolerance = 0.0f;
    if (size.width > size.height) {
        tolerance = size.width*SQUARE_TOLERANCE;
    } else {
        tolerance = size.height*SQUARE_TOLERANCE;
    }
    if (delta < tolerance) {
        return YES;
    }
    return NO;
}

+ (UIImage *)cropAndRotateForThumbnail:(UIImage *)original scaledSize:(CGSize)size {
    CGImageRef croppedBitmap = [self cropSquare:original offset:-1];
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(croppedBitmap);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(croppedBitmap);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(croppedBitmap);
    
    CGContextRef drawingPad = CGBitmapContextCreate(NULL, size.width, size.height, bitsPerComponent, 0, colorSpaceInfo, bitmapInfo);
    
    CGSize newSize = [self concatRotateOpsFromOrient:drawingPad size:size orientation:original.imageOrientation];
    CGRect croppedSquare = CGRectMake(0, 0, newSize.width, newSize.height);
    
    CGContextDrawImage(drawingPad, croppedSquare, croppedBitmap);
    CGImageRef ref = CGBitmapContextCreateImage(drawingPad);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGImageRelease(croppedBitmap);
    CGContextRelease(drawingPad);
    CGImageRelease(ref);

    return newImage;
}

+ (UIImage *)resizeImage:(UIImage *)original scaledSize:(CGSize)size {
    //size.height = size.height * 2;
    //size.width = size.width * 2;
    CGImageRef img = [original CGImage];
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(img);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(img);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(img);
    
    CGContextRef drawingPad = CGBitmapContextCreate(NULL, size.width, size.height, bitsPerComponent, 0, colorSpaceInfo, bitmapInfo);
    
    size = [self concatRotateOpsFromOrient:drawingPad size:size orientation:original.imageOrientation];
    
    CGContextDrawImage(drawingPad, CGRectMake(0, 0, size.width, size.height), img);
    CGImageRef ref = CGBitmapContextCreateImage(drawingPad);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(drawingPad);
    CGImageRelease(ref);
    
    return newImage;
}

+ (UIImage *)formatImage:(UIImage *)original offset:(CGFloat)offset scaledSize:(CGSize)size borderSize:(CGFloat)borderSize borderColor:(UIColor *)color {
    size.height = size.height * 2;
    size.width = size.width * 2;
    borderSize = borderSize * 2;
    
    CGImageRef croppedBitmap = nil;
    CGRect imageDrawingSquare = CGRectMake(borderSize, borderSize, size.width - 2*borderSize, size.height - 2*borderSize);

    if ([self isSquare:size]) {
        croppedBitmap = [self cropSquare:original offset:offset];
    } else {
        croppedBitmap = [self cropRectangle:original size:imageDrawingSquare.size offset:offset];
    }
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(croppedBitmap);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(croppedBitmap);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(croppedBitmap);
    
    CGContextRef drawingPad = CGBitmapContextCreate(NULL, size.width, size.height, bitsPerComponent, 0, colorSpaceInfo, bitmapInfo);
    
    CGSize newSize = [self concatRotateOpsFromOrient:drawingPad size:size orientation:original.imageOrientation];
    imageDrawingSquare.size.width = newSize.width;
    imageDrawingSquare.size.height = newSize.height;
    if (borderSize > 0) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        CGFloat red = components[0], green = components[1], blue = components[2], alpha = components[3];
        CGContextSetRGBFillColor(drawingPad, red, green, blue, alpha);
        CGContextFillRect(drawingPad, CGRectMake(0, 0, newSize.width, newSize.height));
        imageDrawingSquare.origin.x = borderSize;
        imageDrawingSquare.origin.y = borderSize;
        imageDrawingSquare.size.width = imageDrawingSquare.size.width - 2*borderSize;
        imageDrawingSquare.size.height = imageDrawingSquare.size.height - 2*borderSize;
    }
    
    CGContextDrawImage(drawingPad, imageDrawingSquare, croppedBitmap);
    CGImageRef ref = CGBitmapContextCreateImage(drawingPad);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGImageRelease(croppedBitmap);
    CGContextRelease(drawingPad);
    CGImageRelease(ref);
    
    return newImage;

}

+ (CGImageRef)cropSquare:(UIImage *)original offset:(CGFloat)offset {
    CGFloat startWidth = original.size.width;
    CGFloat startHeight = original.size.height;
    
    int side = startWidth;
    if (startWidth > startHeight)
        side = startHeight;
    
    int x = (startWidth - side)/2;
    int y = (startHeight - side)/2;
    
    if (offset >= 0) {
        if (startWidth >= startHeight) {
            x = offset * startWidth;
        } else {
            y = offset * startHeight;
        }
    }
    
    CGRect cropSquare = CGRectMake(x, y, side, side);
    return CGImageCreateWithImageInRect([original CGImage], cropSquare);
}

+ (CGImageRef)cropRectangle:(UIImage *)original size:(CGSize)size offset:(CGFloat)offset {
    CGFloat startWidth = original.size.width;
    CGFloat startHeight = original.size.height;
    CGFloat xSide = startWidth;
    CGFloat ySide = startHeight;
    
    CGFloat actualAspectRatio = startHeight/startWidth;
    CGFloat idealAspectRatio = size.height/size.width;
    
    xSide = actualAspectRatio < idealAspectRatio ? ySide/idealAspectRatio : startWidth;
    ySide = actualAspectRatio < idealAspectRatio ? startHeight : xSide*idealAspectRatio;
    CGFloat x = (startWidth-xSide)/2;
    CGFloat y = (startHeight-ySide)/2;
    
    CGRect rotatedRect = [self rotateRectAppropriately:CGRectMake(x, y, xSide, ySide) orientation:original.imageOrientation];
    
    return CGImageCreateWithImageInRect([original CGImage], rotatedRect);
}
+ (CGRect) rotateRectAppropriately:(CGRect)rect orientation:(UIImageOrientation)orient {
    if (orient == UIImageOrientationLeft || orient == UIImageOrientationRight) {
        CGFloat xTemp = rect.origin.x;
        CGFloat widthTemp = rect.size.width;
        rect.size.width = rect.size.height;
        rect.size.height = widthTemp;
        rect.origin.x = rect.origin.y;
        rect.origin.y = xTemp;
    }
    return rect;
}
+ (CGSize) concatRotateOpsFromOrient:(CGContextRef)drawingPad size:(CGSize)size orientation:(UIImageOrientation)orient  {
    if (orient == UIImageOrientationLeft) {
        CGContextRotateCTM (drawingPad, M_PI_2); // + 90 degrees
        CGFloat widthTemp = size.width;
        size.width = size.height;
        size.height = widthTemp;
        CGContextTranslateCTM (drawingPad, 0, -size.height);
    } else if (orient == UIImageOrientationRight) {
        CGContextRotateCTM (drawingPad, -M_PI_2); // - 90 degrees
        CGFloat widthTemp = size.width;
        size.width = size.height;
        size.height = widthTemp;
        CGContextTranslateCTM (drawingPad, -size.width, 0);
    } else if (orient == UIImageOrientationDown) {
        CGContextTranslateCTM (drawingPad, size.width, size.height);
        CGContextRotateCTM (drawingPad, -M_PI); // - 180 degrees
    }
    return size;
}

@end
