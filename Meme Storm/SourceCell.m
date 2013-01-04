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

@end
