//
//  PhotoCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 4/18/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *CELL_ID = @"PhotoCell";

@interface PhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *checkedOverlay;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

-(void) setUnchecked;
-(void) setChecked;

@end
