//
//  AppDelegate.h
//  EasyShare
//
//  Created by Benjamin Hoover on 5/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginViewController.h"
#import "ViewController.h"
#import "Reachability.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong,nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableDictionary *postCache;
@property (strong, nonatomic) Reachability *connection;
@property (strong, nonatomic) UIView *addStatusBar;
@property BOOL onWifi;
- (void)openSession;
- (void)handleFBError:(NSError *)error;
- (void)showWebViewWithURL:(NSString *)url;
@end
