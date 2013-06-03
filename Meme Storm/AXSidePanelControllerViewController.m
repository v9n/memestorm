//
//  AXSidePanelControllerViewController.m
//  Meme Storm
//
//  Created by Hoa Diem Nguyet on 6/3/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "AXSidePanelControllerViewController.h"

@interface AXSidePanelController ()

@end

@implementation AXSidePanelController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

+ (UIImage *)defaultImage {
	static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
		
		[[UIColor blackColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 20, 1)] fill];
		
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];
		
		defaultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
	});
    return defaultImage;
}


#pragma mark - Public Methods

- (UIBarButtonItem *)leftButtonForCenterPanel {
    UIBarButtonItem * item;
    item = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"site-toggle"] target:self selector:@selector(toggleLeftPanel:)];
    
//    item = [[UIBarButtonItem alloc] initWithImage:[[self class] defaultImage] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];;
    
    [item setStyle:UIBarButtonItemStylePlain];
    return item;

}

@end
