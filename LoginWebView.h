//
//  LoginWebView.h
//  EasyShare
//
//  Created by Benjamin Hoover on 8/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enums.h"
@protocol LoginWebViewDelegate <NSObject>
@optional
- (void)loginDidSucceed;
- (void)loginDidFail;
@end
@interface LoginWebView : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UINavigationBar *topNovBar;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *goBackToLoginPage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) id <LoginWebViewDelegate> delegate;
@property (strong,nonatomic) NSURL *originalURL;
@property (nonatomic) type theNetwork;
- (void)loadWithURL:(NSString *)url ofType:(type)theNetwork andTitle:(NSString *)title;

@end
