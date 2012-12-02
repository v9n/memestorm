//
//  AxcotoAppDelegate.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 11/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AxcotoViewController;


@interface AxcotoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AxcotoViewController *viewController;

@property (nonatomic, retain) UINavigationController *navController;

@end
