//
//  FBLoginViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 5/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "FBLoginViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ViewController.h"
#import <Accounts/Accounts.h>
#import "TWLoginViewController.h"
@interface FBLoginViewController ()

@end

@implementation FBLoginViewController
BOOL tappedButton = FALSE;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarStyle:UIStatusBarStyleLightContent];
    self.title = @"Setup";
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(goToTwitter)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = [UIColor lightGrayColor];
        
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess:) name:@"loginsuccess" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkLogin:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    if ([[ UIScreen mainScreen ] bounds ].size.height == 568) {
        self.topSpace.constant = 55;
    } else {
        self.topSpace.constant = 13;
    }
	// Do any additional setup after loading the view.
}
- (void)loginSuccess {
    
    [self.loginbutton setTitle:@"Logout" forState:UIControlStateNormal];
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:[[NSUserDefaults standardUserDefaults]stringForKey:@"twitterAccountID"]];
    if (!account) {
        [self performSelector:@selector(goToTwitter) withObject:nil afterDelay:1.0];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)goToTwitter {
    TWLoginViewController *twLogin = [self.storyboard instantiateViewControllerWithIdentifier:@"TWLoginViewController"];
    [self.navigationController pushViewController:twLogin animated:YES];
}
- (void)checkLogin:(NSNotification *)notification {
    if (FBSession.activeSession.state == FBSessionStateOpen) {
        [self loginSuccess];
    }
 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loginFailed {
    //login failed
}
- (IBAction)login:(id)sender {
    tappedButton = TRUE;
    if (FBSession.activeSession.state == FBSessionStateOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
        [self.loginbutton setTitle:@"Login" forState:UIControlStateNormal];
    
        
    } else {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate openSession];
    }
}

@end
