//
//  CNCache.h
//  iCeeNee
//
//  Created by kureikain on 5/31/13.
//  Copyright (c) 2013 Ceenee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXCache
: NSObject

@property (strong, nonatomic) NSMutableDictionary * driver;
@property (strong, nonatomic) NSString * db;

- (id) getByKey:(NSString *) key;
- (BOOL) saveForKey:(NSString *) key withValue:(id) value;
@end
