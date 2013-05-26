//
//  SourceCell.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/8/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SourceCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *thumbImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *langImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLbl;
@property (unsafe_unretained, nonatomic) int order;;



- (void) setMemeTitle:(NSString *) title;
- (void) setAvatar:(UIImage *) img ;

- (void)drawRect:(CGRect)rect;
- (void)paint:(NSIndexPath *) indexPath;

@end
