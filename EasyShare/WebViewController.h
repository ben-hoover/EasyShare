//
//  WebViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 7/23/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openInSafari;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *theURL;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fwd;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
- (void)updateBackForwardButtons;
@end
