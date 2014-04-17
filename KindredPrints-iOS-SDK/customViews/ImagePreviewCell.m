//
//  ImagePreviewCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "ImagePreviewCell.h"
#import "InterfacePreferenceHelper.h"
#import "ImageManager.h"
#import "CircularButton.h"
#import "OrderManager.h"
#import "SideArrow.h"

@interface ImagePreviewCell() <ImageManagerDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) SideArrow *leftSideArrow;
@property (strong, nonatomic) SideArrow *rightSideArrow;

@property (strong, nonatomic) CircularButton *cmdDelete;
@property (strong, nonatomic) OrderManager *orderManager;
@property (strong, nonatomic) ImageManager *imManager;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UILabel *txtPicCount;
@property (strong, nonatomic) BaseImage *image;
@property (strong, nonatomic) UIButton *warningButton;
@property (strong, nonatomic) UIButton *flipButton;

@property (nonatomic) CGSize previewSize;
@property (nonatomic) NSInteger index;

@property (nonatomic) NSInteger alertTag;

@property (nonatomic) BOOL frontSideUp;

@end

@implementation ImagePreviewCell

static NSInteger TAG_WARNING = 0;
static NSInteger TAG_DELETE = 1;

static CGFloat const HEADER_SIZE = 25;
static CGFloat const PADDING = 7.0f;
static CGFloat const SHADOW_LAYER_SIZE = 1.05;
static CGFloat const ARROW_TRANSPARENCY = 0.65f;

- (ImageManager *)imManager {
    if (!_imManager)
    {
        _imManager = [ImageManager GetInstance];
        _imManager.delegate = self;
    }
    return _imManager;
}

- (OrderManager *)orderManager {
    if (!_orderManager) {
        _orderManager = [OrderManager getInstance];
    }
    return _orderManager;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPhoto:(BaseImage *)image atIndex:(NSInteger)index
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        self.image = image;
        self.index = index;

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake((bounds.size.width-[InterfacePreferenceHelper getPicturePreviewSize])/2, ([InterfacePreferenceHelper getPicturePreviewSize]+2*HEADER_SIZE-[InterfacePreferenceHelper getPicturePreviewSize])/2, [InterfacePreferenceHelper getPicturePreviewSize], [InterfacePreferenceHelper getPicturePreviewSize])];
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake((bounds.size.width-SHADOW_LAYER_SIZE*[InterfacePreferenceHelper getPicturePreviewSize])/2, ([InterfacePreferenceHelper getPicturePreviewSize]+2*HEADER_SIZE-[InterfacePreferenceHelper getPicturePreviewSize])/2, SHADOW_LAYER_SIZE*[InterfacePreferenceHelper getPicturePreviewSize], SHADOW_LAYER_SIZE*[InterfacePreferenceHelper getPicturePreviewSize])];
        [self addSubview:self.shadowView];
        [self addSubview:self.imgView];
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.cmdDelete = [[CircularButton alloc] initWithFrame:CGRectMake(self.imgView.frame.origin.x+self.imgView.frame.size.width-[InterfacePreferenceHelper getCartDeleteSize] -[InterfacePreferenceHelper getCartDeletePadding], self.imgView.frame.origin.y-[InterfacePreferenceHelper getCartDeletePadding], [InterfacePreferenceHelper getCartDeleteSize], [InterfacePreferenceHelper getCartDeleteSize])];
        [self.cmdDelete drawCircleButtonWithPressedFillColor:[UIColor whiteColor] andBasecolor:[UIColor whiteColor]  andInnerStrokeColor:[InterfacePreferenceHelper getColor:ColorNavBar] andOuterStrokeColor:[UIColor whiteColor] andButtonType:DeleteButton];
        [self.cmdDelete addTarget:self action:@selector(cmdDeletePressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.cmdDelete];
        
        NSString *title = [NSString stringWithFormat:@"Picture %d of %d", (int)(self.index+1), (int)[self.orderManager countOfOrders]];
        CGRect size;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, [InterfacePreferenceHelper getPicturePreviewSize]) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:FONT_LIGHT size:OrderViewFontSize], NSFontAttributeName, nil] context:nil];
        } else {
            CGSize tempSize = [title sizeWithFont:[UIFont fontWithName:FONT_LIGHT size:OrderViewFontSize]];
            size = CGRectMake(0, 0, tempSize.width, tempSize.height);
        }
        
        self.txtPicCount = [[UILabel alloc] initWithFrame:CGRectMake((bounds.size.width-size.size.width)/2-PADDING, self.imgView.frame.origin.y+self.imgView.frame.size.height-2.1*OrderViewFontSize-PADDING, size.size.width+2*PADDING, 2.4*OrderViewFontSize)];
        [self.txtPicCount setTextAlignment:NSTextAlignmentCenter];
        [self.txtPicCount setTextColor:[UIColor whiteColor]];
        [self.txtPicCount setBackgroundColor:[InterfacePreferenceHelper getColor:ColorDarkGrayTrans]];
        [self.txtPicCount.layer setCornerRadius:4.0f];
        [self.txtPicCount.layer setMasksToBounds:YES];
        [self.txtPicCount setText:title];
        [self.txtPicCount setFont:[UIFont fontWithName:FONT_LIGHT size:OrderViewFontSize]];
        [self addSubview:self.txtPicCount];
        
        self.warningButton = [[UIButton alloc] initWithFrame:CGRectMake(self.imgView.frame.origin.x+PADDING, self.imgView.frame.origin.y+PADDING, [InterfacePreferenceHelper getCartDeleteSize], [InterfacePreferenceHelper getCartDeleteSize])];
        [self.warningButton setBackgroundColor:[UIColor clearColor]];
        [self.warningButton setImage:[UIImage imageNamed:@"ico_warning_yellow"] forState:UIControlStateNormal];
        [self.warningButton setHidden:YES];
        [self.warningButton addTarget:self action:@selector(showWarningForImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.warningButton];

        self.flipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.imgView.frame.origin.x-PADDING-[InterfacePreferenceHelper getCartDeleteSize], self.imgView.frame.origin.y+PADDING, [InterfacePreferenceHelper getCartDeleteSize], [InterfacePreferenceHelper getCartDeleteSize])];
        [self.flipButton setBackgroundColor:[UIColor clearColor]];
        [self.flipButton setImage:[UIImage imageNamed:@"ico_flip_white"] forState:UIControlStateNormal];
        [self.flipButton setHidden:YES];
        [self.flipButton addTarget:self action:@selector(flipImageView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.flipButton];
        self.frontSideUp = YES;
        
        CGFloat arrowSide = (bounds.size.width-[InterfacePreferenceHelper getPicturePreviewSize])/2;
        self.leftSideArrow = [[SideArrow alloc] initWithFrame:CGRectMake(0, ([InterfacePreferenceHelper getPicturePreviewSize]+2*HEADER_SIZE-arrowSide)/2, arrowSide, arrowSide)];
        [self.leftSideArrow drawSideArrowOfColor:[UIColor whiteColor] andTrans:ARROW_TRANSPARENCY andArrowType:LeftSideArrow];
        [self.leftSideArrow addTarget:self action:@selector(clickedLeftArrow) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftSideArrow];
        if (self.index == 0)
            [self.leftSideArrow setHidden:YES];
        
        self.rightSideArrow = [[SideArrow alloc] initWithFrame:CGRectMake(bounds.size.width-arrowSide, ([InterfacePreferenceHelper getPicturePreviewSize]+2*HEADER_SIZE-arrowSide)/2, arrowSide, arrowSide)];
        [self.rightSideArrow drawSideArrowOfColor:[UIColor whiteColor] andTrans:ARROW_TRANSPARENCY andArrowType:RightSideArrow];
        [self.rightSideArrow addTarget:self action:@selector(clickedRightArrow) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightSideArrow];
        if (self.index == (int)[self.orderManager countOfOrders]-1)
            [self.rightSideArrow setHidden:YES];
        
        [self updateDisplayForProduct:nil];
    }
    return self;
}

- (void) cmdDeletePressed {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove Photo?" message:@"Do you want to remove this photo from your cart?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alertView.tag = TAG_DELETE;
    [alertView show];
}


- (void) resizeImageViewWithImage {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect imgViewFrame = self.imgView.frame;
    CGFloat xSide = [InterfacePreferenceHelper getPicturePreviewSize];
    CGFloat ySide = [InterfacePreferenceHelper getPicturePreviewSize];
    
    if (self.previewSize.width > self.previewSize.height && self.previewSize.width != 0) {
        ySide = [InterfacePreferenceHelper getPicturePreviewSize]*self.previewSize.height/self.previewSize.width;
    } else if (self.previewSize.height != 0) {
        xSide = [InterfacePreferenceHelper getPicturePreviewSize]*self.previewSize.width/self.previewSize.height;
    }
    
    imgViewFrame.size.width = xSide;
    imgViewFrame.size.height = ySide;
    imgViewFrame.origin.x = (bounds.size.width-xSide)/2;
    imgViewFrame.origin.y = ([InterfacePreferenceHelper getPicturePreviewSize]+2*HEADER_SIZE-ySide)/2;
    self.imgView.frame = imgViewFrame;
    
    CGRect warningFrame = imgViewFrame;
    warningFrame.origin.x = warningFrame.origin.x + PADDING;
    warningFrame.origin.y = warningFrame.origin.y + PADDING;
    warningFrame.size.width = [InterfacePreferenceHelper getCartDeleteSize];
    warningFrame.size.height = [InterfacePreferenceHelper getCartDeleteSize];
    self.warningButton.frame = warningFrame;
    
    CGRect flipFrame = imgViewFrame;
    flipFrame.origin.x = flipFrame.origin.x - [InterfacePreferenceHelper getCartDeleteSize] - PADDING;
    flipFrame.origin.y = flipFrame.origin.y + PADDING;
    flipFrame.size.width = [InterfacePreferenceHelper getCartDeleteSize];
    flipFrame.size.height = [InterfacePreferenceHelper getCartDeleteSize];
    self.flipButton.frame = flipFrame;
    
    CGRect deleteFrame = self.cmdDelete.frame;
    deleteFrame.origin.x = self.imgView.frame.origin.x+self.imgView.frame.size.width-[InterfacePreferenceHelper getCartDeleteSize] - [InterfacePreferenceHelper getCartDeletePadding];
    deleteFrame.origin.y = self.imgView.frame.origin.y+[InterfacePreferenceHelper getCartDeletePadding];
    self.cmdDelete.frame = deleteFrame;
    
    CGRect textFrame = self.txtPicCount.frame;
    textFrame.origin.y = self.imgView.frame.origin.y+self.imgView.frame.size.height-2.1*OrderViewFontSize-PADDING;
    self.txtPicCount.frame = textFrame;
    [self.txtPicCount setText:[NSString stringWithFormat:@"Picture %d of %d", (int)(self.index+1), (int)[self.orderManager countOfOrders]]];
    
    xSide = SHADOW_LAYER_SIZE * xSide;
    ySide = SHADOW_LAYER_SIZE * ySide;
    imgViewFrame.size.width = xSide;
    imgViewFrame.size.height = ySide;
    imgViewFrame.origin.x = (bounds.size.width-xSide)/2;
    imgViewFrame.origin.y = ([InterfacePreferenceHelper getPicturePreviewSize]+2*HEADER_SIZE-ySide)/2;

    self.shadowView.frame = imgViewFrame;
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.cornerRadius = 4; // if you like rounded corners
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds].CGPath;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowView.layer.shadowRadius = 9.0;
    self.shadowView.layer.shadowOpacity = 0.6;
}

- (void)updateDisplayForProduct:(PrintableSize *)product {
    if (product) {
        self.previewSize = CGSizeMake(product.sPreviewSize.width, product.sPreviewSize.height);
    } else {
        self.previewSize = CGSizeMake(self.image.pWidth, self.image.pHeight);
        if ([[self.orderManager getOrderForIndex:self.index].printProducts count] > 0) {
            product = [[self.orderManager getOrderForIndex:self.index].printProducts objectAtIndex:0];
            self.previewSize = CGSizeMake(product.sPreviewSize.width, product.sPreviewSize.height);
        }
    }
    if (self.image.pIsTwoSided) {
        [self.flipButton setHidden:NO];
    } else {
        [self.flipButton setHidden:YES];
    }
    self.imManager.delegate = self;
    [self.imManager setImageAsync:self.imgView withImage:self.image displaySize:PreviewPictureType atSize:product];
}

- (void)showWaringIcon {
    [self.warningButton setHidden:NO];
}

- (void)flipImageView {
    self.frontSideUp = !self.frontSideUp;
    BaseImage *image = self.image;
    if (!self.frontSideUp) {
        image = self.image.pBackSide;
    }
    self.imManager.delegate = self;
    [self.imManager setImageAsync:self.imgView withImage:image displaySize:PreviewPictureType atSize:nil];
}

- (void)showWarningForImage {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning: Low Resolution" message:@"This photo is a bit too low resolution and might look grainy or blurry in the print." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag = TAG_WARNING;
    [alertView show];
}

- (void)clickedRightArrow {
    if (self.delegate) [self.delegate userRequestedGoForwardAPage];
}

- (void)clickedLeftArrow {
    if (self.delegate) [self.delegate userRequestedGoBackAPage];
}

#pragma mark IMAGE MANAGER DELEGATE

- (void)imageInserted {
    self.imManager.delegate = nil;
   
    self.image = [self.orderManager getOrderForIndex:self.index].image;
    
    if (!self.imgView.image) {
        [self updateDisplayForProduct:nil];
    }
    
    [self resizeImageViewWithImage];
}

#pragma mark ALERT VIEW DELEGATE

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_DELETE) {
        if (buttonIndex > 0) {
            [self.delegate userRequestedDelete];
        }
    }
}

@end
