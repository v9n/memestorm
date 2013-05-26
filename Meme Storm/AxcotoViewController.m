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
    NSArray *memeSourceData;
}

@synthesize downloadProgress;
@synthesize avatarFolder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self drawUi];
    [self setTitle:@"Meme Storm"];
    [self loadMemeSource];
}

/**
 Redraw to custom UI
 */
- (void) drawUi
{
    UINavigationBar * bar =  self.navigationController.navigationBar;    
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        UIImage * bg = [bar createImageWithColor:[UIColor colorWithRed:35/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f]];
        [[UINavigationBar appearance] setBackgroundImage:bg forBarMetrics:UIBarMetricsDefault];
    } else {
        
    }
    UIColor * color = [UIColor colorWithRed:35/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = color;

    color = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = color;
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTarget:self selector:@selector(reorderSite) withTitle:@"Edit"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(reorderSite)];
    
    [self.memeSourceTable setBackgroundColor:[UIColor clearColor]];
    [self.memeSourceTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}


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
    [super viewDidUnload];
}

- (void) loadMemeSource {
//    NSString * s1 = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ENVIRONMENT"];
    
    [downloadProgress startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^ {
        
        NSString * s1= [[[NSProcessInfo processInfo] environment] objectForKey:@"ENVIRONMENT"];
        NSLog(@"Environment %@", s1);        
        
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * f = [path objectAtIndex:0];
        f = [f stringByAppendingString:@"/source.json"];
                
        NSString * url = [NSString stringWithFormat:@"%@/m/list", AX_SPIDER_URL];
        //NSString * url = @"http://127.0.0.1:9393/m/list";
        NSLog(@"Start to load meme source at: %@", url);
        
        NSFileManager * fileMan = [NSFileManager defaultManager];
        NSData *s = Nil;
        int attempt =0;
        
        if ([fileMan fileExistsAtPath:f]) {
            NSLog(@"Read memeSource form cache: %@", f);
            NSError * e;
            NSDictionary * attr = [fileMan attributesOfItemAtPath:f error:&e];
            if (attr !=nil) {
                NSDate * d = [attr objectForKey:NSFileCreationDate];
                NSLog(@"The cache is created at %@\n. This is was %f seconds ago", d, [d timeIntervalSinceNow]);
                if ([d timeIntervalSinceNow] + 24 * 3600 > 0) {
                    NSLog(@"There is no need to fetch the data");
                    s = [[NSData alloc] initWithContentsOfFile:f];
                } else {
                    NSLog(@"There is need to fetch the data");
                }
            }
        
        }
        
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
        
            while (attempt<=2 && s==Nil)
            {
                attempt++;
                NSLog(@"Attempt #%d to get memesource list", attempt);
                @try {
                    s =  [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
                    [s writeToFile:f atomically:TRUE];
                    
                }
                @catch (NSException * e){
                    NSLog(@"Fail at attempt #%d. Error:%@", attempt, e);
                }
            }
            
        if (s==nil) {
            
            return;
        }
        
        memeSourceData = (NSArray *)[s objectFromJSONData];
        
        //Fetch avatar
        for (int count=0; count<[memeSourceData count]; count++) {
            attempt = 0; s=nil;
            NSString * url = [[memeSourceData objectAtIndex:count] objectForKey:@"i"];
            NSString * avatarFileName = [[[memeSourceData objectAtIndex:count] objectForKey:@"name"] stringByAppendingString:@".png"];
            avatarFileName = [avatarFolder stringByAppendingPathComponent:avatarFileName];
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
        
        NSLog(@"Meme Source Data: %@", memeSourceData);
        
        //Update UI on mean thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (memeSourceData==NULL) {
                [downloadProgress stopAnimating];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cannot fetch meme data!"
                                                                  message:@"Check your data connection then open the app again."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];                
                return;
            } else {
                [self.memeSourceTable reloadData];
                [downloadProgress stopAnimating];
            }
            
            //Clean old cache
            //@TODO make it smater
            //[self cleanMemeCache];
            
        });
        
    });
}

- (void) reorderSite
{
    static Boolean edit=NO;
    edit = !edit;
    [self.navigationItem.leftBarButtonItem setTitle:edit?@"Done":@"Edit"];
    [self.memeSourceTable setEditing:edit];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * s = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self readMemeFor:s];
}

-(IBAction)readMemeFor:(id)sender{
    AxcotoMemeDetailViewController *secondView = [[AxcotoMemeDetailViewController alloc]
                                    initWithNibName:@"AxcotoMemeDetailViewController"
                                    bundle:nil];
    NSLog(@"Selected source: %@", (NSString *) sender);
    [secondView setMemeSource:(NSString *)sender];
    
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
