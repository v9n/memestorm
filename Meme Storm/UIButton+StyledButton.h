//
//  UIButton+StyledButton.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 1/7/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton (UIButton_StyledButton)
+ (UIButton *)styledButtonWithBackgroundImage:(UIImage *)image font:(UIFont *)font title:(NSString *)title target:(id)target selector:(SEL)selector;
@end
