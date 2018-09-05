//
//  LoginWebView.m
//  EasyShare
//
//  Created by Benjamin Hoover on 8/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "LoginWebView.h"

@interface LoginWebView ()

@end

@implementation LoginWebView

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
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.webView.delegate = self;
    self.backButton.enabled = FALSE;
    self.forwardButton.enabled = FALSE;
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadWithURL:(NSString *)url ofType:(type)theNetwork andTitle:(NSString *)title {
    self.originalURL = [NSURL URLWithString:url];
    self.theNetwork = theNetwork;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.originalURL]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {  
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
 
    
}
- (IBAction)cancel:(id)sender {
    [self.delegate loginDidFail];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}
- (IBAction)backToLogin:(id)sender {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.originalURL]];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel)];
    self.topNovBar.topItem.rightBarButtonItem = cancel;
    self.topNovBar.topItem.title = @"Loading...";
    if (self.webView.canGoBack == TRUE) {
        self.backButton.enabled = TRUE;
    } else {
        self.backButton.enabled = FALSE;
    }
    if (self.webView.canGoForward == TRUE) {
        self.forwardButton.enabled = TRUE;
    } else {
        self.forwardButton.enabled = FALSE;
    }
}
- (void)cancel {
    [self.webView stopLoading];
}
- (void)reload {
    [self.webView reload];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.topNovBar.topItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    self.topNovBar.topItem.rightBarButtonItem = refresh;
}
- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.theNetwork == Instagram) {
        NSString *URL = request.URL.absoluteString; NSLog(@"%@",URL);
        NSRange theRange = [URL rangeOfString:@"https://127.0.0.1/#access_token="];
        if (theRange.location != NSNotFound) {
            [[NSUserDefaults standardUserDefaults]setObject:[URL substringFromIndex:theRange.location+theRange.length] forKey:@"InstagramAccessToken"];
            [self dismissViewControllerAnimated:YES completion:nil];
            if ([self.delegate respondsToSelector:@selector(loginDidSucceed)]) {
                [self.delegate loginDidSucceed];
            }
            self.webView.delegate = nil;
            return FALSE;
        } else {
            NSLog(@"%@",request.URL);
            return TRUE;
        }
      
    } else {
        return TRUE;
    }
}
@end
