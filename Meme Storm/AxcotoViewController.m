//
//  AxcotoViewController.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 11/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import "AxcotoViewController.h"
#import "AxcotoMemeDetailViewController.h"
#import "SourceCell.h"
#import "AXConfig.h"
#import "UINavigationBar+CustomBackground.h"


@interface AxcotoViewController ()

@end

@implementation AxcotoViewController
{
    NSMutableArray *memeSourceData;
}

@synthesize downloadProgress;
@synthesize avatarFolder;
@synthesize cache;
@synthesize chooseMemeButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self drawUi];
    [self setTitle:@"Meme Storm"];
    cache = [AXCache instance];
    [self prepare];    
    [self loadMemeSource];
}

/**
 Redraw to custom UI
 */
- (void) drawUi
{
    UINavigationBar * bar =  self.navigationController.navigationBar;
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
//        UIImage * bg = [bar createImageWithColor:[UIColor colorWithRed:35/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f]];
        UIImage * bg = [bar createImageWithColor:[UIColor colorWithRed:36/255.0f green:137/255.0f blue:197/255.0f alpha:1.0f]];

        [[UINavigationBar appearance] setBackgroundImage:bg forBarMetrics:UIBarMetricsDefault];
        
    } else {
        UIColor * color = [UIColor colorWithRed:35/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f];
        self.navigationController.navigationBar.tintColor = color;
    }

//    color = [UIColor redColor];
//    self.navigationController.navigationBar.tintColor = color;
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTarget:self selector:@selector(reorderSite) withTitle:@"Edit"];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(reorderSite)];
    
    [self.memeSourceTable setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal.png"]]];
    [self.memeSourceTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

/**
 * Customize setTitle method for navigation bar
 */
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"Montserrat-Bold" size:18.00];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.textColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f];
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMemeSourceTable:nil];
    [self setDownloadProgress:nil];
    [self setDownloadProgress:nil];
    [self setChooseMemeButton:nil];
    [super viewDidUnload];
}

/**
 Prepare folder structure for the app.
 */
- (void) prepare
{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    avatarFolder = [[path objectAtIndex:0] stringByAppendingPathComponent:@"avatar"];
}



/**
 Do 2 things:
 1. Load meme source that users chose and display on table
 2. Update meme source via our API end point. So if on our API end point, we implemented a new meme site, then this step is to make sure information 
    of that site is update into our app data
 
 At the very first time, user have no data for current selected meme. So we choose all meme site by default to full fill this value.
 */
 
- (void) loadMemeSource {
    memeSourceData = (NSMutableArray *) [cache getByKey:@"selected_sources"];
}

- (void) reorderSite
{
    static Boolean edit=NO;
    edit = !edit;
    [self.navigationItem.leftBarButtonItem setTitle:edit?@"Done":@"Edit"];
    [self.memeSourceTable setEditing:edit];
}

- (IBAction)showSourceList:(id)sender {
//showLeftPanelAnimated
    AXSidePanelController * rootViewController =  (AXSidePanelController *) [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController showLeftPanelAnimated:YES];
}

/**
 Come from side panel. 
 Need to refresh the meme list
 */
# pragma mark - AXSidePanelDelegate method
- (void)didShowCenterPanel
{
    [self loadMemeSource];
    if (memeSourceData!=nil && [memeSourceData count]>0) {
        [chooseMemeButton setHidden:YES];
    }
    [self.memeSourceTable reloadData];
}

# pragma mark - UIView method
- (void)viewWillAppear:(BOOL)animated
{
    if (memeSourceData!=nil && [memeSourceData count]>0) {
        [chooseMemeButton setHidden:YES];
    }
    [self.memeSourceTable reloadData];
}

/**
 Left panel is hide. We shold update the list
 */
//#pragma mark - AXSidePanelDelegate method
//- (void) didHideLeftPanel {
//    [self loadMemeSource];
//    [self.memeSourceTable reloadData];
//}

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
    SourceCell * c = (SourceCell *) cell;
    [c paint:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    SourceCell * cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray * objects = [[NSBundle mainBundle] loadNibNamed:@"SourceCell" owner:self options:nil];
        for (id currentObject in objects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (SourceCell *) currentObject;
                break;
            }
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell setMemeTitle:[[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"t"]];
    NSString * avatarFile = [avatarFolder stringByAppendingPathComponent:[[[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"name"] stringByAppendingString:@".png"]];
    NSLog(@"Load thumbnail image %@", avatarFile);
    [cell setAvatar:[UIImage imageWithContentsOfFile:avatarFile]];
    [cell setLastRead:[[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"last_read"]];

    UIView *bgSelectedView = [[UIView alloc] init];
//    [bgSelectedView setBackgroundColor:[UIColor colorWithRed:31/255.0f green:127/255.0f blue:92/255.0f alpha:1.0f]];
    [bgSelectedView setBackgroundColor:[UIColor colorWithRed:35/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f]];
    [cell setSelectedBackgroundView:bgSelectedView];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * s = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self readMemeFor:s atRow:indexPath];
}

-(IBAction)readMemeFor:(id)sender atRow:(NSIndexPath *) aPath{
    AxcotoMemeDetailViewController *secondView = [[AxcotoMemeDetailViewController alloc]
                                    initWithNibName:@"AxcotoMemeDetailViewController"
                                    bundle:nil];
    NSLog(@"Selected source: %@", (NSString *) sender);
    [secondView setMemeSource:(NSString *)sender];
    
    NSMutableDictionary * memeSource =  (NSMutableDictionary *)[memeSourceData objectAtIndex:aPath.row];
    NSDateFormatter * date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"MM-dd-yyyy HH:mm"];
    [memeSource setObject:[date stringFromDate:[NSDate date]] forKey:@"last_read"];
    [cache saveForKey:@"selected_sources" withValue:memeSourceData];
    
    
    [[self navigationController] pushViewController:secondView animated:YES];

}

- (void) cleanMemeCache
{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * doc = [path objectAtIndex:0];
    
    NSString * memeFolder = [doc stringByAppendingFormat:@"/meme/%@",@"funnymama"];
    
    for (int i=0; i<[memeSourceData count]; i++) {
        memeFolder = [doc stringByAppendingFormat:@"/meme/%@", [[memeSourceData objectAtIndex:i] objectForKey:@"name"]];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:memeFolder error:&error]) {
            NSLog(@"About to remove file: %@", [memeFolder stringByAppendingPathComponent:file]);
            BOOL success = [fm removeItemAtPath:[memeFolder stringByAppendingPathComponent:file] error:&error];
            if (!success || error) {
                // it failed.
                NSLog(@"Cannot clean item %@", [memeFolder stringByAppendingPathComponent:file]);
            }
        }
    }
}

@end
