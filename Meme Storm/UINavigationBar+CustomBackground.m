//
//  UInavigationBar+CustomBackground.m
//  Meme Storm
//
//  Created by Hoa Diem Nguyet on 5/25/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "UInavigationBar+CustomBackground.h"

@implementation UINavigationBar (UINavigationBar_CustomBackground)


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
- (void)drawRect:(CGRect)rect {
    UIColor *color = self.tintColor;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect);
}


- (UIImage *) createImageWithColor:(UIColor *)color andSize:(CGSize) size {
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();

    CGRect fillRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *) createImageWithColor:(UIColor *)color {
    return [self createImageWithColor:color andSize:self.frame.size];
}

@end