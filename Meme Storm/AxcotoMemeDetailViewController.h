//
//  AxcotoMemeDetailViewController.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/1/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "MBProgressHUD.h"

#import "UIImageView+WebCache.h"
#import "AXMemeCommentViewController.h"

NSString * const AXMemeBackground;
@interface AxcotoMemeDetailViewController : UIViewController <UIScrollViewDelegate, SDWebImageManagerDelegate> {
    int currentMemeIndex;
    int currentMemePage;
    NSMutableArray * memesList;
    NSString * docRoot;
    float screenHeigh;
    float screenWidth;
    bool downloading;
    bool isToolbarVisible;
    CGSize currentImageSize;
}

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (strong, nonatomic) NSString *memeSource ;
@property BOOL refresh;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *imgContainer;

@property (strong, nonatomic) UIImageView * prevImgView;
@property (strong, nonatomic) UIImageView * currentImgView;
@property (strong, nonatomic) UIImageView * nextImgView;

@property (strong, nonatomic) UIView * prevScroolView;
@property (strong, nonatomic) UIScrollView * currentScroolView;
@property (strong, nonatomic) UIScrollView * currentScroolViewContainer;
@property (strong, nonatomic) UIView * nextScroolView;

@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeCommentButton;
@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeLikeButton;
@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeShareButton;
@property (unsafe_unretained, nonatomic)  UIBarButtonItem *memeDownloadButton;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *memeTitleLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *metaMemeView;

@property (strong, nonatomic) MBProgressHUD *downloadProgress;
@property (retain, nonatomic) AXMemeCommentViewController *commetViewController;
@property NSUInteger tag;

- (IBAction)showComment:(id)sender;
- (IBAction)shareMeme:(id)sender;
- (void) downloadMeme:(id)sender;
- (IBAction)refresh:(id)sender;
    
- (void) showMemeListView;

- (void)caculateViewerDim;
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image;

# pragma mark
- (void)image:(UIImage *)img didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

- (NSUInteger) fetchFromSource:(NSUInteger)pageToDownload withTag:(NSUInteger)aTag runIfFound:(void (^)(void))execBlock orNotFound:(void (^)(void))failBlock;
    
@end
