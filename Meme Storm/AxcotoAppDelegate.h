//
//  AxcotoAppDelegate.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 11/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "AXSidePanelControllerViewController.h"

@class AxcotoViewController;


@interface AxcotoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JASidePanelController *viewController;

@property (nonatomic, retain) UINavigationController *navController;

@end
