//
//  WebViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/23/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "WebViewController.h"
#import "OpenInChromeController.h"
#import "AppDelegate.h"
#define Delegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])
@interface WebViewController ()

@end
@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBar.alpha = 1.0;
}
- (void)viewWillDisappear:(BOOL)animated {
    Delegate.addStatusBar.hidden = FALSE;
}
- (void)viewDidLoad
{
    Delegate.addStatusBar.hidden = TRUE;
    [self.navigationController setNavigationBarHidden:FALSE animated:NO];
    
    self.navigationController.navigationBar.alpha = 1.0;

    [super viewDidLoad];
    
    self.title = @"Loading...";
    self.webView.delegate = self;
    [self updateBackForwardButtons];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.theURL]];
    //movin fwd yeah!! -| :D
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openInBrowser:(id)sender {
    NSString *chrome = nil;
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"googlechrome://"]]) {
        chrome = @"Open In Chrome";
    }
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"Open in Browser" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open In Safari",chrome,@"Share Page", nil];
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Open In Safari"]) {
        [[UIApplication sharedApplication]openURL:self.webView.request.URL];
    } else if ([title isEqualToString:@"Open In Chrome"] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome-x-callback://"]]) {
        NSString *appName =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSURL *inputURL = self.webView.request.URL;
        NSURL *callbackURL = [NSURL URLWithString:@"fb328237410604283://"];
        
        NSString *scheme = inputURL.scheme;
        
        // Proceed only if scheme is http or https.
        if ([scheme isEqualToString:@"http"] ||
            [scheme isEqualToString:@"https"]) {
            NSString *chromeURLString = [NSString stringWithFormat:
                                         @"googlechrome-x-callback://x-callback-url/open/?x-source=%@&x-success=%@&url=%@",
                                         appName,
                                         [callbackURL absoluteString],
                                         [inputURL absoluteString]];
            NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
            
            // Open the URL with Google Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
        }

    }
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.title = @"Loading...";
    UIActivityIndicatorView *loadingSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingSpinner.frame = CGRectMake(0, 0, 20, 20);
    UIBarButtonItem *loading = [[UIBarButtonItem alloc]initWithCustomView:loadingSpinner];
    [loadingSpinner startAnimating];
    self.navigationItem.rightBarButtonItem = loading;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@",error);
    NSLog(@"%@",error.localizedDescription);
    NSLog(@"%@",webView.request.URL);
    if ([error.localizedDescription isEqualToString:@"Frame load interrupted"]) {
        [[UIApplication sharedApplication]openURL:self.theURL];
    }

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    //keep moving FORWARD FU YEAH!!!!!!!!!! :D:D:D:D:D:D:D:D
    [self updateBackForwardButtons];
}
- (void)updateBackForwardButtons {
    if (self.webView.canGoBack) {
        self.back.enabled = TRUE;
    } else {
        self.back.enabled = FALSE;
    }
    if (self.webView.canGoForward) {
        self.fwd.enabled = TRUE;
    } else {
        self.fwd.enabled = FALSE;
    }
}
- (void)reload {
    [self.webView reload];
}

@end
