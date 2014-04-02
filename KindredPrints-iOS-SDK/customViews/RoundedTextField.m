//
//  RoundedTextField.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/7/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "RoundedTextField.h"
#import "InterfacePreferenceHelper.h"

@interface RoundedTextField()

@property (strong, nonatomic) UIImageView *imgIcon;
@property (strong, nonatomic) UIView *greyView;

@end

@implementation RoundedTextField

static CGFloat const PERCENT_IMAGE_SIZE = 0.5f;
static CGFloat const PERCENT_HEADER = 0.15;
static CGFloat const TEXT_PADDING = 5.0f;
static CGFloat const BORDER_WIDTH = 1.0f;
static CGFloat const CORNER_RADIUS = 8.0f;

- (id)initWithFrame:(CGRect)frame andStrokeColor:(UIColor *)strokeColor andIconBackgroundColor:(UIColor *)bgColor andImage:(UIImage *)image andHintText:(NSString *)hint
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.imgIcon = [[UIImageView alloc] initWithImage:image];
        CGFloat widthToHeight = image.size.width/image.size.height;
        [self.imgIcon setFrame:CGRectMake(PERCENT_HEADER*frame.size.width*(1-PERCENT_IMAGE_SIZE*widthToHeight)/2, (frame.size.height-frame.size.height*PERCENT_IMAGE_SIZE)/2, PERCENT_HEADER*frame.size.width*PERCENT_IMAGE_SIZE*widthToHeight, frame.size.height*PERCENT_IMAGE_SIZE)];
        
        self.greyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PERCENT_HEADER*frame.size.width, frame.size.height)];
        [self.greyView setBackgroundColor:bgColor];
        [self addSubview:self.greyView];
        [self addSubview:self.imgIcon];
        
        self.txtEntry = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width*PERCENT_HEADER+TEXT_PADDING, 0, frame.size.width*(1-PERCENT_HEADER)-2*TEXT_PADDING, frame.size.height)];
        [self.txtEntry setBackgroundColor:[UIColor clearColor]];
        [self.txtEntry setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self.txtEntry setTextColor:[UIColor whiteColor]];
        [self.txtEntry setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
        [self.txtEntry setAttributedPlaceholder:[[NSAttributedString alloc]
                                                 initWithString:hint
                                                 attributes:[[NSDictionary alloc]
                                                             initWithObjects:@[[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize],
                                                                               [InterfacePreferenceHelper getColor:ColorNavBar]
                                                                               ]
                                                             forKeys:@[
                                                                       NSFontAttributeName,
                                                                       NSForegroundColorAttributeName]]]];
        
        [self addSubview:self.txtEntry];
        
        NSLog(@"frame height %f, text frame height %f", self.frame.size.height, self.txtEntry.frame.size.height);
        
        [self.layer setCornerRadius:CORNER_RADIUS];
        [self.layer setBorderWidth:BORDER_WIDTH];
        [self.layer setBorderColor:[strokeColor CGColor]];
        
        [self setClipsToBounds:YES];
        
    }
    return self;
}

@end
