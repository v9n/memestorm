//
//  AxcotoViewController.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 11/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIBarButtonItem+StyledButton.h"
#import "AXCache.h"
#import "AXSidePanelController.h"

@interface AxcotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AXSidePanelDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *memeSourceTable;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *downloadProgress;
@property (strong, nonatomic)    AXCache * cache ;

@property (weak, nonatomic) IBOutlet UIButton *chooseMemeButton;

- (void) didHideLeftPanel;
- (void) didShowCenterPanel;

@property NSString * avatarFolder;
- (void) loadMemeSource;
- (void) cleanMemeCache;
- (void) reorderSite;
@end
