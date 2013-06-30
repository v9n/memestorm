//
//  AxcotoMemeDetailViewController.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/1/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import "AxcotoMemeDetailViewController.h"
#import "AXMemeCommentViewController.h"

#import "SHK.h"
#import "UIBarButtonItem+StyledButton.h"

//#import "ImageZoomingViewController.h"
//#import "TapDetemtingImageView.h"
#import "AXConfig.h"

#define MEME_META_VIEW_HEIGHT 30
#define ZOOM_STEP 1.5
#define AX_VIEW_MARGIN 10

NSString * const AXMemeBackground = @"bg.png";
NSString * const AXBarBkgImg = @"toolbar-bg";

@interface AxcotoMemeDetailViewController ()
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation AxcotoMemeDetailViewController

@synthesize memeSource, refresh;
@synthesize imgContainer, downloadProgress, metaMemeView;

@synthesize prevScroolView, currentScroolView, currentScroolViewContainer, nextScroolView;
@synthesize prevImgView, currentImgView, nextImgView;

@synthesize memeShareButton, memeCommentButton, memeLikeButton, memeDownloadButton;

@synthesize memeTitleLbl, refreshButton, redownloadMemeButton;
@synthesize tag;
@synthesize commetViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationController] setNavigationBarHidden:NO];
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"arrow-left"] andBound:CGRectMake(10, 5, 30, 30) target:self selector:@selector(showMemeListView)];
        memeSource = @"";
        refresh = YES;
        memeLikeButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-like"] andBound:CGRectMake(0, 5, 25, 25) target:self selector:@selector(likeMeme:)];
        memeShareButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-share-b"] andBound:CGRectMake(20, 5, 25, 25) target:self selector:@selector(shareMeme:)];
        memeDownloadButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-download"] andBound:CGRectMake(20, 5, 25, 25) target:self selector:@selector(downloadMeme:)];
        memeCommentButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-com"] andBound:CGRectMake(20, 5, 25, 25) target:self selector:@selector(showComment:)];
        tag = 0;
        self.navigationItem.rightBarButtonItems = @[memeShareButton, memeDownloadButton, memeCommentButton, memeLikeButton];
        
        downloadProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        downloadProgress.mode = MBProgressHUDAnimationFade;
        downloadProgress.labelText = @"Downloading...";
        commetViewController = [[AXMemeCommentViewController alloc] initWithNibName:@"AXMemeCommentViewController" bundle:nil];        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@""]; //clear title out. 
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docRoot = [path objectAtIndex:0];
    
    currentMemeIndex = 0; //show the first picture
    currentMemePage = 0;
    memesList = [NSMutableArray arrayWithCapacity:5]; //NSMutuableArrat auto expand when needed. This is just to allocate an enought amount for initalize this array. So, 5 is an affordable number for this purpose.
    [memesList insertObject:@"marked_bound_page" atIndex:0];
    
    CGRect c = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:            
            screenHeigh = c.size.width;
            screenWidth = c.size.height;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            screenHeigh = c.size.height;
            screenWidth = c.size.width;
            break;
    }
    
    NSLog(@"Screen height is %f", screenHeigh);
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self setUpImageViewer];
    [self bindSwipeEvent];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"Start to read meme source: %@", memeSource);
    
    if (refresh) {
        currentMemeIndex = 0; //show the first picture
        currentMemePage = 0;
        refresh = NO;
        [self download];
    }
    isToolbarVisible = YES;
    [self handleSingleTap];
    [self.refreshButton setHidden:YES];
    [currentImgView setImage:nil]; //clear image 
}

/**
 Prepare controller and object. Set their location, initalizr their value or so
 */
- (void) setUpImageViewer {
    CGRect f;
    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeigh);
    
    [redownloadMemeButton setFrame:CGRectMake((screenWidth-redownloadMemeButton.frame.size.width)/2, 230, 128, 128)];
    [refreshButton setFrame:CGRectMake((screenWidth-refreshButton.frame.size.width)/2, 100, refreshButton.frame.size.width, refreshButton.frame.size.height)];
    
    imgContainer.delegate = self;
    imgContainer.pagingEnabled = YES;
    imgContainer.frame = CGRectMake(0, 0, screenWidth, screenHeigh);
    NSLog(@"The height of imgContainer is %f", imgContainer.frame.size.height);
    imgContainer.bouncesZoom = YES;
    imgContainer.clipsToBounds = YES;

    metaMemeView.frame = CGRectMake(0, screenHeigh  -  MEME_META_VIEW_HEIGHT - 40 - 20 , screenWidth, MEME_META_VIEW_HEIGHT); //20 is heigh of status bar, 44 is heigh of UINavigaitonbar
    f = metaMemeView.frame;
    [metaMemeView setFrame:CGRectMake(0, f.origin.y, screenWidth, f.size.height)];
    [memeTitleLbl setFrame:CGRectMake(0, 0, f.size.width, f.size.height)];

    
    prevScroolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeigh)];
    nextScroolView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * 2, 0, screenWidth, screenHeigh)];
    currentScroolView = [[UIScrollView alloc] initWithFrame:CGRectMake(screenWidth, 0, screenWidth , screenHeigh)];
    [imgContainer addSubview: prevScroolView];
    [imgContainer addSubview: currentScroolView];
    [imgContainer addSubview: nextScroolView];
    imgContainer.contentSize = CGSizeMake(screenWidth * 3 + 2 * AX_VIEW_MARGIN  , screenHeigh);
    
    [currentScroolView setDelegate:self]; //zooming, we always use the currentScroolView to display image.
    currentScroolView.minimumZoomScale=0.5;
    currentScroolView.maximumZoomScale=6.0;
    currentScroolView.zoomScale = 2;
    
    currentImgView =[[UIImageView alloc] init];
    [currentScroolView addSubview:currentImgView];
    currentScroolView.contentSize = [currentImgView frame].size;
        
    [imgContainer scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, screenHeigh) animated:NO];
}

/**
 * RecaculateViewer Dimension based on orientation
 */
- (void) caculateViewerDim:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect c = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            screenHeigh = c.size.width;
            screenWidth = c.size.height;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            screenHeigh = c.size.height;
            screenWidth = c.size.width;
            break;
    }
}


/**
 * Delegation method when rotate the device
 */
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"Oriented is: %d", fromInterfaceOrientation);
    [self caculateViewerDim:fromInterfaceOrientation];
    imgContainer.frame = CGRectMake(0, 0, screenWidth, screenHeigh);
    
    metaMemeView.frame = CGRectMake(0, screenHeigh - self.navigationController.navigationBar.bounds.size.height -  MEME_META_VIEW_HEIGHT, screenWidth, screenWidth);
    
    prevScroolView.frame = CGRectMake(0,0,screenWidth, screenHeigh);
    currentScroolView.frame = CGRectMake(screenWidth * 1,0,screenWidth, screenHeigh);
    nextScroolView.frame = CGRectMake(screenWidth * 2,0, screenWidth, screenHeigh);
    imgContainer.contentSize = CGSizeMake(screenWidth * 3, screenHeigh);
    currentScroolView.contentSize = [currentImgView frame].size;
    [imgContainer scrollRectToVisible:CGRectMake(screenWidth * 1, 0, screenWidth * 1, screenHeigh) animated:NO];
   
    [self centerImgView:currentImgView atScale:1];
}

/**
 We use paging of UIScrollView now so we don't need this anymore
 */
- (void) bindSwipeEvent {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setEnabled:YES];
    
    [imgContainer addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.enabled = YES;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [imgContainer addGestureRecognizer:singleTap];
    
    
//    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
//    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
//    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//    rightSwipe.numberOfTouchesRequired = 1;
//    [imgContainer addGestureRecognizer:rightSwipe];
//    
//    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
//    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
//    leftSwipe.numberOfTouchesRequired = 1;
//    [imgContainer addGestureRecognizer:leftSwipe];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Default download command to download the first page after main view is loaded
 */
- (void)download {
    currentMemePage++;
    currentMemeIndex=0;
    [self download:currentMemePage andShow:YES];
}

/**
 Once the app fails to download the meme. It shows this button to user can refresh. The button hide itself once pressing.
 */
- (IBAction)refresh:(id)sender {
    [self.refreshButton setHidden:YES];
    [self download];
}

/*
 Failt to download the image. Allow user re-download it.
 */
- (IBAction)retryDownloadMeme:(id) sender {
    [redownloadMemeButton setHidden:YES];
    [self loadImageAtPage:currentMemePage withIndex:currentMemeIndex];
}

/**
 Download the data via the other thread and device if we should show sth after finishing
 */
- (void) download:(NSUInteger)pageToDownload  andShow:(Boolean) show{
    
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * doc = [path objectAtIndex:0];
    
    [self.downloadProgress show:YES];
    downloading = YES;
    //We cannot run it on main queu to avoid block UI thread
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        tag++;
        
        [self fetchFromSource:pageToDownload withTag:tag runIfFound: ^{
            // We are updating UI so let do it on mean thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [imgContainer setHidden:FALSE];
                if (show) {
                    [self loadImage:0];
                }
                [downloadProgress hide:YES];
                downloading = NO;                
            });
            
        } orNotFound:^{
            // We are updating UI so let do it on mean thread
            currentMemePage--;
            currentMemeIndex=0;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cannot find any meme!"
                                                                  message:@"It seems the meme source is down. Try again later."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
                [downloadProgress hide:YES];                
                [self.refreshButton setHidden:NO];
            });
        }];
        
    });
    
}


/**
fetchFromSource should be in Asyntask or run on anothe thread instad of meain thread ot avoid block ui
**/
- (NSUInteger) fetchFromSource:(NSUInteger)pageToDownload withTag:(NSUInteger) aTag runIfFound:(void (^)(void))execBlock orNotFound:(void (^)(void))failBlock {
    //get '/m/:source/:section,:start_id,:end_id:,:quantity' do |source,section,start_id,end_id,quantity|
    NSString * start_id;
    NSString * end_id;
    NSData * dataSource;
    NSArray * memes;
    
    NSUInteger section;
    int quantity = 0;
    section = pageToDownload;
    if (pageToDownload==1) {
        start_id = @"0";
        end_id = @"0";
        quantity = 10;
    } else  {
        start_id = [[[memesList objectAtIndex:(pageToDownload - 1)] objectAtIndex:0] objectForKey:@"id"];
        end_id = [[[memesList objectAtIndex:(pageToDownload - 1)] lastObject] objectForKey:@"id"];
        quantity = [[memesList objectAtIndex:(pageToDownload -1)] count];
    }
    
    NSString * url = [NSString stringWithFormat:@"%@/m/%@/%d,%@,%@,%d", AX_SPIDER_URL, memeSource,pageToDownload, start_id, end_id, quantity];
    //NSString * url = [NSString stringWithFormat:@"http://127.0.0.1:9393/m/%@/%d,%@,%@,%d", memeSource,pageToDownload, start_id, end_id, quantity];
    
    NSLog(@"Start to fetch from this URL%@", url);

    @try {
        dataSource = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        memes = (NSArray *)[dataSource objectFromJSONData];
        NSLog(@"Meme JSON Data: %@", memes);
    }
    @catch (NSException *e) {
        failBlock();
        return 0;
    };
    
    if (memes == nil || [memes isEqual:nil] || [memes count]==0) {
        failBlock();
        return 0;
    }
    
    if (tag==aTag) {
        if( [memes isEqual:nil] || [memes count]==0) {
            NSLog(@"No meme found");
            failBlock();
            return 0;
        } else {
            NSLog(@"Looks good. Inset meme data into current page.");            
            [memesList insertObject:memes atIndex:currentMemePage];
            execBlock();
        }
    } else {
        NSLog(@"memePage is fetched succesfully. However, ignore loading. It seems user navigate and another download action triggered. So ignore it to avoid override current data. This is a old action.");
    }
    return [memes count];
}

- (void)viewDidUnload {
    [self setMemeCommentButton:nil];
    [self setMemeDownloadButton:nil];
    [self setMemeLikeButton:nil];
    [self setMemeShareButton:nil];
    
    [self setImgContainer:nil];
    [self setDownloadProgress:nil];
    [self setMetaMemeView:nil];
    [self setMetaMemeView:nil];
    [self setMemeTitleLbl:nil];
    [self setRefreshButton:nil];
    [self setRedownloadMemeButton:nil];
    [super viewDidUnload];
}

#pragma mark Gesture method
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {

    //calculate minimum scale to perfectly fit image width, and begin at that scale
//    float minimumScale = [currentScroolView frame].size.width  / currentImgView.image.size.width;
//    float newScale = minimumScale;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    if (currentScroolView.zoomScale == currentScroolView.minimumZoomScale)
    {
        currentScroolView.zoomScale = 2;
    } else
    {
        currentScroolView.zoomScale = currentScroolView.minimumZoomScale;
    }
//    [currentScroolView zoomToRect:zoomRect animated:YES];
}

/**
 Hide and unhide toolbar, topbar when touching the screen
 */
- (void)handleSingleTap
{
    isToolbarVisible = !isToolbarVisible;
    [[self navigationController] setNavigationBarHidden:isToolbarVisible];
    [[self metaMemeView] setHidden:isToolbarVisible];
    [[self memeTitleLbl] setHidden:isToolbarVisible];
}

/**
 Zooming via pinching with two finger
 */
- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [imgContainer zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imgContainer zoomToRect:zoomRect animated:YES];
}

/**
 Move to next meme
 */
- (void) handleRightSwipe:(UISwipeGestureRecognizer *) swipeGestureRecognizer {
    [self loadImage:-1];
    NSLog(@"%d", currentMemeIndex);
}

/**
 Don't move if we are downling. Wait until it finishes
 */
- (void) handleLeftSwipe:(UISwipeGestureRecognizer *) swipeGestureRecognizer {
    if (!downloading) {
        [self loadImage:1];
        NSLog(@"%d", currentMemeIndex);
    } else {
        NSLog(@"INFO: %@", @"We are downloading data for next page. plz wait until it finsihes");
    }
}

/**
Caculate which image we should load and show on screen
 */
- (void) loadImage:(int)id {
    if (id<0 && currentMemePage==1 && currentMemeIndex==0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No more!"
                                                          message:@"You are viewing the first meme."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    
    if (id<0 && currentMemePage>0) {
        currentMemeIndex = currentMemeIndex + id;
        if (currentMemeIndex==-1) {
            currentMemePage = currentMemePage -1;
            currentMemeIndex = [[memesList objectAtIndex:currentMemePage] count] -1;
        }
        [self loadImageAtPage:currentMemePage withIndex:currentMemeIndex];
        return;
    }
    
    if (id>=0 && (currentMemeIndex +1 < [[memesList objectAtIndex:currentMemePage] count])) {
        currentMemeIndex = currentMemeIndex + id;
        [self loadImageAtPage:currentMemePage withIndex:currentMemeIndex];
    } else {
        currentMemePage++;
        currentMemeIndex = 0;
        [self download:currentMemePage andShow:YES];
    }
}

- (NSString *) cleanTitle:(NSString *) lbl
{
    NSRange r;
    while ((r = [lbl rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {        
        lbl = [lbl stringByReplacingCharactersInRange:r withString:@""];
    }
    return lbl;
}

/**
 Show a specified to view. We use UIViewScrool and implement a effect of infinitive scrool.
 Basically, we have 3 sub view inside a scroolview. Once we swipte to previous or next view, we load the imgae for the middle view and force UIScroolView come back to this view after finishing navigating.
 */
- (void) loadImageAtPage:(NSUInteger) page withIndex:(int)index {
    memeReady = NO;
    @try {
        NSDictionary * memeToLoad = [[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex];
        NSURL * fileUrl = [NSURL URLWithString:[memeToLoad objectForKey:@"src"]];
        
        NSString * likeCount = [[memeToLoad objectForKey:@"info"] objectForKey:@"like"];
        NSString * commentCount = [[memeToLoad objectForKey:@"info"] objectForKey:@"comment"];
        
        [memeTitleLbl setText:[self cleanTitle:[memeToLoad objectForKey:@"title"]]];
        
        NSString * imgPath = [docRoot stringByAppendingFormat:@"/meme/%@/%@", self.memeSource, [fileUrl lastPathComponent]];
        
        NSLog(@"About to load: %@", [fileUrl absoluteString]);
        //if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
            //So, we need to remove old image view
            for (UIView * v in currentScroolView.subviews) {
                if ([v isKindOfClass:[UIImageView class]]) {
                    [v removeFromSuperview];
                }
            }
            
            //Use SDWeb to load imag async
            [downloadProgress show:YES];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            tag++;
            [manager downloadWithURL:fileUrl
                            delegate:self
                             options:0
                             success:^(UIImage *image, BOOL cached)
                             {
                                 memeReady = YES;
                               //do something with image
                                 NSLog(@"Success to download the image from: %@", cached? @"cache":@"network");
                                 if (cached) {
                                 }
                             }
                             failure:^(NSError * error) {
                                 memeReady = NO;
                                 NSLog(@"Cannot download the image: %@", error);
                                [redownloadMemeButton setHidden:NO];
                                [downloadProgress hide:YES];
                             }];
    } @catch (NSException * e) {
        memeReady = NO;
        NSLog(@"Cannot download the image. Error: %@", e);
        [redownloadMemeButton setHidden:NO];
        [downloadProgress hide:YES];
    }
}

- (void) drawImgToScrool:(UIImage *)img
{
    //Show place holder image
    NSLog(@"Image to draw: %@", img);
    NSLog(@"Original size of this image is: %fx%f", img.size.width, img.size.height);
    currentImgView = nil; //Release it? not sure, need to be do an instrucment
    currentImgView =[[UIImageView alloc] initWithImage:img];
    currentImgView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    currentImageSize = CGSizeMake(img.size.width, img.size.height);
    
    [currentScroolView addSubview:currentImgView];
    
    currentScroolView.contentSize = [currentImgView frame].size;
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [currentScroolView frame].size.width  / [currentImgView frame].size.width;
    
    //Recenter the zoom images    
    UIInterfaceOrientation direction = [[UIApplication sharedApplication] statusBarOrientation];
    switch (direction)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            currentScroolView.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeigh);
            NSLog(@"The screen width and height is: %fx%f", screenWidth, screenHeigh);
            minimumScale = 1;
            currentImgView.frame = CGRectMake((screenWidth - img.size.width / 2)/2, 0, img.size.width/2, img.size.height/2);
            
            currentScroolView.minimumZoomScale = minimumScale;
            currentScroolView.zoomScale = minimumScale;
            NSLog(@"Size of img viewer is: %fx%f", currentImgView.frame.size.width, currentImgView.frame.size.height);
        }
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            float h = minimumScale * [currentImgView frame].size.height;
            NSLog(@"Size after scale is: %fx%f", [currentScroolView frame].size.width, h);
    
            currentScroolView.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeigh);
            
            currentScroolView.minimumZoomScale = minimumScale;
            currentScroolView.zoomScale = minimumScale;

            if ( h < screenHeigh) {
//                currentScroolView.frame = CGRectMake(screenWidth, (screenHeigh - h)/2, screenWidth, h);
                currentImgView.frame = CGRectMake(0, (screenHeigh - h)/2, screenWidth, h);
            }
            
            break;
        }
    }
    
    currentScroolView.maximumZoomScale = 6.0;
    [downloadProgress hide:YES]; //now, f inished download, finish loading Viewm show hide the progress icon
}

#pragma mark SDWebImageDownloaderDelegate method 
/*
 At this point, the image is downloaded properly. We can start to do whateer w/ it.
 */
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    NSLog(@"Finish downloading image. Start to redraw it");
    [self drawImgToScrool:image];
    NSLog(@"Finish redrawing");
}

- (void)webImageManager:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cannot download meme!"
                                                      message:@"Check internet connection.You can retry or ignore and move to next meme."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    NSLog(@"Error. %@", error);
}


#pragma mark UIScroolViewDelegate method
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [currentImgView frame].size.height / scale;
    zoomRect.size.width  = [currentImgView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark UIScroolViewDelegate method
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return currentImgView;
}

#pragma mark UIScroolViewDelegate method
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    NSLog(@"- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale %@, %@, %f", scrollView, view, scale);
    NSLog(@"Zoom ration: %f", scale);
    float h = currentImgView.image.size.height * scale;
    float w = currentImgView.image.size.width * scale;
    if (h < screenHeigh) {
        currentImgView.frame = CGRectMake( (screenWidth - w) /2, (screenHeigh - h)/2, w, h);
    }
   // [self centerImgView:view atScale:scale];
}

/**
 Re position image view to center of screen when rotating the device
 */
- (void) centerImgView:(UIView *)view atScale:(float)scale
{
    UIInterfaceOrientation direction = [[UIApplication sharedApplication] statusBarOrientation];
    switch (direction)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            CGSize scaleSize = CGSizeMake(currentImageSize.width * scale, currentImageSize.height * scale);
            view.frame = CGRectMake((screenWidth - scaleSize.width/2)/2, 0, scaleSize.width / 2, scaleSize.height/2);
            break;
        }
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            CGSize scaleSize = CGSizeMake(currentImageSize.width * scale, currentImageSize.height * scale);
            view.frame = CGRectMake((screenWidth - scaleSize.width/2)/2, 0, scaleSize.width / 2, scaleSize.height/2);
            break;
        }
    };
}

/**
 If a downloading process is happenng. just abondone 
 If everything seems fine, attempt to decide if we should move next or move forward
 Otherwise, do abosultely nothing.
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *) sender
{
    if (downloading)
    {
        NSLog(@"Downloading new data so ignore it");
    }
    else
    {
        //So we are moving forward
        if (imgContainer.contentOffset.x - 2 * AX_VIEW_MARGIN>imgContainer.frame.size.width)
        {
            //Fill in the new image
            [self loadImage:1];
            NSLog(@"Current Meme is: %d", currentMemeIndex);
            //we will always come back the center one to keep infinitg scrool effect
            [imgContainer scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, screenHeigh) animated:NO];
            
        }
    
        if (imgContainer.contentOffset.x + 2 * AX_VIEW_MARGIN< imgContainer.frame.size.width)
        {
            [self loadImage:-1];
            NSLog(@"Current Meme is: %d", currentMemeIndex);
            //we will always come back the center one to keep infinitg scrool effect
            [imgContainer scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, screenHeigh) animated:NO];
            
        } 
        
    }
}

/**
 Show comment view with a WEBUIVIew to loading a comment web page (usually a facebook social comment plugin)
 */
- (IBAction)showComment:(id)sender {
    if (!memeReady) {
        return;
    }
    
    if (commetViewController == nil) {
        commetViewController = [[AXMemeCommentViewController alloc] initWithNibName:@"AXMemeCommentViewController" bundle:nil];
    }
    commetViewController.commentUrl = [[[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex] objectForKey:@"comment_url"];
    NSLog(@"About to load %@", commetViewController.commentUrl);
    
    [UIView beginAnimations:@"animation" context:nil];
    [self.navigationController pushViewController:commetViewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (void)likeMeme:(id)sender {
    if (!memeReady) {
        return;
    }
    
    NSString * meme_id=  [[[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex] objectForKey:@"id"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/m/like",AX_SPIDER_URL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSDictionary *d = [NSDictionary dictionaryWithObjects:@[self.memeSource,meme_id] forKeys:@[@"site",@"id"]];
    NSData * postData = [d JSONData];
    NSLog(@"Data to send: %@", postData);
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

# pragma mark - NSConnection delegate method
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Did fail with error %@" , [error localizedDescription]);
}

# pragma mark - NSConnection delegate method
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse;
    httpResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpResponse statusCode];
    NSLog(@"Status code was %d", statusCode);
}

/**
 ShareKit comes to play at this moment. 
 It handles sharing featue via twitter and facebook
 */
- (IBAction)shareMeme:(id)sender {
    if (!memeReady) {
        return;
    }
    // Create the item to share (in this example, a url)
    NSDictionary * ameme = [[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex];
    NSURL *url = [NSURL URLWithString:[ameme objectForKey:@"url"]];
    NSString * title = [self cleanTitle:[ameme objectForKey:@"title"]];
    NSLog(@"URL %@\nTitle: %@", url, title);
    SHKItem *item = [SHKItem URL:url title:title contentType:SHKURLContentTypeWebpage];
    
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [SHK setRootViewController:self];
    [actionSheet showInView:self.metaMemeView];
    //[actionSheet showFromToolbar:self.metaMemeView];
}

/**
 Save meme to local phone. Require write access to Photo Camera rool to write picture to
*/
-(void)downloadMeme:(id) sender
{
    if (!memeReady) {
        return;
    }

    if (downloading) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cannot save!"
                                                          message:@"Meme is downloading. Try again later."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];

    } else {
        [downloadProgress show:YES];
        UIImageWriteToSavedPhotosAlbum(currentImgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }

}

# pragma mark
/**
 Delegation when fisniging writing picture to photos album
 */
- (void)image:(UIImage *)img didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != nil) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cannot save!"
                                                          message:@"Meme cannot saved to your iOS album. Check your space usage."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Photo saved!"
                                                          message:@"Meme is saved to your iOS album"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    [downloadProgress hide:YES];
}

/**
 Navigate to meme source list. Then user can choose to read another meme site.
 */
- (void) showMemeListView
{    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

@end
