//
//  FBLoginViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 5/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBLoginViewController : UIViewController
- (IBAction)login:(id)sender;
- (void) loginFailed;
@property (strong, nonatomic) IBOutlet UIButton *loginbutton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
- (void) loginSuccess: (NSNotification *)notification;
@end
