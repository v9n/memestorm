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
        NSLog(@"%@", s1);
        
        
        NSString * url = @"http://meme-storm.herokuapp.com/m/list";
        //NSString * url = @"http://127.0.0.1:9393/m/list";
        NSLog(@"Start to load meme source at: %@", url);
        NSData *s =  [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * f = [path objectAtIndex:0];
        f = [f stringByAppendingString:@"/source.json"];
        [s writeToFile:f atomically:TRUE];
        memeSourceData = (NSArray *)[s objectFromJSONData];
        NSLog(@"Meme Source Data: %@", memeSourceData);
        
        //Update UI on mean thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.memeSourceTable reloadData];
            [downloadProgress stopAnimating];
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
    
    cell.textLabel.text = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"t"];
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
    [secondView setMemeSource:(NSString *)sender];
    
    [[self navigationController] pushViewController:secondView animated:YES];

}



@end
