//
//  ImagePreviewCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "BaseImage.h"
#import "PrintableSize.h"

static NSString *IMAGE_PREVIEW_CELL = @"kp_image_cell";

@protocol ImagePreviewDelegate <NSObject>

@optional
- (void)userRequestedDelete;
- (void)userRequestedGoBackAPage;
- (void)userRequestedGoForwardAPage;
@end


@interface ImagePreviewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPhoto:(BaseImage *)image atIndex:(NSInteger)index;
- (void) resizeImageViewWithImage;
- (void) updateDisplayForProduct:(PrintableSize *)product;
- (void) showWaringIcon;

@property (nonatomic, strong) id <ImagePreviewDelegate> delegate;


@end
