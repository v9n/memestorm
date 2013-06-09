//
//  AXMemeShopViewController.h
//  Meme Storm
//
//  Created by Hoa Diem Nguyet on 6/2/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "CRTableViewCell.h"
#import "AXCache.h"
#import "AXSidePanelController.h"

#define kMarkColor kYellowColor;

@interface AXMemeShopViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AXSidePanelDelegate>

@property (strong, nonatomic) IBOutlet UITableView *memeSourceTable;
@property (strong, nonatomic) NSArray *memeSourceData;
@property (strong, nonatomic) NSMutableArray *selectedMarks; // You need probably to save the selected cells for use in the future.
@property (strong, nonatomic) AXCache *cache;
- (void) loadMemeSource;
- (void) saveSetting;

- (void) didHideLeftPanel;

@end
