//
//  PhotoCell.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 4/18/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,frame.size.width, frame.size.width)];
        [self addSubview:self.imageView];
        
        CGRect selectedRect = CGRectMake(frame.size.width-frame.size.width/4.5-3, frame.size.width-frame.size.width/4.5-3, frame.size.width/4.5, frame.size.width/4.5);
        self.checkedOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_checked.png"]];
        self.checkedOverlay.frame = selectedRect;
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect activityFrame = self.activityView.frame;
        activityFrame.origin.x = (frame.size.width-activityFrame.size.width)/2;
        activityFrame.origin.y = (frame.size.height-activityFrame.size.height)/2;
        self.activityView.frame = activityFrame;
        [self addSubview:self.activityView];
        
        [self.activityView startAnimating];
        
        [self addSubview:self.checkedOverlay];
        [self.checkedOverlay setOpaque:YES];
        [self.checkedOverlay setHidden:YES];
    }
    return self;
}

-(void) setUnchecked{
    [self.checkedOverlay setHidden:YES];
}

-(void) setChecked {
    [self.checkedOverlay setHidden:NO];
}

@end
