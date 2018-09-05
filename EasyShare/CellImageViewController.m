//
//  CellImageViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 6/26/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "CellImageViewController.h"
#import "ZoomImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "Post.h"
#import "GlobalManager.h"
#import "EasyShareCell.h"
#import "InstagramManager.h"
@interface CellImageViewController ()

@end

@implementation CellImageViewController

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
   // self.scroller.contentSize = [UIScreen mainScreen].bounds.size;
    
    self.cellimage = [[UIImageView alloc]init];
    self.cellimage.frame = self.view.bounds;
    self.cellimage.userInteractionEnabled = TRUE;
    self.scroller.backgroundColor = [UIColor blackColor];
    self.cellimage.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgimage removeFromSuperview];
        self.bgimage.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
    [self.scroller addSubview:self.cellimage];
    UITapGestureRecognizer *c = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flashControls)];
    [self.scroller addGestureRecognizer:c];
    [self flashControls];
    
    
    self.view.backgroundColor = [UIColor clearColor];
    self.scroller.delegate = self;
    self.scroller.minimumZoomScale = 1.0;
    self.scroller.maximumZoomScale = 3.0;
    
    
    
    
    
    
  //  UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flashControls)];
    //[self.scroller addGestureRecognizer:tapper];
    UIPanGestureRecognizer *panGesturer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
    self.cellimage.userInteractionEnabled = TRUE;
     [self.cellimage addGestureRecognizer:panGesturer];
    [self.closeButton setTitle:@"Done" forState:UIControlStateNormal];
    NSLog(@"%@",self.closeButton);
    CALayer *newlayer = self.closeButton.layer;
    newlayer.backgroundColor = [[UIColor clearColor]CGColor];
    newlayer.borderWidth = 1.0f;
    newlayer.borderColor = [[UIColor whiteColor]CGColor];
    newlayer.cornerRadius = 4.0f;
    
    CALayer *otherlayer = self.topControlBar.layer;
    otherlayer.shadowOffset = CGSizeMake(10,10);
    otherlayer.shadowRadius = 5;
    otherlayer.shadowColor = [[UIColor blackColor]CGColor];
    otherlayer.shadowOpacity =1.0;
    otherlayer.shadowPath = [[UIBezierPath bezierPathWithRect:otherlayer.bounds] CGPath];
  
	// Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    [delegate.window insertSubview:self.bgimage  belowSubview:self.view];

    NSLog(@"%@",self.bgimage.image);
   // [self.scroller bringSubviewToFront:self.closeButton];
    NSLog(@"caption size is %f",self.caption.frame.size.height);
    NSLog(@"caption size is %f",self.captionHeightConstraint.constant);
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.cellimage;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    NSLog(@"zoomscale is %f",self.scroller.zoomScale);
    if (scrollView.zoomScale == 1.0) {
        [self showControls];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismiss:(id)sender {
    [self.delegate dismissWithFrame:self.cellimage.frame imageColor:self.scroller.backgroundColor];
}
- (IBAction)showOptions:(id)sender {
    NSMutableArray *arrayOfOptions = [GlobalManager listOfOptionsForPost:self.tappedPost showCount:YES];
    [arrayOfOptions addObject:@"Save"];
    [arrayOfOptions addObject:@"Cancel"];
    
    UIActionSheet *opt = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    NSString *theButtonTitle;
    for (theButtonTitle in arrayOfOptions) {
        [opt addButtonWithTitle:theButtonTitle];
    }
    opt.cancelButtonIndex = arrayOfOptions.count - 1;
    [opt showInView:self.view];
}
- (void)moveImage:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan && self.scroller.zoomScale <= 1.1) {
        self.topControlBar.hidden = TRUE;
        self.bottomControlBar.hidden = TRUE;
        oldPosition = self.cellimage.center;
    } else if (recognizer.state == UIGestureRecognizerStateEnded && self.scroller.zoomScale <= 1.1) {
        if (distancefromcenter <= 100) {
            [UIView animateWithDuration:0.2 animations:^{
               self.cellimage.center = oldPosition;
                self.scroller.backgroundColor = [UIColor blackColor];
            }];
            
        } else {
        [self.delegate dismissWithFrame:self.cellimage.frame imageColor:self.scroller.backgroundColor];

        
        //check for tue 7/9 time--is copy needed?
     
        }
    } else if (self.scroller.zoomScale <= 1.1) {
        CGPoint locationinsuperview = [recognizer translationInView:self.scroller];

        self.cellimage.center = CGPointMake(self.cellimage.frame.size.width/2, oldPosition.y +locationinsuperview.y);
        NSLog(@"%f, %f",locationinsuperview.x, locationinsuperview.y);
       // CGRect screenRect = [[UIScreen mainScreen] bounds];
        distancefromcenter = fabs(([UIScreen mainScreen].bounds.size.height/2)-self.cellimage.center.y);
        NSLog(@"currently at %f, distance from center is %f", self.cellimage.center.y, distancefromcenter);
        double alpha = 1 - (distancefromcenter/([UIScreen mainScreen].bounds.size.height/2));
        self.scroller.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    }

}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale > 1.0)
        [self hideControls];
    //why can't put final methods..?
}
- (void)flashControls {
    if (self.topControlBar.hidden == FALSE && self.topControlBar.hidden == FALSE) {
         self.bottomControlBar.hidden = TRUE;
        [self hideControls];
        
    } else {
        [self showControls];
        
    }
}
- (void)hideControls {
    [UIView animateWithDuration:0.25 animations:^{
        self.topControlBar.alpha = 0;
        self.bottomControlBar.alpha = 0;
    } completion:^(BOOL finished) {
        self.topControlBar.hidden = TRUE;
        self.bottomControlBar.hidden = TRUE;
    }];    
}
- (void)showControls {
    self.topControlBar.hidden = FALSE;
    self.bottomControlBar.hidden = FALSE;
    [UIView animateWithDuration:0.25 animations:^{
        self.topControlBar.alpha = 1;
        self.bottomControlBar.alpha = 1;
        [self.view bringSubviewToFront:self.topControlBar];
        [self.view bringSubviewToFront:self.bottomControlBar];
    }];
}
- (void)setupWithViewController:(UIViewController *)controller andPost:(Post *)post inRow:(NSInteger)row imageView:(UIImageView *)zoomedImageView inTable:(UITableView *)tableView{
    NSIndexPath *cellposition = [NSIndexPath indexPathForRow:row inSection:0];
    EasyShareCell *cellselected = (EasyShareCell *)[tableView cellForRowAtIndexPath:cellposition];
    self.cell = cellselected;
    Post *cellpost;
    if (post.isAShare == TRUE) {
        AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
        cellpost = [delegate.postCache objectForKey:post.photo_objectid];
    } else {
        cellpost = post;
    }
    
    if (cellpost.type == Photo) {
       
        self.delegate = (ViewController *)controller;
        tableView.scrollEnabled = FALSE;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [[controller navigationController]setNavigationBarHidden:YES animated:YES];
        
        NSLog(@"tap");
        
        UIView *backgroundview = [[UIView alloc]initWithFrame:tableView.bounds];
        backgroundview.backgroundColor = [UIColor clearColor];
        [tableView addSubview:backgroundview];
        [backgroundview addSubview:zoomedImageView];
        
        zoomedImageView.image = cellselected.viewimage.image;
        
        zoomedImageView.frame = [cellselected.viewimage convertRect:cellselected.viewimage.bounds toView:backgroundview];
        zoomedImageView.tag = cellposition.row;
        zoomedImageView.hidden = TRUE;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
            UIGraphicsBeginImageContextWithOptions(tableView.frame.size, NO, [UIScreen mainScreen].scale);
        else
            UIGraphicsBeginImageContext(tableView.frame.size);
        [tableView.superview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *parentViewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        zoomedImageView.hidden = FALSE;
        
        
        [UIView animateWithDuration:1.0 animations:^{
            
            backgroundview.backgroundColor = [UIColor blackColor];
            zoomedImageView.frame = backgroundview.bounds;
            
        } completion:^(BOOL finished) {
            
            [controller presentViewController:self animated:NO completion:^{
                
                self.cellimage.image = zoomedImageView.image;
                self.bgimagepic = parentViewImage;
                self.bgimage.image = self.bgimagepic;
                
                self.caption.text = cellpost.caption;
                self.userLabel.text = cellpost.author;
                
                if (cellpost.likeCount && cellpost.commentCount && cellpost.time) {
                    self.date.text = [GlobalManager stringDistanceToDate:cellpost.time];
                    self.likesCount.text = [NSString stringWithFormat:@"%@ Likes", cellpost.likeCount];
                    self.commentsCount.text = [NSString stringWithFormat:@"%@ Comments",cellpost.commentCount];
                    self.tappedPost = cellpost;
                    
                } else {
                    if (cellpost.network == Facebook) {
                        FacebookManager *manager = [[FacebookManager alloc]init];
                        [manager getMoreImageInfoWithID:cellpost.photo_objectid completion:^(id results) {
                            if ([results isKindOfClass:[NSError class]]) {
                                //handle error
                                NSLog(@"error %@",results);
                            } else {
                                NSLog(@"%@",results);
                                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                                
                                NSArray *datas = [results objectForKey:@"data"];
                                if (datas.count <= 1) {
                                    cellpost.likeCount = [NSString stringWithFormat:@"%@",[[[datas objectAtIndex:0]objectForKey:@"like_info"]objectForKey:@"like_count"]];
                                    
                                    cellpost.commentCount = [NSString stringWithFormat:@"%@",[[[datas objectAtIndex:0]objectForKey:@"comment_info"]objectForKey:@"comment_count"]];
                                    self.likesCount.text = [NSString stringWithFormat:@"%@ Likes",[[[datas objectAtIndex:0]objectForKey:@"like_info"]objectForKey:@"like_count"]];
                                    self.commentsCount.text = [NSString stringWithFormat:@"%@ Comments",[[[datas objectAtIndex:0]objectForKey:@"comment_info"]objectForKey:@"comment_count"]];
                                    NSTimeInterval seconds = [[[datas objectAtIndex:0]objectForKey:@"created"]doubleValue];
                                    NSDate *postedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                                    cellpost.time = postedDate;
                                    cellpost.canComment = [[[[datas objectAtIndex:0]objectForKey:@"comment_info"]objectForKey:@"can_comment"]boolValue];
                                    cellpost.canLike = [[[[datas objectAtIndex:0]objectForKey:@"like_info"]objectForKey:@"can_like"]boolValue];
                                    self.date.text = [GlobalManager stringDistanceToDate:postedDate];
                                    self.tappedPost = cellpost;
                                    
                                }
                                
                            }
                        }];
                    }
                    
                    
                }
                
                
                
                
                NSLog(@"%@",self.bgimage.image);
                backgroundview.hidden = TRUE;
                if (cellpost.story == FALSE ) {
                    CGSize size = [self.caption.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-16, INT_MAX)];
                    size.height += 16;
                    self.captionHeightConstraint.constant = MIN(size.height, self.captionHeightConstraint.constant);
                } else {
                    self.captionHeightConstraint.constant = 0;
                    self.captionBottomConstraint.constant = 0;
                    self.caption.hidden = TRUE;
                    self.borderView.hidden = TRUE;
                }
                
            }];
            
        }];
        
        // cellselected.viewimage.hidden = TRUE;
        tableView.scrollEnabled = FALSE;
        
    } else if (cellpost.type == Video){
        [GlobalManager playVideoWithViewController:self post:cellpost];
    }

}
#pragma mark actionSheet deleGate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex]rangeOfString:@"ike"].location != NSNotFound) {
        [self like];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex]rangeOfString:@"Comment"].location!= NSNotFound) {
        [self closeAndComment];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex]rangeOfString:@"Share"].location != NSNotFound) {
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:@"Save"]) {
        UIImageWriteToSavedPhotosAlbum(self.cellimage.image, nil, nil, nil);
    }
    
    
}

- (void)closeAndComment{
    [self.delegate goToCommentsWithFrame:self.cellimage.frame imageColor:self.cellimage.backgroundColor andPost:self.tappedPost];
  

}
- (void)like {
    void(^likeCompletion)(BOOL) = ^(BOOL success) {
        self.igManager = nil;
        if (success == TRUE) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Succesfully Liked Post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            self.tappedPost.userLikes = TRUE;
            NSInteger oldNumberOfLikes = [self.tappedPost.likeCount integerValue];
            oldNumberOfLikes++;
            self.tappedPost.likeCount = [NSString stringWithFormat:@"%i",oldNumberOfLikes];
            self.likesCount.text = [NSString stringWithFormat:@"%i Likes",oldNumberOfLikes];
            self.cell.likeButton.actionCount.text = self.tappedPost.likeCount;
            [self.cell.likeButton.actionButton setTitle:@"Unlike" forState:UIControlStateNormal];
            [self.cell.likeButton.spinner stopAnimating];
            self.cell.likeButton.actionButton.hidden = FALSE;
            
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Could not like post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [self.cell.likeButton.spinner stopAnimating];
            self.cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        }

    };
    void(^unlikeCompletion)(BOOL) = ^(BOOL success){
        self.igManager = nil;
        if (success == TRUE) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Succesfully unliked post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            self.tappedPost.userLikes = FALSE;
            NSInteger oldNumberOfLikes = [self.tappedPost.likeCount integerValue];
            oldNumberOfLikes--;
            self.tappedPost.likeCount = [NSString stringWithFormat:@"%i",oldNumberOfLikes];
            self.likesCount.text = [NSString stringWithFormat:@"%i Likes",oldNumberOfLikes];
            self.cell.likeButton.actionCount.text = self.tappedPost.likeCount;
            [self.cell.likeButton.actionButton setTitle:@"Like" forState:UIControlStateNormal];
            [self.cell.likeButton.spinner stopAnimating];
            self.cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Failed to unlike post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [self.cell.likeButton.spinner stopAnimating];
            self.cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        }

    };
    [self.cell.likeButton.spinner startAnimating];
    self.cell.likeButton.actionButton.hidden = TRUE;
    if (self.tappedPost.network == Facebook) {
        
        FacebookManager *manager = [[FacebookManager alloc]init];
        if (self.tappedPost.userLikes == FALSE) {
            [manager likePost:self.tappedPost.objectId completion:likeCompletion];
            
        } else if (self.tappedPost.userLikes == TRUE){
            [manager unLikePost:self.tappedPost.objectId completion:unlikeCompletion];
        }
    } else if (self.tappedPost.network == Instagram) {
        self.igManager = [[InstagramManager alloc]init];
        if (self.tappedPost.userLikes == FALSE) {
            [self.igManager likePost:self.tappedPost.objectId WithCompletion:likeCompletion];
        } else if (self.tappedPost.userLikes == TRUE) {
            [self.igManager unLikePost:self.tappedPost.objectId WithCompletion:likeCompletion];
        }
        
    }
}





#pragma mark rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.cellimage.frame = CGRectMake(self.cellimage.frame.origin.x, self.cellimage.frame.origin.y, 320, [UIScreen mainScreen].bounds.size.height);
    } else {
        self.cellimage.frame = CGRectMake(self.cellimage.frame.origin.x, self.cellimage.frame.origin.y,[UIScreen mainScreen].bounds.size.height,320);
    }
   // [self presentViewController:self animated:YES completion:nil];
}
- (BOOL)shouldAutorotate {
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
