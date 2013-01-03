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
    float screenHeigh;
    bool downloading;
}

@property (strong, nonatomic) NSString *memeSource ;

@property (unsafe_unretained, nonatomic) IBOutlet UIProgressView *downloadProgress;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *imgContainer;


@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) UIImageView * prevImgView;
@property (strong, nonatomic) UIImageView * currentImgView;
@property (strong, nonatomic) UIImageView * nextImgView;

@property (strong, nonatomic) UIScrollView * prevScroolView;
@property (strong, nonatomic) UIScrollView * currentScroolView;
@property (strong, nonatomic) UIScrollView * nextScroolView;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *metaMemeView;

- (IBAction)showComment:(id)sender;

@end
