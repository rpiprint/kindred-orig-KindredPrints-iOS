//
//  FileCache.h
//  KindredPrints
//
//  Created by Alex Austin on 12/28/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject

+ (FileCache *) getInstance;
- (void) addImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *) getImageForKey:(NSString *)key;
- (void) deleteImageForKey:(NSString *)key;
- (BOOL) hasImageForKey:(NSString *)key;

@end
