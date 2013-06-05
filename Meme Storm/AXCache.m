//
//  CNCache.m
//  iCeeNee
//
//  Created by kureikain on 5/31/13.
//  Copyright (c) 2013 Ceenee. All rights reserved.
//

/*
 Sever as a simple cache mechanism to store app data
 */
#import "AXCache.h"

@implementation AXCache

@synthesize  driver, db;

static AXCache *instance = NULL;

+ (AXCache *) instance {
    @synchronized(self)
    {
        if (instance == NULL)
            instance = [[self alloc] init];
    }
    return(instance);
}

- (id) init
{
    if (self = [super init]) {
        [self loadAppCache];
    }
    return self;
}

/**
 Read information from db file into dictonary
 */
- (void) loadAppCache
{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray* paths = [manager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    driver = nil;
    if ([paths count] > 0)
    {
        db = (NSString *) [[paths objectAtIndex:0] path];
        db = [db stringByAppendingString:@"/app.cache"];
        if ([manager fileExistsAtPath:self.db])
        {
            driver = [[NSMutableDictionary alloc] initWithContentsOfFile:self.db];
        }
    }
    if (driver == nil) {
        driver = [[NSMutableDictionary alloc] init];
    }
    
}

- (id) getByKey:(NSString *) key
{
    return [self.driver objectForKey:key];
}

/**
 Put object into cache. Save instantly to disk.
 */
- (BOOL) saveForKey:(NSString *) key withValue:(id) value
{
    BOOL writeResult;
    @try {
        [self.driver setObject:value forKey:(NSString *)key];
        [self.driver writeToFile:self.db atomically:TRUE];
    }
    @catch (NSException * e) {
        NSLog(@"Cannot create cache file");
        writeResult = FALSE;
    }    
    return writeResult;    
}

@end
