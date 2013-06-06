//
//  AXMemeCommentViewController.h
//  Meme Storm
//
//  Created by Vinh Nguyen on 12/31/12.
//  Copyright (c) 2012 Vinh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXMemeCommentViewController : UIViewController <UIWebViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressBar;

@property NSString * commentUrl;

- (void) loadCommentsView;

- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidStartLoad:(UIWebView *)webView;

@end
