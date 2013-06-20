//
//  AXConfig.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AX_SPIDER_URL  @"http://meme-spider.axcoto.com"
#define AX_MEME_STORM_VERSION @"0.2.0-rc1-b20130619"

@interface AXConfig : NSObject
{
}

+ (AXConfig *) instance;
- (id) read:(NSString *)name;
@end
