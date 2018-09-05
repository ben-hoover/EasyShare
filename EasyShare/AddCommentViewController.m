//
//  AddCommentViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/20/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "AddCommentViewController.h"
#import "FacebookManager.h"
#import "DejalActivityView.h"
@interface AddCommentViewController ()

@end

@implementation AddCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardToShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardToHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.commentText becomeFirstResponder];
    if (self.Network == Facebook && self.Mode == Comment) {
        self.navBar.topItem.title = @"Add Comment";
    } else if (self.Network == Facebook && self.Mode == Share) {
        self.navBar.topItem.title = @"Share Post";
    }
	// Do any additional setup after loading the view.
}
- (void)keyboardToShow:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    NSNumber *animationTime = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationTime.doubleValue];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView setAnimationCurve:curve.doubleValue];
    
    
    NSValue *keyBoardFrame = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyBoardFrame CGRectValue];
    self.textViewButtomSpace.constant = -frame.size.height;
    
    [UIView commitAnimations];
}
- (void)keyboardToHide:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    NSNumber *animationTime = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationTime.doubleValue];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView setAnimationCurve:curve.doubleValue];
    
    self.textViewButtomSpace.constant = 0;
    [UIView commitAnimations];

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addComment:(id)sender {
    if (self.addPost) {
        FacebookManager *manager = [[FacebookManager alloc]init];
        manager.fbDelegate = self;
        [manager addComment:self.commentText.text withID:self.addPost.objectId];
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Adding Comment"];
        self.view.userInteractionEnabled = FALSE;
    }
    
}
- (IBAction)close:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"reload" object:nil];
}
- (void)commentAddDidFinish:(NSError *)error {
    [DejalBezelActivityView removeViewAnimated:TRUE];
    self.view.userInteractionEnabled = TRUE;
    if (error) {
        
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Could Not Add Comment" message:[error.userInfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        
        [errorAlert show];
      
    } else {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reload" object:nil];
    }
}
@end
