//
//  RoundedTextField.h
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/7/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundedTextField : UIView

- (id)initWithFrame:(CGRect)frame andStrokeColor:(UIColor *)strokeColor andIconBackgroundColor:(UIColor *)bgColor andImage:(UIImage *)image andHintText:(NSString *)hint;

@property (strong, nonatomic) UITextField *txtEntry;


@end
