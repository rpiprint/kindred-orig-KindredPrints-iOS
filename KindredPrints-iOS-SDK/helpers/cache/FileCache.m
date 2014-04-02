//
//  FileCache.m
//  KindredPrints
//
//  Created by Alex Austin on 12/28/13.
//  Copyright (c) 2013 Pawprint Labs, Inc. All rights reserved.
//

#import "FileCache.h"
#import "PreferenceHelper.h"

#define MAX_CACHE_SIZE 80

@interface FileCache()
@property (nonatomic) dispatch_semaphore_t agequeue_sema;
@property (nonatomic) dispatch_semaphore_t namecache_sema;

@property (strong, nonatomic) NSMutableDictionary *fnameCache;
@property (strong, nonatomic) NSMutableArray *ageQueue;
@property (strong, nonatomic) NSFileManager *fManager;
@property (strong, nonatomic) NSURL *storageUrl;

@end

@implementation FileCache

static NSString *FILE_LIST = @"curr_file_list";
static NSString *AGE_QUEUE = @"curr_file_age_queue";
static NSString *IMG_DIRECTORY = @"kindredimg/";

static FileCache *cache;

- (NSURL *)storageUrl {
    if (!_storageUrl) {
        _storageUrl = [[self.fManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
        _storageUrl = [_storageUrl URLByAppendingPathComponent:IMG_DIRECTORY];
        BOOL isDir;
        if (![self.fManager fileExistsAtPath:[_storageUrl path] isDirectory:&isDir]) {
            NSError *err;
            [self.fManager createDirectoryAtURL:_storageUrl withIntermediateDirectories:YES attributes:nil error:&err];
        }
    }
    return _storageUrl;
}

- (NSFileManager *)fManager {
    if (!_fManager) _fManager = [[NSFileManager alloc] init];
    return _fManager;
}

- (NSMutableDictionary *)fnameCache {
    //[self initFromDisk];
    if (!_fnameCache) {
        _fnameCache = (NSMutableDictionary *)[PreferenceHelper readObjectFromDefaults:FILE_LIST];
        if (!_fnameCache) _fnameCache = [[NSMutableDictionary alloc] init];
    }
    return _fnameCache;
}

- (NSMutableArray *)ageQueue {
    if (!_ageQueue) {
        _ageQueue = (NSMutableArray *) [PreferenceHelper readObjectFromDefaults:AGE_QUEUE];
        if (!_ageQueue) _ageQueue = [[NSMutableArray alloc] init];
    }
    return _ageQueue;
}

+ (FileCache *) getInstance {
    if (!cache) {
        cache = [[FileCache alloc] init];
        cache.agequeue_sema = dispatch_semaphore_create(1);
        cache.namecache_sema = dispatch_semaphore_create(1);
    }
    return cache;
}

- (void) addImage:(UIImage *)image forKey:(NSString *)key {
    if ([self.fnameCache count] > MAX_CACHE_SIZE) {
        [self ejectOldestItem];
    }
    if (![self refreshKeyIfExist:key]) {
        dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
        [self.ageQueue addObject:key];
        dispatch_semaphore_signal(self.agequeue_sema);
    }
    NSString *fname = [key stringByAppendingString:@".jpg"];
    NSURL *fileUrl = [self.storageUrl URLByAppendingPathComponent:fname];
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    [self.fnameCache setObject:fname forKey:key];
    dispatch_semaphore_signal(self.namecache_sema);
    NSData *imgData = UIImageJPEGRepresentation(image, 95);
    [imgData writeToURL:fileUrl atomically:NO];
    [self updateDisk];
}

- (UIImage *) getImageForKey:(NSString *)key {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    NSString *fname = [self.fnameCache objectForKey:key];
    dispatch_semaphore_signal(self.namecache_sema);
    if (fname) {
        NSURL *fileUrl = [self.storageUrl URLByAppendingPathComponent:fname];
        if ([self.fManager fileExistsAtPath:[fileUrl path]]) {
            [self refreshKeyIfExist:key];
            return [UIImage imageWithContentsOfFile:[fileUrl path]];
        } else
            [self deleteImageForKey:key];
    }
    [self updateDisk];
    return nil;
}

- (void) deleteImageForKey:(NSString *)key {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
    NSString *fname = [self.fnameCache objectForKey:key];
    NSURL *fileUrl = [self.storageUrl URLByAppendingPathComponent:fname];
    if ([self.fManager fileExistsAtPath:[fileUrl path]])
        [self.fManager removeItemAtURL:fileUrl error:nil];
    [self.fnameCache removeObjectForKey:key];
    [self.ageQueue removeObject:key];
    dispatch_semaphore_signal(self.namecache_sema);
    dispatch_semaphore_signal(self.agequeue_sema);
    [self updateDisk];
}

- (BOOL) hasImageForKey:(NSString *)key {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    NSString *fname = [self.fnameCache objectForKey:key];
    dispatch_semaphore_signal(self.namecache_sema);
    if (fname) {
        NSURL *fileUrl = [self.storageUrl URLByAppendingPathComponent:fname];
        if ([self.fManager fileExistsAtPath:[fileUrl path]])
            return YES;
        else
            [self deleteImageForKey:key];
    }
    return NO;
}

// refeshes position of key if exists in cache already (for ejection strategy)
- (BOOL) refreshKeyIfExist:(NSString *)key {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    if ([self.fnameCache objectForKey:key]) {
        dispatch_semaphore_signal(self.namecache_sema);
        dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
        for (int i = 0; i < [self.ageQueue count]; i++) {
            if ([[self.ageQueue objectAtIndex:i] isEqualToString:key]) {
                [self.ageQueue removeObjectAtIndex:i];
                [self.ageQueue addObject:key];
                dispatch_semaphore_signal(self.agequeue_sema);
                [self updateDisk];
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
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
    if ([self.ageQueue count] > 0) {
        NSString *oldestObj = [self.ageQueue objectAtIndex:0];
        NSString *fname = [self.fnameCache objectForKey:oldestObj];
        // delete object
        NSURL *fileUrl = [self.storageUrl URLByAppendingPathComponent:fname];
        if ([self.fManager fileExistsAtPath:[fileUrl path]])
            [self.fManager removeItemAtURL:fileUrl error:nil];
        [self.fnameCache removeObjectForKey:oldestObj];
        [self.ageQueue removeObjectAtIndex:0];
    }
    dispatch_semaphore_signal(self.namecache_sema);
    dispatch_semaphore_signal(self.agequeue_sema);
    [self updateDisk];
    
}

- (void) updateDisk {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    [PreferenceHelper writeObjectToDefaults:FILE_LIST value:self.fnameCache];
    dispatch_semaphore_signal(self.namecache_sema);
    dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
    [PreferenceHelper writeObjectToDefaults:AGE_QUEUE value:self.ageQueue];
    dispatch_semaphore_signal(self.agequeue_sema);
}

- (void) initAgeQueueFromDisk {
    dispatch_semaphore_wait(self.agequeue_sema, DISPATCH_TIME_FOREVER);
    self.ageQueue = (NSMutableArray *)[PreferenceHelper readObjectFromDefaults:AGE_QUEUE];
    dispatch_semaphore_signal(self.agequeue_sema);
}
- (void) initFnameCacheFromDisk {
    dispatch_semaphore_wait(self.namecache_sema, DISPATCH_TIME_FOREVER);
    self.fnameCache = (NSMutableDictionary *)[PreferenceHelper readObjectFromDefaults:FILE_LIST];
    dispatch_semaphore_signal(self.namecache_sema);
}

@end
