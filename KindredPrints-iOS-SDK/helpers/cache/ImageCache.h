//
//  ImageCache.h
//  KindredPrints
//
//  Created by Alex on 7/29/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+ (ImageCache *) getInstance;
- (void) addImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *) getImageForKey:(NSString *)key;
- (void) removeImage:(NSString *)key;
//- (void) startFetching:(NSString *)key;
- (BOOL) hasImage:(NSString *)key;
//- (BOOL) willHaveObject:(NSString *)key;
- (void) setCacheSize:(NSInteger) size;

@end
