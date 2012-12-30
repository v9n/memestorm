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

@interface AxcotoViewController ()

@end

@implementation AxcotoViewController
{
    NSArray *memeSourceData;
}

@synthesize downloadProgress;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //memeSourceData = [NSArray alloc] i;// [NSArray arrayWithObjects: [NSDictionary dictionaryWithObjectsAndKeys: @"funnymama.com", @"url", @"Funny Mama", @"name", nil],  [NSDictionary dictionaryWithObjectsAndKeys: @"LolHapens.com", @"url", @"LolHappens", @"name", nil],  nil];
    
    [self setTitle:@"Meme Storm"];    
    [self loadMemeSource];
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
                
        NSString * url = @"http://meme.axcoto.com/m/list";
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
            
        
        
        memeSourceData = (NSArray *)[s objectFromJSONData];
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
        });
        
    });
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
    cell.textLabel.text = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"t"];
    cell.detailTextLabel.text = @"Funny pic";
    
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



@end
