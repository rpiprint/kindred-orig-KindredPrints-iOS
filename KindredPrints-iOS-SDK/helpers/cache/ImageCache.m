//
//  ImageCache.m
//  KindredPrints
//
//  Created by Alex on 7/29/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//

#import "ImageCache.h"
#import "PreferenceHelper.h"

#define MAX_CACHE_SIZE 80

@interface ImageCache()

@property (nonatomic) NSInteger currCacheSize;
@property (strong, nonatomic) NSMutableDictionary *cache;
@property (strong, nonatomic) NSMutableArray *ageQueue;

@property (nonatomic) dispatch_semaphore_t agequeue_sema;
@property (nonatomic) dispatch_semaphore_t namecache_sema;

@end

@implementation ImageCache

static ImageCache *imageCache;

// Lazy instantiation
- (NSMutableDictionary *)cache {
    if (!_cache) {
        _cache = [[NSMutableDictionary alloc] init];
        self.currCacheSize = MAX_CACHE_SIZE;
    }
    return _cache;
}

- (NSMutableArray *)ageQueue {
    if (!_ageQueue) _ageQueue = [[NSMutableArray alloc] init];
    return _ageQueue;
}

// static getter
+ (ImageCache *) getInstance {
    if (!imageCache) {
        imageCache = [[ImageCache alloc] init];
        imageCache.namecache_sema = dispatch_semaphore_create(1);
        imageCache.agequeue_sema = dispatch_semaphore_create(1);
    }
    return imageCache;
}

// flexible cache size
- (void) setCacheSize:(NSInteger) size {
    if (size < self.currCacheSize) {
        while ([self.cache count] > size) {
            [self ejectOldestItem];
        }
    }
    self.currCacheSize = size;
}

- (void) addImage:(UIImage *)image forKey:(NSString *)key {
    if ([self.cache count] > self.currCacheSize) {
        [self ejectOldestItem];
    }
    if (![self refreshKeyIfExist:key]) {
        dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
        [self.ageQueue addObject:key];
        dispatch_semaphore_signal(self.agequeue_sema);
    }
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    [self.cache setObject:image forKey:key];
    dispatch_semaphore_signal(self.namecache_sema);
}

- (void) removeImage:(NSString *)key {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);

    [self.ageQueue removeObject:key];
    [self.cache removeObjectForKey:key];
    
    dispatch_semaphore_signal(self.namecache_sema);
    dispatch_semaphore_signal(self.agequeue_sema);
}

- (BOOL) hasImage:(NSString *)key {
    return [self.cache objectForKey:key] != nil;
}

- (UIImage *) getImageForKey:(NSString *)key {
    [self refreshKeyIfExist:key];
    return [self.cache objectForKey:key];
}

// refeshes position of key if exists in cache already (for ejection strategy)
- (BOOL) refreshKeyIfExist:(NSString *)key {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    if ([self.cache objectForKey:key]) {
        dispatch_semaphore_signal(self.namecache_sema);
        dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
        for (int i = 0; i < [self.ageQueue count]; i++) {
            if ([[self.ageQueue objectAtIndex:i] isEqualToString:key]) {
                [self.ageQueue removeObjectAtIndex:i];
                [self.ageQueue addObject:key];
                dispatch_semaphore_signal(self.agequeue_sema);
                return YES;
            }
        }
        dispatch_semaphore_signal(self.agequeue_sema);
    } else {
        dispatch_semaphore_signal(self.namecache_sema);
    }
    return NO;
}

// eject last used item (first object in queue)
- (void) ejectOldestItem {
    dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    if ([self.ageQueue count] > 0) {
        NSString *oldestObj = [self.ageQueue objectAtIndex:0];
        [self.cache removeObjectForKey:oldestObj];
        [self.ageQueue removeObjectAtIndex:0];
    }
    dispatch_semaphore_signal(self.namecache_sema);
    dispatch_semaphore_signal(self.agequeue_sema);
}
@end
