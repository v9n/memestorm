//
//  AxcotoViewController.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 11/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AxcotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *memeSourceTable;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *downloadProgress;


- (void) loadMemeSource;

@end
