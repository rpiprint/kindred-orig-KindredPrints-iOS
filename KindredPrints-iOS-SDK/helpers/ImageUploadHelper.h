//
//  ImageUploadHelper.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImage.h"

@protocol ImageUploadDelegate <NSObject>

@optional
- (void)uploadsHaveCompleted;
- (void)uploadsHaveFailed;
- (void)uploadFinishedWithOverallProgress:(CGFloat)progress processedCount:(NSInteger)processed andTotal:(NSInteger)total;
@end

@interface ImageUploadHelper : NSObject

@property (nonatomic, strong) id <ImageUploadDelegate> delegate;

+ (ImageUploadHelper *) getInstance;
- (void) imageReadyForUpload:(BaseImage *)image;
- (void) validateAllOrdersInit;
- (void) clearAllQueue;

@end
