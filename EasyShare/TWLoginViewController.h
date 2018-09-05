//
//  TWLoginViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 6/20/14.
//  Copyright (c) 2014 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterManager.h"
@interface TWLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UILabel *loggedInAs;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
@property (strong, nonatomic)TwitterManager *manager;
@end
