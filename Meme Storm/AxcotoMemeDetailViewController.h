//
//  AxcotoMemeDetailViewController.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/1/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"

@interface AxcotoMemeDetailViewController : UIViewController <UIScrollViewDelegate> {
    int currentMemeIndex;
    int currentMemePage;
    NSMutableArray * memesList;
    NSString * docRoot;
}

@property (strong, nonatomic) NSString *memeSource ;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *imgContainer;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewUi;

@end
