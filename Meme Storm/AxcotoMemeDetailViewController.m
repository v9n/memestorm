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

#define MEME_META_VIEW_HEIGHT 27
#define ZOOM_STEP 1.5
#define AX_VIEW_MARGIN 10

NSString * const AXMemeBackground = @"bg.png";
NSString * const AXBarBkgImg = @"toolbar-bg";

@interface AxcotoMemeDetailViewController ()
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation AxcotoMemeDetailViewController

@synthesize memeSource;
@synthesize imgContainer, downloadProgress, metaMemeView;

@synthesize prevScroolView, currentScroolView, currentScroolViewContainer, nextScroolView;
@synthesize prevImgView, currentImgView, nextImgView;

@synthesize memeShareButton, memeCommentButton, memeLikeButton, memeDownloadButton;
@synthesize memeTitleLbl;
@synthesize tag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationController] setNavigationBarHidden:NO];
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"arrow-left"] target:self selector:@selector(showMemeListView)];
        
        memeLikeButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-like"] target:self selector:@selector(showComment:)];
        memeShareButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-share-b"] target:self selector:@selector(shareMeme:)];
        memeDownloadButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-download"] target:self selector:@selector(downloadMeme:)];
        memeCommentButton = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"mini-com"] target:self selector:@selector(showComment:)];
        tag = 0;
        self.navigationItem.rightBarButtonItems = @[memeShareButton, memeDownloadButton, memeCommentButton, memeLikeButton];
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
    [self download];
    
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
    [self handleSingleTap];    
}

/**
 Prepare controller and object. Set their location, initalizr their value or so
 */
- (void) setUpImageViewer {
    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeigh);

    imgContainer.delegate = self;
    imgContainer.pagingEnabled = YES;
    imgContainer.frame = CGRectMake(0, 0, screenWidth, screenHeigh);
    NSLog(@"The height of imgContainer is %f", imgContainer.frame.size.height);
    
    metaMemeView.frame = CGRectMake(0, screenHeigh - self.navigationController.navigationBar.bounds.size.height -  MEME_META_VIEW_HEIGHT - 20 , screenWidth, MEME_META_VIEW_HEIGHT); //20 is heigh of status bar
    
    [metaMemeView setHidden:FALSE];
//    [metaMemeView setBackgroundColor:[UIColor whiteColor]];
//    [metaMemeView setAlpha:0.7];
    
    imgContainer.bouncesZoom = YES;
    imgContainer.clipsToBounds = YES;
//    memeTitleLbl.frame = CGRectMake(0, metaMemeView.frame.origin.y - metaMemeView.frame.size.height - memeTitleLbl.frame.size.height, screenWidth, memeTitleLbl.frame.size.height);
//    [memeTitleLbl setBackgroundColor:[UIColor clearColor]];
    
    NSString * imgPath = [docRoot stringByAppendingFormat:@"/meme/d.jpg"];
    NSString * resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@", AXMemeBackground];
    
    NSFileManager * fileMan = [NSFileManager defaultManager];
    if ([fileMan fileExistsAtPath:imgPath]==FALSE) {
        NSError * error;
        [fileMan copyItemAtPath:resourcePath toPath:imgPath error:&error];
        NSLog(@"%@", error);
    }
  
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
    
    currentImgView =[[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]]];
    [currentScroolView addSubview:currentImgView];
    currentScroolView.contentSize = [currentImgView frame].size;
        
    [imgContainer scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, screenHeigh) animated:NO];
    
    downloadProgress.frame = CGRectMake((screenWidth - downloadProgress.frame.size.width) / 2, 100, downloadProgress.frame.size.width, downloadProgress.frame.size.height);
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
    downloadProgress.frame = CGRectMake((screenWidth - downloadProgress.frame.size.width) / 2, 100, downloadProgress.frame.size.width, downloadProgress.frame.size.height);
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
- (void) download {
    currentMemePage++;
    currentMemeIndex=0;
    [self download:1 andShow:YES];
}

/**
 Download the data via the other thread and device if we should show sth after finishing
 */
- (void) download:(NSUInteger)pageToDownload  andShow:(Boolean) show{
    
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * doc = [path objectAtIndex:0];
    NSString * memeFolder = [doc stringByAppendingFormat:@"/meme/%@",self.memeSource];
    
    [downloadProgress setHidden:FALSE];
    [downloadProgress startAnimating];
    downloading = YES;
    //We cannot run it on main queu to avoid block UI thread
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        tag++;
        [self fetchFromSource:pageToDownload withTag:tag thenRun: ^{
            // We are updating UI so let do it on mean thread
            dispatch_async(dispatch_get_main_queue(), ^{
                downloading = NO;
                [imgContainer setHidden:FALSE];
                if (show) {
                    [self loadImage:0];
                }
                [downloadProgress setHidden:TRUE];
                [downloadProgress stopAnimating];
            });
            
        }];
        
    });
    
}


/**
* fetchFromSource should be in Asyntask or run on anothe thread instad of meain thread ot avoid block ui
**/
- (void) fetchFromSource:(NSUInteger)pageToDownload withTag:(NSUInteger) aTag thenRun:(void (^)(void))execBlock{
    //get '/m/:source/:section,:start_id,:end_id:,:quantity' do |source,section,start_id,end_id,quantity|
    NSString * start_id;
    NSString * end_id;
    NSUInteger section;
    int quantity = 0;
    section = pageToDownload;
    if (pageToDownload==1) {
        start_id = @"0";
        end_id = @"0";
        quantity = 10;
    } else //(pageToDownload==2) {
//        start_id = @"0";
//        end_id = @"0";
//        quantity = [[memesList objectAtIndex:(pageToDownload -1)] count];
//    } else {
    {
        start_id = [[[memesList objectAtIndex:(pageToDownload - 1)] objectAtIndex:0] objectForKey:@"id"];
        end_id = [[[memesList objectAtIndex:(pageToDownload - 1)] lastObject] objectForKey:@"id"];
        quantity = [[memesList objectAtIndex:(pageToDownload -1)] count];
    }
    
    NSString * url = [NSString stringWithFormat:@"%@/m/%@/%d,%@,%@,%d", AX_SPIDER_URL, memeSource,pageToDownload, start_id, end_id, quantity];
    //NSString * url = [NSString stringWithFormat:@"http://127.0.0.1:9393/m/%@/%d,%@,%@,%d", memeSource,pageToDownload, start_id, end_id, quantity];
    
    NSLog(@"Start to fetch from this URL%@", url);    
    NSData * dataSource = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSArray * memes = (NSArray *)[dataSource objectFromJSONData];
    NSLog(@"%@", memes);
   [memesList insertObject:memes atIndex:currentMemePage];
    
    if (tag==aTag) {
        NSLog(@"Looks good. Go ahead and load download image to view");        
        execBlock();
    } else {
        NSLog(@"Download finish but ignire loading. It seems user move to another step already");
    }
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
    [super viewDidUnload];
}

#pragma mark Gesture method
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {

    //calculate minimum scale to perfectly fit image width, and begin at that scale
//    float minimumScale = [currentScroolView frame].size.width  / currentImgView.image.size.width;
//    float newScale = minimumScale;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];

    currentScroolView.zoomScale = currentScroolView.minimumZoomScale;
//    [currentScroolView zoomToRect:zoomRect animated:YES];
}

/**
 Hide and unhide toolbar, topbar when touching the screen
 */
- (void)handleSingleTap
{
    static Boolean clicked = NO;
    [[self navigationController] setNavigationBarHidden:clicked];
    [[self metaMemeView] setHidden:clicked];
    [[self memeTitleLbl] setHidden:clicked];
    clicked = !clicked;    
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
    if ([downloadProgress isHidden]) {
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

/**
 Show a specified to view. We use UIViewScrool and implement a effect of infinitive scrool.
 Basically, we have 3 sub view inside a scroolview. Once we swipte to previous or next view, we load the imgae for the middle view and force UIScroolView come back to this view after finishing navigating.
 */
- (void) loadImageAtPage:(NSUInteger) page withIndex:(int)index {
    @try {
        NSDictionary * memeToLoad = [[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex];
        NSURL * fileUrl = [NSURL URLWithString:[memeToLoad objectForKey:@"src"]];
        
        NSString * likeCount = [[memeToLoad objectForKey:@"info"] objectForKey:@"like"];
        NSString * commentCount = [[memeToLoad objectForKey:@"info"] objectForKey:@"comment"];
        
//        if ([likeCount isEqualToString:@""]) {
////            [socialMetric setText:[NSString stringWithFormat:@"%@ Comment", commentCount]];
////            
//        } else {
//            
////            [socialMetric setText:[NSString stringWithFormat:@"%@ Comment, %@ Likes", commentCount, likeCount]];
//            
//        }
        
        [memeTitleLbl setText:[memeToLoad objectForKey:@"title"]];
        
        NSString * imgPath = [docRoot stringByAppendingFormat:@"/meme/%@/%@", self.memeSource, [fileUrl lastPathComponent]];
        
        NSLog(@"About to load: %@", fileUrl);
        //if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
            //So, we need to remove old image view
            for (UIView * v in currentScroolView.subviews) {
                if ([v isKindOfClass:[UIImageView class]]) {
                    [v removeFromSuperview];
                }
            }
            
            //Use SDWeb to load imag async
            [downloadProgress startAnimating];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            tag++;
            [manager downloadWithURL:fileUrl
                            delegate:self
                             options:0
                             success:^(UIImage *image, BOOL cached)
                             {
                               //do something with image
                                 NSLog(@"Success to download the image from: %@", cached? @"cache":@"network");
                                 if (cached) {
                                     //try to write it down
//                                     NSData * imgData = UIImageJPEGRepresentation(image, 100);
//                                     [imgData writeToFile:imgPath atomically:YES];
                                 }
                             }
                             failure:^(NSError * error) {
                                 NSLog(@"Cannot download the image: %@", error);
                             }];
            //End SDWeb
            
            //Show place holder image
//            UIImage * img = [UIImage imageNamed:@"bg"];
//            UIImage * img = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]];
//            [self drawImgToScrool:img];
        
        //}
    } @catch (NSException * e) {
    //    NSLog(@"Eror%@", e.reason);
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
}

#pragma mark SDWebImageDownloaderDelegate method 
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    NSLog(@"Finish downloading image. Start to redraw it");
    [self drawImgToScrool:image];
    NSLog(@"Finish redrawing");
    [downloadProgress stopAnimating];
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
    AXMemeCommentViewController * commetViewController;
    commetViewController = [[AXMemeCommentViewController alloc] initWithNibName:@"AXMemeCommentViewController" bundle:nil];
    commetViewController.commentUrl = [[[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex] objectForKey:@"comment_url"];
    NSLog(@"About to load %@", commetViewController.commentUrl);
    
    [UIView beginAnimations:@"animation" context:nil];
    [self.navigationController pushViewController:commetViewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

/**
 ShareKit comes to play at this moment. 
 It handles sharing featue via twitter and facebook
 */
- (IBAction)shareMeme:(id)sender {
    // Create the item to share (in this example, a url)
    NSDictionary * ameme = [[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex];
    NSURL *url = [NSURL URLWithString:[ameme objectForKey:@"url"]];
    NSLog(@"URL %@\nTitle: %@", url, [ameme objectForKey:@"title"]);
    SHKItem *item = [SHKItem URL:url title:[ameme objectForKey:@"title"] contentType:SHKURLContentTypeWebpage];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:self];
    
    // Display the action sheet
    [actionSheet showInView:self.metaMemeView];
    //[actionSheet showFromToolbar:self.metaMemeView];
}

/**
 Save meme to local phone. Require write access to Photo Camera rool to write picture to
*/
-(void)downloadMeme:(id) sender
{
    if ([downloadProgress isAnimating]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cannot save!"
                                                          message:@"Meme is downloading. Try again later."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];

    } else {
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
}

/**
 Navigate to meme source list. Then user can choose to read another meme site.
 */
- (void) showMemeListView
{    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

@end
