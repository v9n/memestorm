//
//  AxcotoMemeDetailViewController.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/1/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "SDWebImage/UIImageView+WebCache.h"

NSString * const AXMemeBackground;
@interface AxcotoMemeDetailViewController : UIViewController <UIScrollViewDelegate, SDWebImageManagerDelegate> {
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

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *downloadProgress;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *imgContainer;

@property (strong, nonatomic) UIImageView * prevImgView;
@property (strong, nonatomic) UIImageView * currentImgView;
@property (strong, nonatomic) UIImageView * nextImgView;

@property (strong, nonatomic) UIScrollView * prevScroolView;
@property (strong, nonatomic) UIScrollView * currentScroolView;
@property (strong, nonatomic) UIScrollView * nextScroolView;

@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeCommentButton;
@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeLikeButton;
@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeShareButton;
@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeDownloadButton;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *memeTitleLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *metaMemeView;

@property NSUInteger tag;

- (IBAction)showComment:(id)sender;
- (IBAction)shareMeme:(id)sender;
- (void) downloadMeme:(id)sender;

- (void) showMemeListView;

- (void)caculateViewerDim;
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image;

# pragma mark
- (void)image:(UIImage *)img didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end
