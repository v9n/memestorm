//
//  AXMemeShopViewController.h
//  Meme Storm
//  Some code here is adopted from Ieag/PullToRefresh 
//  Created by Hoa Diem Nguyet on 6/2/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "CRTableViewCell.h"
#import "AXConfig.h"
#import "AXCache.h"
#import "AXSidePanelController.h"
#import "MBProgressHUD.h"

#define kMarkColor kYellowColor;
#define REFRESH_HEADER_HEIGHT 52.0f

@interface AXMemeShopViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AXSidePanelDelegate>
{
    BOOL isDragging;
    BOOL isLoading;    
}

@property (strong, nonatomic) IBOutlet UITableView *memeSourceTable;
@property (strong, nonatomic) NSMutableArray *memeSourceData;
@property (strong, nonatomic) NSMutableArray *selectedMarks; // You need probably to save the selected cells for use in the future.
@property (strong, nonatomic) AXCache *cache;
@property NSString * avatarFolder;

@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;

- (void) loadMemeSource;
- (void) saveSelectedSource;
- (void) updateSourceList;
- (void) downloadAvatarForSite:(NSDictionary *) site;

- (void) addPullToRefresh;
- (void) didHideLeftPanel;

@end
