//
//  IGLoginViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 6/21/14.
//  Copyright (c) 2014 Benjamin Hoover. All rights reserved.
//

#import "IGLoginViewController.h"
#import "InstagramManager.h"
#import <StoreKit/StoreKit.h>
@interface IGLoginViewController ()

@end

@implementation IGLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (InstagramManager *)igManager {
    if (!_igManager) {
        _igManager = [[InstagramManager alloc]init];
    }
    return _igManager;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Setup";
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    
    
    
    if ([[ UIScreen mainScreen ] bounds ].size.height == 568) {
        self.topSpace.constant = 55;
    } else {
        self.topSpace.constant = 13;
    }
    
    // Do any additional setup after loading the view.
}
- (IBAction)getIgApp:(id)sender {
    SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
    storeController.delegate = self;
    
    NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : @389801252 };
    
    [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [self presentViewController:storeController animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to load Instagram app on the app store" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (IBAction)iglogin:(id)sender {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"InstagramAccessToken"] != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"InstagramAccessToken"];
        [self.login setTitle:@"Logout" forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
        [self performSelector:@selector(dismiss) withObject:self afterDelay:1.0];
    } else {

        self.igManager.authenticationCompletion = ^(BOOL success) {

            
        };
        [self.igManager authenticate];
    }
    
}
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"InstagramAccessToken"] != nil) {
        [self.login setTitle:@"Logout" forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
        [self performSelector:@selector(dismiss) withObject:self afterDelay:1.0];
    } else {
        [self.login setTitle:@"Login" forState:UIControlStateNormal];
    }
}
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
