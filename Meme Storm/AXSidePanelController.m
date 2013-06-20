//
//  AXSidePanelControllerViewController.m
//  Meme Storm
//
//  Created by Hoa Diem Nguyet on 6/3/13.
//  Copyright (c) 2013 Vinh Nguyen. All rights reserved.
//

#import "AXSidePanelController.h"
#import "AxcotoViewController.h"

@interface AXSidePanelController ()

@end

@implementation AXSidePanelController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        [self setAllowLeftSwipe:NO];
//        [self setAllowRightSwipe:NO];
//    }
//    return self;
//}

- (id)init {
    if (self = [super init]) {
        [self setAllowLeftSwipe:NO];
        [self setAllowRightSwipe:NO];
        [self setCanUnloadRightPanel:YES];
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
    item = [UIBarButtonItem transparentButtonWithImage:[UIImage imageNamed:@"site-toggle"] andBound:CGRectMake(10, 5, 30, 30) target:self selector:@selector(toggleLeftPanel:)];
    
//    item = [[UIBarButtonItem alloc] initWithImage:[[self class] defaultImage] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];;
    
    [item setStyle:UIBarButtonItemStylePlain];
    return item;

}


- (void)toggleLeftPanel:(__unused id)sender {

    if (self.state == JASidePanelLeftVisible) {
    } else if (self.state == JASidePanelCenterVisible) {
        if ([self.leftPanel conformsToProtocol:@protocol(AXSidePanelDelegate)] && [self.leftPanel respondsToSelector:@selector(didShowLeftPanel)]) {
            [self.leftPanel didShowLeftPanel];
        }
    }
    [super toggleLeftPanel:sender];
}

# pragma mark - Override
- (void)showCenterPanelAnimated:(BOOL)animated {
    BOOL fromLeft = NO;
    if (self.state == JASidePanelLeftVisible) {
        fromLeft = YES;
        if ([self.leftPanel conformsToProtocol:@protocol(AXSidePanelDelegate)] && [self.leftPanel respondsToSelector:@selector(didHideLeftPanel)]) {
            [self.leftPanel didHideLeftPanel];
        }
    } else if (self.state == JASidePanelCenterVisible) {
        
    }
    [super showCenterPanelAnimated:animated];
    AxcotoViewController * centerView = (AxcotoViewController *)self.centerPanel.visibleViewController;
    if (fromLeft==YES && [centerView conformsToProtocol:@protocol(AXSidePanelDelegate)] && [centerView respondsToSelector:@selector(didShowCenterPanel)]) {
        [centerView didShowCenterPanel];
    }
    
}

/**
 * Completely disable swipe npw
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

@end
