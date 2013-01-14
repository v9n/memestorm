//
//  UIButton+StyledButton.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 1/7/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "UIButton+StyledButton.h"

@implementation UIButton (UIButton_StyledButton)

+ (UIButton *)styledButtonWithBackgroundImage:(UIImage *)image font:(UIFont *)font title:(NSString *)title target:(id)target selector:(SEL)selector
{
    CGSize textSize = [title sizeWithFont:font];
    CGSize buttonSize = CGSizeMake(textSize.width + 20.0f, image.size.height);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height)];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    
    return button;
}

@end