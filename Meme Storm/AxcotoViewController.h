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
#import "AxcotoMemeDetailViewController.h"

@interface AxcotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AXSidePanelDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *memeSourceTable;

@property (strong, nonatomic)    AXCache * cache ;

@property (weak, nonatomic) IBOutlet UIButton *chooseMemeButton;

@property (strong, nonatomic) AxcotoMemeDetailViewController *readerView;

- (void) didHideLeftPanel;
- (void) didShowCenterPanel;

@property NSString * avatarFolder;
- (void) loadMemeSource;
- (void) cleanMemeCache;
- (void) reorderSite;
- (IBAction)showSourceList:(id)sender;
- (void)showSettingKit:(id)sender;
@end
