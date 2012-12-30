//
//  AXConfig.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXConfig : NSObject
{
}

+ (AXConfig *) instance;
- (id) read:(NSString *)name;
@end
