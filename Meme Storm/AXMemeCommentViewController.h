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

@property NSString * commentUrl;

- (void) loadCommentsView;

@end
