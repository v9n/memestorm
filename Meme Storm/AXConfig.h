//
//  AXConfig.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

//#ifndef AX_SPIDER_URL
#define AX_SPIDER_URL  @"http://meme-spider.axcoto.com"
//#endif

@interface AXConfig : NSObject
{
}

+ (AXConfig *) instance;
- (id) read:(NSString *)name;
@end
