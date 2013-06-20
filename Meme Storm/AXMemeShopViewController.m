//
//  AXMemeShopViewController.m
//  Meme Storm
//
//  Created by Hoa Diem Nguyet on 6/2/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "AXMemeShopViewController.h"

#define kAXDATE_FORMAT @"MM-dd-yyyy HH:mm"
#define kAX_CACHE_SOURCE 60 * 60 * 24 * 1 //In seconds

@interface AXMemeShopViewController ()

@end

@implementation AXMemeShopViewController

@synthesize memeSourceTable, memeSourceData, selectedMarks, cache, avatarFolder;

@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selectedMarks = [[NSMutableArray alloc] init];
        cache = [AXCache instance];
        [self loadMemeSource];
        textPull = @"Pull down to refresh...";
        textRelease = @"Release to refresh...";
        textLoading = @"Loading...";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addPullToRefresh];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void) didHideLeftPanel {
    [self saveSelectedSource];
}

- (void) didShowLeftPanel {
    NSString *t = [cache getByKey:@"last_sync"];
    if (t == nil) { //never sync before
        [self updateSourceList];
    } else {
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"hhmm'Z' MM/dd/yy"];
//        NSDate *date = [dateFormat dateFromString:string];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kAXDATE_FORMAT];
        NSDate *d = [dateFormatter dateFromString:t];
        NSTimeInterval diff = [d timeIntervalSinceNow];
        if ( (diff + kAX_CACHE_SOURCE) < 0 ) {
            [self updateSourceList];
        }
    }
}

/**
 Store selected site and other configuration if has some.
 */
- (void) saveSelectedSource
{
    NSMutableArray * selectedSource = [[NSMutableArray alloc] initWithCapacity:[selectedMarks count]];
    NSArray * sources = [cache getByKey:@"sources"];
    
    for (NSDictionary * d in sources)
    {
        if ([selectedMarks containsObject:[d objectForKey:@"u"]])
        {
            [selectedSource addObject:d];
        }
    }
    
    [cache saveForKey:@"selected_sources" withValue:selectedSource];
}

- (void) loadMemeSource {
    memeSourceData= (NSArray *) [cache getByKey:@"sources"];
    
    NSArray * selectedSource = (NSArray *) [cache getByKey:@"selected_sources"];
    if ( selectedSource!=nil && ([selectedSource count] > 0) ) {
        for (NSDictionary * d in selectedSource) {
            [selectedMarks addObject:[d objectForKey:@"u"]];
        }
    }
}

/**
 Sync meme site list from remote to local.
 So if a site is added on server, then this method will download meta data and store in internal cache
 */
- (void) updateSourceList
{
    
    NSString * s1= [[[NSProcessInfo processInfo] environment] objectForKey:@"ENVIRONMENT"];
    NSLog(@"Environment %@", s1);
    
    NSString * url = [NSString stringWithFormat:@"%@/m/list", AX_SPIDER_URL];
    //NSString * url = @"http://127.0.0.1:9393/m/list";
    NSLog(@"Will load meme source at: %@", url);

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Loading Source";
    
    dispatch_async(dispatch_get_global_queue(0,0), ^ {
        NSData *s = Nil;
        NSArray * supportedMemeSite;
        
        int attempt =0;
        
        while (attempt<=5 && s==Nil)
        {
            attempt++;
            NSLog(@"Attempt #%d to get memesource list", attempt);
            @try {
                s =  [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
            }
            @catch (NSException * e){
                s= nil;
                NSLog(@"Fail at attempt #%d. Error:%@", attempt, e);
            }
        }
        
        if (s==nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cannot fetch meme data!"
                                                                  message:@"Check your data connection then open the app again."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
                return;
                
                
            });
            return;
        }
        
        NSDateFormatter * date = [[NSDateFormatter alloc] init];
        [date setDateFormat:kAXDATE_FORMAT];
        [cache saveForKey:@"last_sync" withValue:[date stringFromDate:[NSDate date]]];
        
        supportedMemeSite = [s objectFromJSONData];
        [cache saveForKey:@"sources" withValue:[s objectFromJSONData]];

//                    //No longer support avatar
//        for (int count=0; count<[supportedMemeSite count]; count++) {
//
//            [self downloadAvatarForSite:(NSDictionary *)[supportedMemeSite objectAtIndex:count]];
//        }
        
        if (memeSourceData == nil) {
            memeSourceData = supportedMemeSite; //On the first time, we show all meme site we supported, or we can define
        }
        [cache saveForKey:@"sources" withValue:memeSourceData];
        
        
        NSLog(@"Meme Source Data: %@", memeSourceData);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self.memeSourceTable reloadData];
            [self stopLoading];
        });
        
        
    });
}

# pragma mark - UIView method
- (void)viewWillAppear:(BOOL)animated
{
    [self.memeSourceTable reloadData];
}

/**
 Download avatar picture for a meme site
 */
- (void) downloadAvatarForSite:(NSDictionary *) site {
    int attempt = 0;
    NSData * s=nil;
    NSString * url = [site objectForKey:@"i"];
    NSString * avatarFileName = [[site objectForKey:@"name"] stringByAppendingString:@".png"];
    avatarFileName = [avatarFolder stringByAppendingPathComponent:avatarFileName];
    static NSFileManager *fileMan = nil;
    if (fileMan==nil) {
        fileMan= [NSFileManager defaultManager];
    }
    
    if (![fileMan fileExistsAtPath:avatarFileName]) {
        while (attempt<=2 && s==Nil)
        {
            attempt++;
            NSLog(@"Attempt #%d to get avatar", attempt);
            @try {
                s =  [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
                [s writeToFile:avatarFileName atomically:TRUE];
            }
            @catch (NSException * e){
                NSLog(@"Fail at attempt #%d. Error:%@", attempt, e);
            }
        }
    }
}

/**
 Prepare folder structure for the app.
 */
- (void) prepare
{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager * fileMan = [NSFileManager defaultManager];
    avatarFolder = [[path objectAtIndex:0] stringByAppendingPathComponent:@"avatar"];
    if (![fileMan fileExistsAtPath:avatarFolder]) {
        NSError * e;
        NSLog(@"Trying to create avatar folder");
        if ([fileMan createDirectoryAtPath:avatarFolder withIntermediateDirectories:YES attributes:nil error:&e])
        {
            NSLog(@"%@", @"Success to create memeFolder");
        }
        else
        {
            NSLog(@"[%@] ERROR: attempting to create avatar directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
}

/**
 add pull to refresh header for table view
 */
- (void) addPullToRefresh
{
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [self.memeSourceTable addSubview:refreshHeaderView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"";//@"Meme Sources";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [memeSourceData count];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CRTableViewCellIdentifier = @"cellIdentifier";
    
    // init the CRTableViewCell
    CRTableViewCell *cell = (CRTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CRTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[CRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CRTableViewCellIdentifier];
    }
    
    // Check if the cell is currently selected (marked)
    NSString *text = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"u"];
    cell.isSelected = [selectedMarks containsObject:text] ? YES : NO;
    
    cell.textLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"u"];
    
    if ([selectedMarks containsObject:text])// Is selected?
        [selectedMarks removeObject:text];
    else
        [selectedMarks addObject:text];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0) {
            self.memeSourceTable.contentInset = UIEdgeInsetsZero;
        } else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT) {
            self.memeSourceTable.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
//                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
//                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.memeSourceTable.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;        
    }];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.memeSourceTable.contentInset = UIEdgeInsetsZero;
//        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
}

- (void)refresh {
    [self updateSourceList];
}

@end
