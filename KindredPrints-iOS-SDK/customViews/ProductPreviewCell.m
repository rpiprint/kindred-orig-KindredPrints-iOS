//
//  ProductPreviewCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "ProductPreviewCell.h"
#import "QuantityControlView.h"
#import "InterfacePreferenceHelper.h"
#import "UserPreferenceHelper.h"
#import "ImageManager.h"

@interface ProductPreviewCell() <QuantityControlDelegate>

@property (strong, nonatomic) ImageManager *imManager;

@property (strong, nonatomic) UIButton *warningButton;
@property (strong, nonatomic) UIImageView *prevImageView;
@property (strong, nonatomic) UILabel *txtTitle;
@property (strong, nonatomic) UILabel *txtDesc;
@property (strong, nonatomic) QuantityControlView *viewQuantity;

@property (nonatomic, strong) PrintableSize *size;
@property (nonatomic, strong) BaseImage *image;

@end

@implementation ProductPreviewCell

static CGFloat WARNING_IMAGE_SIZE_PERC = 0.35;
static CGFloat WARN_PADDING = 5;
static CGFloat QUANTITY_VIEW_HEIGHT_PERC = 0.6;
static CGFloat TEXT_VIEW_HEIGHT_PERC = 1.2;

- (ImageManager *)imManager {
    if (!_imManager) {
        _imManager = [ImageManager GetInstance];
    }
    return _imManager;
}

- (UIImageView *)prevImageView {
    if (!_prevImageView) {
        _prevImageView = [[UIImageView alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCartPadding]+(self.frame.size.height-IMAGE_SIZE_PERC*self.size.sThumbSize.width)/2, (self.frame.size.height-IMAGE_SIZE_PERC*self.size.sThumbSize.height)/2, self.size.sThumbSize.width*IMAGE_SIZE_PERC, self.size.sThumbSize.height*IMAGE_SIZE_PERC)];
        [self addSubview:_prevImageView];
    }
    return _prevImageView;
}

- (UIButton *)warningButton {
    if (!_warningButton) {
        _warningButton = [[UIButton alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCartPadding]+WARN_PADDING, (1-WARNING_IMAGE_SIZE_PERC)*self.frame.size.height-WARN_PADDING, WARNING_IMAGE_SIZE_PERC*self.frame.size.height, WARNING_IMAGE_SIZE_PERC*self.frame.size.height)];
        [_warningButton setBackgroundColor:[UIColor clearColor]];
        [_warningButton setImage:[UIImage imageNamed:@"ico_warning_yellow"] forState:UIControlStateNormal];
        [_warningButton setHidden:YES];
        [_warningButton addTarget:self action:@selector(showWarningForImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_warningButton];
    }
    return _warningButton;
}
- (QuantityControlView *)viewQuantity {
    if (!_viewQuantity) {
        CGFloat qHeight = self.frame.size.height*QUANTITY_VIEW_HEIGHT_PERC;
        CGFloat qWidth = 3*qHeight;
        _viewQuantity = [[QuantityControlView alloc] initWithFrame:CGRectMake(self.frame.size.width-qWidth-[InterfacePreferenceHelper getCartPadding], (self.frame.size.height-qHeight)/2, qWidth, qHeight) andQuantity:self.size.sQuantity];
        _viewQuantity.delegate = self;
        [self addSubview:_viewQuantity];
    }
    return _viewQuantity;
}

- (UILabel *)txtTitle {
    if (!_txtTitle) {
        CGFloat txtWidth = self.frame.size.width-self.prevImageView.frame.size.width-self.prevImageView.frame.origin.x-self.viewQuantity.frame.size.width;
        _txtTitle = [[UILabel alloc] initWithFrame:CGRectMake([InterfacePreferenceHelper getCartPadding]+self.size.sThumbSize.width*IMAGE_SIZE_PERC+3*WARN_PADDING, (1-IMAGE_SIZE_PERC)*self.frame.size.height/2+(IMAGE_SIZE_PERC*self.frame.size.height-2*MenuButtonFontSize*TEXT_VIEW_HEIGHT_PERC)/2, txtWidth,MenuButtonFontSize*TEXT_VIEW_HEIGHT_PERC)];
        [_txtTitle setTextAlignment:NSTextAlignmentLeft];
        [_txtTitle setBackgroundColor:[UIColor clearColor]];
        [_txtTitle setTextColor:[UIColor whiteColor]];
        [_txtTitle setFont:[UIFont fontWithName:FONT_LIGHT size:MenuButtonFontSize]];
        [self addSubview:_txtTitle];
    }
    return _txtTitle;
}

- (UILabel *)txtDesc {
    if (!_txtDesc) {
        CGFloat txtWidth = self.frame.size.width-self.prevImageView.frame.size.width-self.prevImageView.frame.origin.x-self.viewQuantity.frame.size.width;
        _txtDesc = [[UILabel alloc] initWithFrame:CGRectMake(self.size.sThumbSize.width*IMAGE_SIZE_PERC+[InterfacePreferenceHelper getCartPadding]+3*WARN_PADDING, self.txtTitle.frame.origin.y+self.txtTitle.frame.size.height, txtWidth, MenuButtonFontSize*TEXT_VIEW_HEIGHT_PERC)];
        [_txtDesc setTextAlignment:NSTextAlignmentLeft];
        [_txtDesc setBackgroundColor:[UIColor clearColor]];
        [_txtDesc setTextColor:[UIColor whiteColor]];
        [_txtDesc setFont:[UIFont fontWithName:FONT_LIGHT size:MenuButtonFontSize]];
        [self addSubview:_txtDesc];
    }
    return _txtDesc;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPhoto:(BaseImage *)image withSize:(PrintableSize *)size {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.size = size;
        self.image = image;
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        CGRect bounds = [InterfacePreferenceHelper getScreenBounds];
        CGRect frame = self.frame;
        frame.size.height = ROW_HEIGHT_PERCENT*[InterfacePreferenceHelper getPictureThumbSize];
        frame.size.width = bounds.size.width;
        self.frame = frame;
        
        [self updateDisplayForImage:image andSize:size];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)updateDisplayForImage:(BaseImage *)order andSize:(PrintableSize *)size {
    [self.prevImageView removeFromSuperview];
    self.prevImageView = nil;
    
    self.viewQuantity.quantity = size.sQuantity;
    
    [self.imManager setImageAsync:self.prevImageView withImage:order displaySize:ThumbnailPictureType atSize:size];
    [self.txtTitle setText:size.sTitle];
    NSString *pricing = [NSString stringWithFormat:@"+ $%.2f ea.", ((CGFloat)size.sPrice)/100.0];
    [self.txtDesc setText:pricing];
    
    if (size.sDPI < size.sWarnDPI) {
        [self.warningButton setHidden:NO];
    } else {
        [self.warningButton setHidden:YES];
    }
}

- (void)updatedQuantity:(NSInteger)quantity {
    NSInteger deltaPrice = (quantity-self.size.sQuantity)*self.size.sPrice;
    self.size.sQuantity = quantity;
    [self.delegate updateProductWithSize:self.size andDeltaPrice:deltaPrice];
}

- (void)showWarningForImage {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning: Low Resolution" message:@"This photo is a bit too low resolution and might look grainy or blurry in the print." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];

}

@end
