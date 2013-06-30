//
//  AXConfig.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AX_SPIDER_URL  @"http://meme-spider.axcoto.com"
//#define AX_SPIDER_URL  @"http://192.168.1.104:9292"
#define AX_MEME_STORM_VERSION @"0.4.0-rc1-b20130629"

@interface AXConfig : NSObject
{
}

+ (AXConfig *) instance;
- (id) read:(NSString *)name;
@end
