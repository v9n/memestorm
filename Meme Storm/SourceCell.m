//
//  SourceCell.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/8/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import "SourceCell.h"

@implementation SourceCell

@synthesize  thumbImageView, langImageView, nameLbl;
@synthesize  order;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    UIColor *color;
//    UIColor *color = [UIColor colorWithRed:31/255.0f green:127/255.0f blue:92/255.0f alpha:1.0f];
//    color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    color = [UIColor clearColor];
    
    
    //UIColor *lineColor = [UIColor colorWithRed:37/255.0f green:110/255.0f blue:83/255.0f alpha:1.0f];
//    UIColor *lineColor = [UIColor colorWithRed:244/255.0f green:244/255.0f blue:244/255.0f alpha:1.0f];
    UIColor *lineColor = [UIColor colorWithRed:79/255.0f green:79/255.0f blue:79/255.0f alpha:1.0f];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect)
    ;
    int xStart = 0, yStart = self.bounds.size.height;

    
    UIBezierPath *topPath = [UIBezierPath bezierPath];

    [topPath moveToPoint:CGPointMake(xStart, yStart)];
    [topPath addLineToPoint:CGPointMake(xStart+self.bounds.size.width, yStart)];
    [topPath setLineWidth:2.0f];
    [lineColor setStroke];
    [topPath stroke];
    
//    [topPath moveToPoint:CGPointMake(53, 0)];
//    [topPath addLineToPoint:CGPointMake(53, 56)];
   
    [topPath stroke];
}

- (void)paint:(NSIndexPath *) indexPath {
    UIColor *color, *lineColor;
    
    if (0==fmod(indexPath.row, 2)) {
        color = [UIColor colorWithRed:31/255.0f green:127/255.0f blue:92/255.0f alpha:1.0f];

    } else {
        color = [UIColor colorWithRed:25/255.0f green:102/255.0f blue:74/255.0f alpha:1.0f];
    }
    lineColor = [UIColor colorWithRed:37/255.0f green:110/255.0f blue:83/255.0f alpha:1.0f];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, self.bounds);
    
    int xStart = 0, yStart = self.bounds.size.height;
    
    
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    
    [topPath moveToPoint:CGPointMake(xStart, yStart)];
    [topPath addLineToPoint:CGPointMake(xStart+self.bounds.size.width, yStart)];
    
    [lineColor setStroke];
    [topPath stroke];
    
//    [topPath moveToPoint:CGPointMake(56, 0)];
//    [topPath addLineToPoint:CGPointMake(56, 56)];
    
    [topPath stroke];

    
}


- (void) setMemeTitle:(NSString *)title {
    nameLbl.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.00];
    [nameLbl setTextColor:[UIColor blackColor]];
    [nameLbl setText:title];

}

- (void) setAvatar:(UIImage *) img {
   thumbImageView.image = img;
}
@end
