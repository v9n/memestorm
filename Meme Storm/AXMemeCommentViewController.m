//
//  AXMemeCommentViewController.m
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/31/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import "AXMemeCommentViewController.h"

#import "UIBarButtonItem+StyledButton.h"

@interface AXMemeCommentViewController ()

@end

@implementation AXMemeCommentViewController

@synthesize commentUrl, progressBar;

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
    self.webView.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTarget:self selector:@selector(back)];
    
	[self loadCommentsView];

}

- (void) back
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
}

- (void) loadCommentsView
{
    NSURL *url = [NSURL URLWithString:self.commentUrl];
    
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request];
}

# pragma mark - Public Method
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.progressBar stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.progressBar startAnimating];
}

@end
