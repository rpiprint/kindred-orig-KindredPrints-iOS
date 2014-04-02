//
//  ProductPreviewCell.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseImage.h"
#import "PrintableSize.h"

static NSString *PRODUCT_PREVIEW_CELL = @"kp_product_preview";
static CGFloat IMAGE_SIZE_PERC = 0.6;
static CGFloat ROW_HEIGHT_PERCENT = 0.65;


@protocol ProductPreviewDelegate <NSObject>

@optional
- (void)updateProductWithSize:(PrintableSize *)size andDeltaPrice:(NSInteger)deltaPrice;
@end

@interface ProductPreviewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPhoto:(BaseImage *)image withSize:(PrintableSize *)size;
- (void)updateDisplayForImage:(BaseImage *)order andSize:(PrintableSize *)size;

@property (nonatomic, strong) id <ProductPreviewDelegate> delegate;


@end
