//
//  AXSidePanelControllerViewController.h
//  Meme Storm
//
//  Created by Hoa Diem Nguyet on 6/3/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "JASidePanelController.h"

#import "UIBarButtonItem+StyledButton.h"

@protocol AXSidePanelDelegate <NSObject>

@optional

- (void) didHideLeftPanel;

@end

@interface AXSidePanelController : JASidePanelController

// set the panels
@property (nonatomic, strong) UIViewController<AXSidePanelDelegate>  *leftPanel;   // optional
@property (nonatomic, strong) UIViewController<AXSidePanelDelegate> *centerPanel; // required
@property (nonatomic, strong) UIViewController<AXSidePanelDelegate> *rightPanel;  // optional


@end
