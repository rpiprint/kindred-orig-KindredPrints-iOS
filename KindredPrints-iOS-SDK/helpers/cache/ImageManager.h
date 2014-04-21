//
//  ImageManager.h
//  KindredPrints
//
//  Created by Alex Austin on 12/28/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImage.h"
#import "KPImage.h"
#import "PrintableSize.h"
#import "InterfacePreferenceHelper.h"

typedef void (^asyncWithImage) (UIImage *image);
typedef void (^asyncFinished) ();

@protocol ImageManagerDelegate <NSObject>

@optional
- (void)imageInserted;
@end

@interface ImageManager : NSObject


@property (nonatomic, strong) id <ImageManagerDelegate> delegate;

+ (ImageManager *) GetInstance;

- (NSData *)getFullImage:(BaseImage *)image;

- (void) startPrefetchingOrigImageToCache:(BaseImage *)image;
- (void) cacheOrigImageFromMemory:(BaseImage *)image withImage:(UIImage *)imgData;

- (void) setImageAsync:(UIImageView *)view withImage:(BaseImage *)image displaySize:(PictureSize)displaySize atSize:(PrintableSize *)size;
- (void) setImageAsync:(UIImageView *)view andProgressView:(UIActivityIndicatorView *)progView withImage:(KPImage *)image andIndex:(NSInteger)index;

@end
