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
    static dispatch_once_t once;
    static AXConfig *instance;
    dispatch_once(&once, ^ { instance = [[AXConfig alloc] init];});
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (id) read:(NSString *)name
{
 return @"...";
}

@end
