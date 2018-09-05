//
//  CommentsTableViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/19/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "CommentCell.h"
#import "ProfilePictureDownloader.h"
#import "AddCommentViewController.h"
#import "DejalActivityView.h"
#import "InstagramManager.h"
#import "FacebookManager.h"
//#import "GooglePlusManager.h"
#import <QuartzCore/QuartzCore.h>
#import "CellImageViewController.h"
#import "GlobalManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#define Delegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])
@interface CommentsTableViewController ()

@end

@implementation CommentsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}






- (void)viewDidLoad
{
    Delegate.addStatusBar.hidden = TRUE;
    [self.navigationController setNavigationBarHidden:FALSE animated:NO];

        self.navigationController.navigationBar.alpha = 1.0;
    

    [super viewDidLoad];
    //pars
    //   if () {
    
    //  }
   
    //
    self.tableView.tableFooterView = self.tableFooter;
    NSLog(@"%@",self.tableView.tableFooterView);
    NSLog(@"%f",self.tableView.contentSize.height);
    self.title = @"Comments";
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showOptions)];
    self.navigationItem.rightBarButtonItem = addItem;
    switch (self.cellPost.network) {
        case Facebook:
            [self FBLoad];
            break;
        case Instagram:
            [self IGLoad];
            break;
        default:
            break;
    }
    
        // [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:@"CommentCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.profilecache = [[NSMutableDictionary alloc]init];
    NSLog(@"%f",self.tableView.contentSize.height);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissed) name:@"reload" object:nil];
    
    
}
- (void)FBLoad {
    FacebookManager *globalManageHelper = [[FacebookManager alloc]init];
    
    
    [globalManageHelper getCommentsWithCursor:nil objectID:self.cellPost.objectId completion:^(NSError *resultingError, id comments){
        if (resultingError) {
            NSLog(@"%@",resultingError);
            
        } else {
            NSLog(@"%@",comments);
            self.comments = [comments objectForKey:@"data"];
            self.nextPageID = [[[comments objectForKey:@"paging"]objectForKey:@"cursors"]objectForKey:@"after"];
            [self.tableView reloadData];
            
            if (!self.nextPageID) {
                
            }
            
            
        }
    }];

}
- (void)IGLoad {
    

    if (self.cellPost.comments.count >= [self.cellPost.commentCount intValue]) {
        self.comments = [NSArray arrayWithArray:self.cellPost.comments];
        self.tableView.tableFooterView = nil;
    } else {
        [self igLoadMore];
    }
    
    //self.tableView.tableFooterView = [self tableFooter];
        
}
- (NSMutableArray *)arrayOfOptions {
    if (!_arrayOfOptions) {
        _arrayOfOptions = [[NSMutableArray alloc]init];
    }
    return _arrayOfOptions;
}
- (void)loadWithPostID:(NSString *)postID {
    
}
- (void)viewDidAppear:(BOOL)animated {
    
        self.navigationController.navigationBar.alpha = 1.0;

}
- (void)viewWillDisappear:(BOOL)animated {
    Delegate.addStatusBar.hidden =  FALSE;
}
- (void)comment:(NSInteger)index {
    [self addComment];
}
- (UIView *)tableFooter {
    if (!_tableFooter) {
        _tableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loading startAnimating];
        loading.translatesAutoresizingMaskIntoConstraints = FALSE;
        [_tableFooter addSubview:loading];
        
        [_tableFooter addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_tableFooter attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [_tableFooter addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_tableFooter attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    
    
    return _tableFooter;
}
- (void)showOptions {
    
        [self.arrayOfOptions removeAllObjects];
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        actionSheet.tag = -1;
        actionSheet.delegate = self;
        self.arrayOfOptions = [GlobalManager listOfOptionsForPost:self.cellPost showCount:YES];
        [self.arrayOfOptions addObject:@"Cancel"];
        NSString *theOption;
        for (theOption in self.arrayOfOptions) {
            [actionSheet addButtonWithTitle:theOption];
        }
        
        
        [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
        [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == -1) {
        
        
        if ([[self.arrayOfOptions objectAtIndex:buttonIndex]rangeOfString:@"ike"].location != NSNotFound) {
            [self like:0];
        } else if ([[self.arrayOfOptions objectAtIndex:buttonIndex]rangeOfString:@"Comment"].location != NSNotFound) {
            [self addComment];
        }
    } else {
        NSDictionary *comment = [self.comments objectAtIndex:actionSheet.tag];
        if (buttonIndex == 0 && [[comment objectForKey:@"user_likes"]boolValue] == FALSE) {
            FacebookManager *manager = [[FacebookManager alloc]init];
            [manager likePost:[comment objectForKey:@"id"] completion:^(BOOL success){
                if (success == TRUE) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Succesfully liked comment!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    CommentCell *cell = (CommentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:actionSheet.tag inSection:1]];
                    NSInteger oldNumberOfLikes = [[comment objectForKey:@"like_count"]integerValue];
                    oldNumberOfLikes++;
                    cell.likeCount.text = [NSString stringWithFormat:@"%i likes",oldNumberOfLikes];
                    [comment setValue:[NSString stringWithFormat:@"%i",oldNumberOfLikes] forKey:@"like_count"];
                    [comment setValue:[NSNumber numberWithBool:TRUE] forKey:@"user_likes"];
                    cell.likeCount.textColor = [UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:1.0];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Failed to like comment!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }];
        } else if (buttonIndex == 0 && [[comment objectForKey:@"user_likes"]boolValue] == TRUE) {
            FacebookManager *manager = [[FacebookManager alloc]init];
            [manager unLikePost:[comment objectForKey:@"id"] completion:^(BOOL success) {
                if (success == TRUE) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Unliked comment succesfully!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                    [alert show];
                    CommentCell *cell = (CommentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:actionSheet.tag inSection:1]];
                    NSInteger oldNumberOfLikes = [[comment objectForKey:@"like_count"]integerValue];
                    oldNumberOfLikes--;
                    cell.likeCount.text = [NSString stringWithFormat:@"%i likes",oldNumberOfLikes];
                    [comment setValue:[NSString stringWithFormat:@"%i",oldNumberOfLikes] forKey:@"like_count"];
                    [comment setValue:[NSNumber numberWithBool:FALSE] forKey:@"user_likes"];
                    cell.likeCount.textColor = [UIColor lightGrayColor];
                    
                } else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Failed to unlike comment!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }];
        }
    }
    
}
- (void)like:(NSInteger)index {
    __weak CommentsTableViewController *self_ = self;
     EasyShareCell *cell = (EasyShareCell *)[self_.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.likeCompletion = ^(BOOL success){
        self_.igManager = nil;
        if (success == TRUE) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Succesfully Liked Post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            self_.cellPost.userLikes = TRUE;
            NSInteger oldNumberOfLikes = [self_.cellPost.likeCount integerValue];
            oldNumberOfLikes++;
            self_.cellPost.likeCount = [NSString stringWithFormat:@"%i",oldNumberOfLikes];
            cell.likeButton.actionCount.text = self_.cellPost.likeCount;
            [cell.likeButton.actionButton setTitle:@"Unlike" forState:UIControlStateNormal];
            [cell.likeButton.spinner stopAnimating];
            cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Could not like post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [cell.likeButton.spinner stopAnimating];
            cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        }
        
    };

    void(^unLikeCompletion)(BOOL success) = ^(BOOL success){
        self_.igManager = nil;
        if (success == TRUE) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Succesfully unliked post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            self.cellPost.userLikes = FALSE;
            NSInteger oldNumberOfLikes = [self.cellPost.likeCount integerValue];
            oldNumberOfLikes--;
            self.cellPost.likeCount = [NSString stringWithFormat:@"%i",oldNumberOfLikes];
            cell.likeButton.actionCount.text = self.cellPost.likeCount;
            [cell.likeButton.actionButton setTitle:@"Like" forState:UIControlStateNormal];
            [cell.likeButton.spinner stopAnimating];
            cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Failed to unlike post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [cell.likeButton.spinner stopAnimating];
            cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        }
    };
    cell.likeButton.actionButton.hidden = TRUE;
    [cell.likeButton.spinner startAnimating];
    if (self.cellPost.network == Facebook) {
        FacebookManager *manager = [[FacebookManager alloc]init];
        if (self.cellPost.userLikes == FALSE) {
            [manager likePost:self.cellPost.objectId completion:self.likeCompletion];
            
        } else if (self.cellPost.userLikes == TRUE){
            [manager unLikePost:self.cellPost.objectId completion:unLikeCompletion];
        }
    } else if (self.cellPost.network == Instagram) {
        self.igManager = [[InstagramManager alloc]init];
        if (self.cellPost.userLikes == FALSE) {
            [self.igManager likePost:self.cellPost.objectId WithCompletion:self.likeCompletion];
        } else {
            [self.igManager unLikePost:self.cellPost.objectId WithCompletion:unLikeCompletion];
        }
        
    }
}


- (void)addComment {
    AddCommentViewController *submitComment = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCommentViewController"];
    submitComment.addPost = self.cellPost;
    [self presentViewController:submitComment animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 - (void)dismissed{
 [self dismissViewControllerAnimated:YES completion:nil];
 [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading"];
 [self reload];
 }
 */
- (void)reload{
    FacebookManager *fbTotalControl = [[FacebookManager alloc]init];
    [fbTotalControl getCommentsWithCursor:nil objectID:self.cellPost.objectId completion:^(NSError *resultingError, id comments) {
        [DejalBezelActivityView removeViewAnimated:YES];
        if (resultingError) {
            NSLog(@"%@",resultingError);
            
        } else {
            if ([comments isKindOfClass:[NSDictionary class]]) {
                self.comments = [comments objectForKey:@"data"];
                
                
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
                    self.tableView.tableFooterView = [self tableFooter];
                }
            }
        }
        
    }];
    
}
- (void)dismissed {
    //for closing add comment view
    [self dismissViewControllerAnimated:YES completion:nil];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."];
    [self reload];
}
- (void)igLoadMore {
    self.igManager = [[InstagramManager alloc]init];
    [self.igManager getCommentsForPostID:self.cellPost.objectId WithCompletion:^(NSMutableArray *comments) {
        if (comments) {
            self.comments = comments;
            self.tableView.tableFooterView = nil;
            [self.tableView reloadData];
        }
    }];
    
}
- (void)fbLoadMore {
    isLoading = TRUE;
    FacebookManager *facebookTotalControl = [[FacebookManager alloc]init];
    [facebookTotalControl getCommentsWithCursor:self.nextPageID objectID:self.cellPost.objectId completion:^(NSError *resultingError, id comments) {
        if (resultingError) {
            NSLog(@"%@",resultingError);
        } else {
            if ([comments isKindOfClass:[NSDictionary class]]) {
                NSArray *resultComments = [comments objectForKey:@"data"];
                
                
                self.nextPageID = [[[comments objectForKey:@"paging"]objectForKey:@"cursors"]objectForKey:@"after"];
                if (self.nextPageID) {
                    
                    NSMutableArray *indexArray = [[NSMutableArray alloc]init];
                    for (int i = 0; i < resultComments.count; i++) {
                        [indexArray addObject:[NSIndexPath indexPathForRow:self.comments.count+i inSection:1]];
                    }
                    [self.comments addObjectsFromArray:resultComments];
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:indexArray
                                          withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableView endUpdates];
                    isLoading = FALSE;
                    [self.refreshControl endRefreshing];
                } else {
                    isLoading = FALSE;
                    self.tableView.tableFooterView = nil;
                }
                
            }
        }
    }];
}
- (void)gpLoadMore {
    
}
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    if (indexPath.section == 0) {
        NSLog(@"%f",self.postCell.bounds.size.height);
        return self.cellHeight;
    } else {
        if (indexPath.row > self.comments.count - 1) {
            size = CGSizeMake(0, -11);
        } else {
            NSString *text;
            switch (self.cellPost.network) {
                case Facebook:
                    text = [[self.comments objectAtIndex:indexPath.row]objectForKey:@"message"];
                    break;
                case Instagram:
                    text = [[self.comments objectAtIndex:indexPath.row]objectForKey:@"text"];
                    NSLog(@"%@",text);
                    break;
                default:
                    break;
            }
            size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(249, INT_MAX)];
        }
        return size.height+51;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    NSLog(@"%i",self.comments.count);
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.comments.count;
    } else {
        return 0;
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return @"";
            break;
        case 1:
            return @"Comments";
            break;
            
        default:
            return @"";
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id theCell;
    if (indexPath.section == 0) {
        return self.postCell;
        
        
    } else if (indexPath.section == 1){
        CommentCell *cell;
        cell =[self.tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        NSDictionary *post = [self.comments objectAtIndex:indexPath.row];
        NSDate *commenttime = [[NSDate alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSTimeInterval interval;
        switch (self.cellPost.network) {
            case Facebook:
                cell.username.text = [[post objectForKey:@"from"]objectForKey:@"name"];
                cell.comment.text = [post objectForKey:@"message"];
                cell.likeCount.text = [NSString stringWithFormat:@"%@ likes",[post objectForKey:@"like_count"]];
                if ([[post objectForKey:@"user_likes"]boolValue]== TRUE) {
                    cell.likeCount.textColor = [UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:1.0];
                    
                } else {
                    cell.likeCount.textColor = [UIColor lightGrayColor];
                }
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
                commenttime = [formatter dateFromString:[post objectForKey:@"created_time"]];
                cell.time.text = [GlobalManager stringDistanceToDate:commenttime];
                break;
            case Instagram:
                cell.username.text = [[post objectForKey:@"from"]objectForKey:@"full_name"];
                cell.comment.text = [post objectForKey:@"text"];
                cell.likeCount.text = @"";
                interval = [[post objectForKey:@"created_time"]doubleValue];
                commenttime = [NSDate dateWithTimeIntervalSince1970:interval];
                cell.time.text = [GlobalManager stringDistanceToDate:commenttime];
                break;
            default:
                break;
        }
        
        if (![self.profilecache objectForKey:[[post objectForKey:@"from"]objectForKey:@"id"]]) {
            ProfilePictureDownloader *downloader = [[ProfilePictureDownloader alloc]init];
            __weak ProfilePictureDownloader *_downloader = downloader; //__weak?
            [downloader setCompletionHandler:^{
                
                cell.profileImage.image = _downloader.profilepic;
                
                
                if (_downloader.profilepic) {
                    [self.profilecache setObject:_downloader.profilepic forKey:[[post objectForKey:@"from"]objectForKey:@"id"]];
                }
                
            }];
            switch (self.cellPost.network) {
                case Facebook:
                    [downloader startWithUserId:[[post objectForKey:@"from"]objectForKey:@"id"]];
                    break;
                case Instagram:
                    NSLog(@"%@",[[post objectForKey:@"from"]objectForKey:@"profile_picture"]);
                    [downloader startWithURL:[[post objectForKey:@"from"]objectForKey:@"profile_picture"]];
                default:
                    break;
            }
        
            
        } else {
            cell.profileImage.image = [self.profilecache objectForKey:[[post objectForKey:@"from"]objectForKey:@"id"]];
        }
        
        // Configure the cell...
        NSLog(@"%i vs %i",indexPath.row,self.comments.count-1);
        theCell = cell;
        
    }
    return theCell;
    
    
}

- (NSDate *)yesterday {
    NSCalendar *ical2 = [[NSCalendar alloc] initWithCalendarIdentifier:[[NSCalendar currentCalendar]calendarIdentifier]];
    [ical2 setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [ical2 components:( NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit ) fromDate:[NSDate date]];
    [components setDay:[components day]-1];
    [components setHour:0];
    [components setMinute:0];
    
    return [ical2 dateFromComponents:components];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && self.cellPost.network == Facebook) {
        
        
        UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        action.tag = indexPath.row;
        NSDictionary *post = [self.comments objectAtIndex:indexPath.row];
        NSLog(@"%@",post);
        if ([[post objectForKey:@"user_likes"]boolValue] == TRUE) {
            [action addButtonWithTitle:@"Unlike"];
        } else {
            [action addButtonWithTitle:@"Like"];
        }
        [action addButtonWithTitle:@"Cancel"];
        action.cancelButtonIndex = 1;
        [action showInView:self.view];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"scrollingstarted" object:nil];
    
    CGFloat height = scrollView.frame.size.height;
    
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    NSLog(@"is %f",distanceFromBottom);
    
    if (distanceFromBottom <= height && isLoading == FALSE && self.tableView.tableFooterView != nil && self.tableView.contentSize.height > self.tableView.frame.size.height) {
        NSLog(@"%@",self.tableView.tableFooterView);
        switch (self.cellPost.network) {
            case Instagram:
                [self igLoadMore];
                break;
            case Facebook:
                [self fbLoadMore];
                break;
            default:
                break;
        }
        
        
    }
    
}





/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
- (UIImageView *)zoomedImageView {
    if (!_zoomedImageView) {
        _zoomedImageView = [[UIImageView alloc]init];
        _zoomedImageView.contentMode = UIViewContentModeScaleAspectFit;
        _zoomedImageView.userInteractionEnabled = TRUE;
        
    }
    return _zoomedImageView;
}
- (void)cellTapped:(NSInteger)row {
  
    Post *cellpost = self.cellPost;
    
    
    
    if (cellpost.type == Photo) {
        CellImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CellImageViewController"];
        vc.delegate = self;
        [vc setupWithViewController:self andPost:self.cellPost inRow:0 imageView:self.zoomedImageView inTable:self.tableView];
    } else if (cellpost.type == Video){
        [GlobalManager playVideoWithViewController:self post:cellpost];
    }
    
    
}


- (void)dismissWithFrame:(CGRect)imageFrame imageColor:(UIColor *)photoBackgroundColor {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    self.zoomedImageView.superview.backgroundColor = photoBackgroundColor;
    
    EasyShareCell *cellselected = (EasyShareCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.zoomedImageView.superview.hidden = FALSE;
    
    self.zoomedImageView.frame = [self.zoomedImageView convertRect:imageFrame toView:self.zoomedImageView.superview];
    
    [UIView animateWithDuration:0.4 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[self navigationController]setNavigationBarHidden:NO animated:YES];
        [self.zoomedImageView setFrame: [cellselected.viewimage convertRect:cellselected.viewimage.bounds toView:self.zoomedImageView.superview]];
        self.zoomedImageView.superview.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished){
        [self.zoomedImageView.superview removeFromSuperview];
        cellselected.viewimage.hidden = FALSE;
        
        self.tableView.scrollEnabled = TRUE;
    }];
    
    
}
- (void)goToCommentsWithFrame:(CGRect)imageFrame imageColor:(UIColor *)photoBackgroundColor andPost:(Post *)tappedPost {
    [self dismissWithFrame:imageFrame imageColor:photoBackgroundColor];
}



@end
