//
//  TWLoginViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 6/20/14.
//  Copyright (c) 2014 Benjamin Hoover. All rights reserved.
//

#import "TWLoginViewController.h"
#import "TwitterManager.h"
#import <Accounts/Accounts.h>
#import "IGLoginViewController.h"
@interface TWLoginViewController ()

@end

@implementation TWLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (TwitterManager *)manager {
    if (!_manager) {
        _manager = [[TwitterManager alloc]init];
    }
    return _manager;
}
- (void)viewDidAppear:(BOOL)animated {
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Setup";
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:[[NSUserDefaults standardUserDefaults]stringForKey:@"twitterAccountID"]];
    if (account) {
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    if ([[ UIScreen mainScreen ] bounds ].size.height == 568) {
        self.topSpace.constant = 55;
    } else {
        self.topSpace.constant = 13;
    }
    // Do any additional setup after loading the view.
}
- (IBAction)login:(id)sender {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:[[NSUserDefaults standardUserDefaults]stringForKey:@"twitterAccountID"]];
    if (account) {
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"twitterAccountID"];
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        self.loggedInAs.text = @"Logged in as:";
    } else {
        [self.manager authenticateWithCompletion:^(ACAccount* account){
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        self.loggedInAs.text = [NSString stringWithFormat:@"Logged in as: %@",account.username];
            self.navigationItem.rightBarButtonItem.enabled = FALSE;
            [self performSelector:@selector(next) withObject:self afterDelay:0.5];
        }];
        
    }
  
}
- (void)next {
    IGLoginViewController *ig = [self.storyboard instantiateViewControllerWithIdentifier:@"IGLoginViewController"];
    [self.navigationController pushViewController:ig animated:YES];
}
- (IBAction)dismiss:(id)sender {
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
