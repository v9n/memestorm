//
//  AxcotoMemeSource.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/1/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AxcotoMemeSource : NSObject
{
    NSMutableArray * meme;
}
@property (unsafe_unretained) int currentPage;
@property (unsafe_unretained) NSString * currentMeme;


- (BOOL) hasUpdate;
- (void) previous;
- (void) next;

@end
