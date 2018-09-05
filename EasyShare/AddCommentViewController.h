//
//  AddCommentViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 7/20/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "FacebookManager.h"
#import "AppDelegate.h"
@interface AddCommentViewController : UIViewController <FacebookManagerDelegate>

@property (nonatomic)type Network;
@property (nonatomic)postMode Mode;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UITextView *commentText;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewButtomSpace;
@property (strong, nonatomic) Post *addPost;
@end
