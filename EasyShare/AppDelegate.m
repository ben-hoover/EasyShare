//
//  AppDelegate.m
//  EasyShare
//
//  Created by Benjamin Hoover on 5/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FBLoginViewController.h"
#import "ViewController.h"
#import "Reachability.h"
#import "UINavigationController+StatusBarStyle.h"

@implementation AppDelegate

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (error) {
        [self handleFBError:error];
    }
    switch (state) {
        case FBSessionStateOpen: 
            [center postNotificationName:@"loginsuccess" object:nil userInfo:nil];
    
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
         //   [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
           
            break;
        default:
            break;
    }
    
    
}
- (void)handleFBError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    if (error.fberrorShouldNotifyUser) {
        
        // If the SDK has a message for the user, surface it.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
  
    } else {
        // For simplicity, this sample treats other errors blindly.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
- (void)openSession
{

    [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"basic_info",@"read_stream", @"user_photos",@"user_videos",@"user_status", nil]
                                       allowLoginUI:YES
                                  completionHandler:
     //@"friends_videos", @"friends_photos"
     //@"friends_status"
 ^(FBSession *session,
       FBSessionState state, NSError *error) {
         
     [self sessionStateChanged:session state:state error:error];

     NSLog(@"%@",error.localizedDescription);
     }];
    
    
 
    

   }
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.postCache = [[NSMutableDictionary alloc]init];
    self.connection = [Reachability reachabilityForInternetConnection];
    if ([self.connection currentReachabilityStatus] == ReachableViaWWAN) {
        self.onWifi = FALSE;
    } else {
        self.onWifi = TRUE;
    }
    [self.connection startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
    
        [self openSession];
    } else {
        // No, display the login page.
        
       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setBool:TRUE forKey:@"showlogin"];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.addStatusBar = [[UIView alloc] init];
        self.addStatusBar.frame = CGRectMake(0, 0, 320, 20);
        //change this to match your navigation bar or view color or tool bar
        //You can also use addStatusBar.backgroundColor = [UIColor BlueColor]; or any other color
        self.addStatusBar.backgroundColor = self.navController.navigationBar.backgroundColor;
        [self.window.rootViewController.view addSubview:self.addStatusBar];
    }
    
    return YES;
}
- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability *reach = [notification object];
    if ([reach currentReachabilityStatus] == ReachableViaWWAN) {
        self.onWifi = FALSE;
    } else {
        self.onWifi = TRUE;
    }
}

                    
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
    /*
- (void)showLoginView
{
    UIViewController *topViewController = [self.navController topViewController];
    UIViewController *modalViewController = [topViewController modalViewController];
    
    // If the login screen is not already displayed, display it. If the login screen is
    // displayed, then getting back here means the login in progress did not successfully
    // complete. In that case, notify the login view so it can update its UI appropriately.
    if (![modalViewController isKindOfClass:[FBLoginViewController class]]) {
        FBLoginViewController* loginViewController = [[FBLoginViewController alloc]
                                                      initWithNibName:@"FBLoginViewController"
                                                      bundle:nil];
        [topViewController presentModalViewController:loginViewController animated:NO];
    } else {
        FBLoginViewController* loginViewController =
        (FBLoginViewController*)modalViewController;
        [loginViewController loginFailed];
    }
}
     */
- (void) showWebViewWithURL:(NSString *)url {
    
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
        return [FBSession.activeSession handleOpenURL:url];
    
}
@end
