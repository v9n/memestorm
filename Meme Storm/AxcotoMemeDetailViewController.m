//
//  AxcotoMemeDetailViewController.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/1/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import "AxcotoMemeDetailViewController.h"

//#import "ImageZoomingViewController.h"
//#import "TapDetectingImageView.h"

#define ZOOM_STEP 1.5

@interface AxcotoMemeDetailViewController ()
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end



@implementation AxcotoMemeDetailViewController

@synthesize memeSource;
@synthesize imgContainer, imgViewUi, downloadProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:[@"Meme Browser" stringByAppendingString: self.memeSource]];
    [[self navigationController] setNavigationBarHidden:TRUE];
    
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docRoot = [path objectAtIndex:0];
    
    currentMemeIndex = 0; //show the first picture
    currentMemePage = 0;
    memesList = [NSMutableArray arrayWithCapacity:5]; //NSMutuableArrat auto expand when needed. This is just to allocate an enought amount for initalize this array. So, 5 is an affordable number for this purpose.
    [memesList insertObject:@"marked_bound_page" atIndex:0];
    [self download];
    
    [self setUpImageViewer];
    [self bindSwipeEvent];    
}

- (void) setUpImageViewer {
    imgContainer.bouncesZoom = YES;
    imgContainer.delegate = self;
    imgContainer.clipsToBounds = YES;
    
    imgViewUi.autoresizingMask = ( UIViewAutoresizingFlexibleWidth );
    NSString * imgPath = [docRoot stringByAppendingFormat:@"/meme/d.jpg"];
    //imgViewUi =[[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]]];
    NSString * resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/toxic_angel.jpg"];
    
    NSFileManager * fileMan = [NSFileManager defaultManager];
    if ([fileMan fileExistsAtPath:imgPath]==FALSE) {
        NSError * error;
        [fileMan copyItemAtPath:resourcePath toPath:imgPath error:&error];
        NSLog(@"%@", error);
    }
    
    imgViewUi =[[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]]];
    [imgContainer addSubview:imgViewUi];
    imgContainer.contentSize = [imgViewUi frame].size;
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [imgContainer frame].size.width  / [imgViewUi frame].size.width;
    imgContainer.minimumZoomScale = minimumScale;
    imgContainer.zoomScale = minimumScale;
    //imageScrollView.maximumZoomScale = 1.0;
}

- (void) bindSwipeEvent {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [imgViewUi addGestureRecognizer:doubleTap];
    [imgViewUi addGestureRecognizer:twoFingerTap];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipe.numberOfTouchesRequired = 1;
    [imgContainer addGestureRecognizer:rightSwipe];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipe.numberOfTouchesRequired = 1;
    [imgContainer addGestureRecognizer:leftSwipe];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) download {
    currentMemePage++;
    currentMemeIndex=0;
    [self download:1 andShow:YES];
}

- (void) download:(NSUInteger)pageToDownload  andShow:(Boolean) show{
    
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * doc = [path objectAtIndex:0];
    NSString * memeFolder = [doc stringByAppendingPathComponent:@"meme/funnymama"];
    
    [downloadProgress setHidden:FALSE];
    [downloadProgress setProgress:0 animated:YES];
    //We cannot run it on main queu to avoid block UI thread
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        [self fetchFromSource:pageToDownload];
        NSFileManager * fileMan = [NSFileManager defaultManager];
        
        if (![fileMan fileExistsAtPath:memeFolder]) {
            //try to create if not existed yet
            NSError * e;
            NSLog(@"Trying to validate memeFolder %@", memeFolder);
            if ([[NSFileManager defaultManager] createDirectoryAtPath:memeFolder withIntermediateDirectories:YES attributes:nil error:&e]) {
                NSLog(@"%@", @"Success to create memeFolder");
            } else {
                NSLog(@"[%@] ERROR: attempting to create meme directory", [self class]);
                NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
            }
        }
        
        NSArray * urls = [memesList objectAtIndex:pageToDownload];
        NSURL * fileUrl;
        NSData * imageData;
        NSString * memeFile;
        float totalProgress;
        for (int i=0; i< [urls count]; i++) {
            fileUrl = [NSURL URLWithString:(NSString *) [[urls objectAtIndex:i] objectForKey:@"src"] ];
            memeFile = [memeFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", [fileUrl lastPathComponent]]]; //pageToDownload, i]];
            
            if ([fileMan fileExistsAtPath:memeFile]) {
                NSLog(@"INFO: File %@ is existed in cache folder. Ignore downloading", memeFile);
                
            } else {
                NSLog(@"INFO: attempting to download file %@", memeFile);
                imageData = [NSData dataWithContentsOfURL:fileUrl];
                NSLog(@"INFO: attempting to create file %@", memeFile);
                [imageData writeToFile:memeFile atomically:YES];
                NSLog(@"Download completed: %f", totalProgress);
                // We are updating UI so let do it on mean thread
                
            }
            totalProgress = (float)(i+1) / (float)[urls count];
            dispatch_async(dispatch_get_main_queue(), ^{
                [downloadProgress setProgress:totalProgress];
                [downloadProgress setNeedsDisplay];
            });
        }
        
        // We are updating UI so let do it on mean thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [imgContainer setHidden:FALSE];
            if (show) {
                [self loadImage:0];
            }
            [downloadProgress setHidden:TRUE];
        });
        
        
    });
}


/**
* fetchFromSource should be in Asyntask or run on anothe thread instad of meain thread ot avoid block ui
**/
- (void) fetchFromSource:(NSUInteger)pageToDownload {
    //get '/m/:source/:section,:start_id,:end_id:,:quantity' do |source,section,start_id,end_id,quantity|
    NSString * start_id;
    NSString * end_id;
    NSUInteger section;
    int quantity = 0;
    section = pageToDownload;
    if (pageToDownload<=2) {
        start_id = @"0";
        end_id = @"0";
        quantity = 0;
    } else {
        start_id = [[memesList objectAtIndex:(pageToDownload - 1)] objectAtIndex:0];
        end_id = [[memesList objectAtIndex:(pageToDownload - 1)] lastObject];
        quantity = [[memesList objectAtIndex:(pageToDownload -1)] count];
    }
    //NSString * url = [NSString stringWithFormat:@"http://meme-storm.herokuapp.com/m/%@/%d,%@,%@,%d", memeSource,//pageToDownload, start_id, end_id, quantity];
    NSString * url = [NSString stringWithFormat:@"http://127.0.0.1:9393/m/%@/%d,%@,%@,%d", memeSource,pageToDownload, start_id, end_id, quantity];
    
    NSLog(@"Start to fetch from this URL%@", url);
    
    NSData * dataSource = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSArray * memes = (NSArray *)[dataSource objectFromJSONData];
    NSLog(@"%@", memes);
   [memesList insertObject:memes atIndex:currentMemePage];

}

- (void)viewDidUnload {
    [self setImgContainer:nil];
    [self setImgViewUi:nil];
    [self setDownloadProgress:nil];
    [super viewDidUnload];
}


// Implement a single scroll view delegate method
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return imgViewUi;
}

#pragma mark Gesture method
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // zoom in
    float newScale = [imgContainer zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imgContainer zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [imgContainer zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imgContainer zoomToRect:zoomRect animated:YES];
}

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

- (void) loadImageAtPage:(NSUInteger) page withIndex:(int)index {
    @try {
        NSURL * fileUrl = [NSURL URLWithString:[[[memesList objectAtIndex:currentMemePage] objectAtIndex:currentMemeIndex] objectForKey:@"src"]];
        //NSString * imgPath = [docRoot stringByAppendingFormat:@"/meme/funnymama/%d_%d.jpg", currentMemePage, currentMemeIndex];
        NSString * imgPath = [docRoot stringByAppendingFormat:@"/meme/funnymama/%@.jpg", [fileUrl lastPathComponent]];
        
        NSLog(@"About to load: %@", imgPath);
        if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
            //So, we need to remove old view
            for (UIView * v in imgContainer.subviews) {
                if ([v isKindOfClass:[UIImageView class]]) {
                    [v removeFromSuperview];
                }
            }
            imgViewUi = nil; //Release it? not sure, need to be do an instrucment
            
                        imgViewUi =[[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]]];
                
                        [imgContainer addSubview:imgViewUi];
            
                        imgContainer.contentSize = [imgViewUi frame].size;
                        // calculate minimum scale to perfectly fit image width, and begin at that scale
                        float minimumScale = [imgContainer frame].size.width  / [imgViewUi frame].size.width;
                        imgContainer.minimumZoomScale = minimumScale;
                        imgContainer.zoomScale = minimumScale;
                        //imageScrollView.maximumZoomScale = 1.0;
            
//            UIImage * v = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]];
//            //imgViewUi.image = v;
//            [imgViewUi setImage:v];
//            //imgViewUi.frame = CGRectMake(0, 0, v.size.width, v.size.height);
//            
//            imgContainer.contentSize = [imgViewUi frame].size;
//            float zoomScale = [imgContainer frame].size.width / v.size.width;            
//            [imgContainer setZoomScale:zoomScale];
//            [imgContainer setMinimumZoomScale:zoomScale];
//            //[imgViewUi se
//            NSLog(@"[INFO] Loading new image with width %f", v.size.width);
//            NSLog(@"[INFO] Loading new image with height %f", v.size.height);
            
            
//            imgViewUi =[[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]]];
//            [imgContainer addSubview:imgViewUi];
//            imgContainer.contentSize = [imgViewUi frame].size;
//            // calculate minimum scale to perfectly fit image width, and begin at that scale
//            float minimumScale = [imgContainer frame].size.width  / [imgViewUi frame].size.width;
//            imgContainer.minimumZoomScale = minimumScale;
//            imgContainer.zoomScale = minimumScale;
//            //imageScrollView.maximumZoomScale = 1.0;
            
        }
    } @catch (NSException * e) {
        NSLog(@"%@", e);
    }
}


#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imgContainer frame].size.height / scale;
    zoomRect.size.width  = [imgContainer frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


@end
