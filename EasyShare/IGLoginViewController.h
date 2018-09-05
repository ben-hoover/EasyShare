//
//  IGLoginViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 6/21/14.
//  Copyright (c) 2014 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@class InstagramManager;
@interface IGLoginViewController : UIViewController <SKStoreProductViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *login;
@property (strong,nonatomic) InstagramManager *igManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
@end
