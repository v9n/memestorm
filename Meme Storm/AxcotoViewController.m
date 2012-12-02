//
//  AxcotoViewController.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 11/30/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import "AxcotoViewController.h"
#import "AxcotoMemeDetailViewController.h"

@interface AxcotoViewController ()

@end

@implementation AxcotoViewController
{
    NSArray *memeSourceData;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    memeSourceData = [NSArray arrayWithObjects: [NSDictionary dictionaryWithObjectsAndKeys: @"funnymama.com", @"url", @"Funny Mama", @"name", nil],  [NSDictionary dictionaryWithObjectsAndKeys: @"LolHapens.com", @"url", @"LolHappens", @"name", nil],  nil];
    
    [self setTitle:@"Meme Storm"];
    
    [self loadMemeSource];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMemeSourceTable:nil];
    [super viewDidUnload];
}

- (void) loadMemeSource {
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Meme Sources";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [memeSourceData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
//    [self.navigationController pushViewController:dvController animated:YES];
//    [dvController release];
//    dvController = nil;
    [self readMemeFor:@"funnymama"];
}

-(IBAction)readMemeFor:(id)sender{
    AxcotoMemeDetailViewController *secondView = [[AxcotoMemeDetailViewController alloc]
                                    initWithNibName:@"AxcotoMemeDetailViewController"
                                    bundle:nil];
    [secondView setMemeSource:(NSString *)sender];
    
    [[self navigationController] pushViewController:secondView animated:YES];

}



@end
