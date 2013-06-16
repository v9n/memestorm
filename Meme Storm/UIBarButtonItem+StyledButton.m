//
//  UIBarButtonItem+StyledButton.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 1/7/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "UIBarButtonItem+StyledButton.h"
#import "UIButton+StyledButton.h"

@implementation UIBarButtonItem (StyledButton)

+ (UIBarButtonItem *)styledBackBarButtonItemWithTarget:(id)target selector:(SEL)selector;
{
    return [self styledBackBarButtonItemWithTarget:target selector:selector withTitle:@"Back"];
//    UIImage *image = [UIImage imageNamed:@"button_back"];
////    image = [image stretchableImageWithLeftCapWidth:20.0f topCapHeight:0.0f];
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 31.0, 9)];
//    
//    NSString *title = NSLocalizedString(@"Back", nil);
//    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
//    
//    UIButton *button = [UIButton styledButtonWithBackgroundImage:image font:font title:title target:target selector:selector];
//    button.titleLabel.textColor = [UIColor blackColor];
//    
//    CGSize textSize = [title sizeWithFont:font];
//    CGFloat margin = (button.frame.size.height - textSize.height) / 2;
//    CGFloat marginRight = 7.0f;
//    CGFloat marginLeft = button.frame.size.width - textSize.width - marginRight;
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(margin, marginLeft, margin, marginRight)];
//    [button setTitleColor:[UIColor colorWithRed:95.0f/255.0f green:96.0f/255.0f blue:101.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//    
//    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)styledBackBarButtonItemWithTarget:(id)target selector:(SEL)selector withTitle:(NSString *) title
{
    UIImage *image = [UIImage imageNamed:@"button_back"];
    //    image = [image stretchableImageWithLeftCapWidth:20.0f topCapHeight:0.0f];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 31.0, 9)];
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    
    UIButton *button = [UIButton styledButtonWithBackgroundImage:image font:font title:title target:target selector:selector];
    button.titleLabel.textColor = [UIColor blackColor];
    
    CGSize textSize = [title sizeWithFont:font];
    CGFloat margin = (button.frame.size.height - textSize.height) / 2;
    CGFloat marginRight = 7.0f;
    CGFloat marginLeft = button.frame.size.width - textSize.width - marginRight;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(margin, marginLeft, margin, marginRight)];
    [button setTitleColor:[UIColor colorWithRed:95.0f/255.0f green:96.0f/255.0f blue:101.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)styledCancelBarButtonItemWithTarget:(id)target selector:(SEL)selector;
{
    UIImage *image = [UIImage imageNamed:@"button_square"];
    image = [image stretchableImageWithLeftCapWidth:20.0f topCapHeight:20.0f];
    
    NSString *title = NSLocalizedString(@"Cancel", nil);
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    
    UIButton *button = [UIButton styledButtonWithBackgroundImage:image font:font title:title target:target selector:selector];
    button.titleLabel.textColor = [UIColor blackColor];
    [button setTitleColor:[UIColor colorWithRed:53.0f/255.0f green:77.0f/255.0f blue:99.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)styledSubmitBarButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
{
    UIImage *image = [UIImage imageNamed:@"button_submit"];
    image = [image stretchableImageWithLeftCapWidth:20.0f topCapHeight:20.0f];
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    
    UIButton *button = [UIButton styledButtonWithBackgroundImage:image font:font title:title target:target selector:selector];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button] ;
}

+ (UIBarButtonItem *)transparentButtonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector
{
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    
    UIButton *button = [UIButton styledButtonWithBackgroundImage:image font:font title:@"" target:target selector:selector];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setBounds:CGRectMake(10, 5, 20,20)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button] ;
}

@end