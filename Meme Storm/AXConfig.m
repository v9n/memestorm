//
//  AXConfig.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import "AXConfig.h"

@implementation AXConfig
{
}

+ (AXConfig *) instance
{
    self.instance = [[AXConfig alloc] init];
    return self.instance;
}
@end
