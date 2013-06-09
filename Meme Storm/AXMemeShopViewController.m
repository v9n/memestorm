//
//  AXMemeShopViewController.m
//  Meme Storm
//
//  Created by Hoa Diem Nguyet on 6/2/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "AXMemeShopViewController.h"

@interface AXMemeShopViewController ()

@end

@implementation AXMemeShopViewController

@synthesize memeSourceTable, memeSourceData, selectedMarks, cache;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selectedMarks = [[NSMutableArray alloc] init];
        cache = [AXCache instance];
        [self loadMemeSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [self saveSetting];
}
/**
 Store selected site and other configuration if has some.
 */
- (void) saveSetting
{
    [cache saveForKey:@"selected_sources" withValue:selectedMarks];
}

- (void) loadMemeSource {
    AXCache * cache = [AXCache instance];
    memeSourceData= (NSArray *) [cache getByKey:@"sources"];
//    
//    dispatch_async(dispatch_get_global_queue(0,0), ^ {
//        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString * f = [path objectAtIndex:0];
//        f = [f stringByAppendingString:@"/source.json"];
//        
//        NSFileManager * fileMan = [NSFileManager defaultManager];
//        NSData *s = Nil;
//        
//        if ([fileMan fileExistsAtPath:f]) {
//            NSLog(@"Read memeSource form cache: %@", f);
//            NSError * e;
//            NSDictionary * attr = [fileMan attributesOfItemAtPath:f error:&e];
//            if (attr !=nil) {
//                NSDate * d = [attr objectForKey:NSFileCreationDate];
//                NSLog(@"The cache is created at %@\n. This is was %f seconds ago", d, [d timeIntervalSinceNow]);
//                if ([d timeIntervalSinceNow] + 24 * 3600 > 0) {
//                    NSLog(@"There is no need to fetch the data");
//                    s = [[NSData alloc] initWithContentsOfFile:f];
//                    memeSourceData = (NSArray *)[s objectFromJSONData];
//                    
//                } else {
//                    NSLog(@"There is need to fetch the data");
//                }
//            }
//            
//        }
//    });

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
    NSString *text = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"t"];
    cell.isSelected = [selectedMarks containsObject:text] ? YES : NO;
    
    cell.textLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[memeSourceData objectAtIndex:indexPath.row] objectForKey:@"t"];
    
    if ([selectedMarks containsObject:text])// Is selected?
        [selectedMarks removeObject:text];
    else
        [selectedMarks addObject:text];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
