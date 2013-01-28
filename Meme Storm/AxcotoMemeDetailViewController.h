//
//  AxcotoMemeDetailViewController.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/1/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"

NSString * const AXMemeBackground;
@interface AxcotoMemeDetailViewController : UIViewController <UIScrollViewDelegate> {
    int currentMemeIndex;
    int currentMemePage;
    NSMutableArray * memesList;
    NSString * docRoot;
    float screenHeigh;
    float screenWidth;
    bool downloading;
    
    CGSize currentImageSize;
}

@property (strong, nonatomic) NSString *memeSource ;

@property (unsafe_unretained, nonatomic) IBOutlet UIProgressView *downloadProgress;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *imgContainer;

@property (strong, nonatomic) UIImageView * prevImgView;
@property (strong, nonatomic) UIImageView * currentImgView;
@property (strong, nonatomic) UIImageView * nextImgView;

@property (strong, nonatomic) UIScrollView * prevScroolView;
@property (strong, nonatomic) UIScrollView * currentScroolView;
@property (strong, nonatomic) UIScrollView * nextScroolView;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *memeCommentButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *memeLikeButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *memeShareBar;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *memeTitleLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *metaMemeView;

- (IBAction)showComment:(id)sender;

- (IBAction)share:(id)sender;

- (void) showMemeListView;

- (void)caculateViewerDim;
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end
