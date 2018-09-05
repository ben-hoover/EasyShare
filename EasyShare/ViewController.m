  //
//  ViewController.m
//  EasyShare
//
//  Created by Benjamin Hoover on 5/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//





#import "ViewController.h"
#import "FBLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "ProfilePictureDownloader.h"
#import "DejalActivityView.h"
#import "Post.h"
#import "CellImageViewController.h"
#import "AppDelegate.h"
#import "FacebookManager.h"
#import "BackViewButtonView.h"
#import "CommentsTableViewController.h"
#import "WebViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GlobalManager.h"
#import "InstagramManager.h"
#import "TwitterManager.h"
#import "UINavigationController+StatusBarStyle.h"
#define Delegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidUnload {
    
}
- (FacebookManager *)fbManager {
    if (!_fbManager) {
        _fbManager = [[FacebookManager alloc]init];
    }
    return _fbManager;
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"showlogin"]) {
        [defaults setBool:FALSE forKey:@"showlogin"];
        UINavigationController *navcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            navcontroller.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        }
        [self presentViewController:navcontroller animated:TRUE completion:nil];
    } else {
        if (self.arrayofposts.count == 0) {
            loads = 0;
            if ([FBSession activeSession].state == FBSessionStateOpen) {
                [self load3];
            }
        }
       

        
        oldorientation = UIDeviceOrientationPortrait;
        self.isinfullscreen = FALSE;
        
        
           }
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.frame = CGRectMake(0,-44,320,480);
  
    
    /*[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
     */
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.fbprofilecache = [[NSMutableDictionary alloc]init];
    self.fbphotocache = [[NSMutableDictionary alloc]init];
    self.igprofilecache = [[NSMutableDictionary alloc]init];
    self.igphotocache = [[NSMutableDictionary alloc]init];
    self.twprofilecache = [[NSMutableDictionary alloc]init];
    UIRefreshControl *refresher = [[UIRefreshControl alloc]init];
    refresher.tintColor = [UIColor grayColor];
    [refresher addTarget:self action:@selector(load) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresher;
 
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.tableView.scrollEnabled = FALSE;
    self.linkImageCache = [[NSMutableDictionary alloc]init];
    [DejalBezelActivityView activityViewForView:self.tableView];
    loads = 0;
   if ([FBSession activeSession].state == FBSessionStateOpen) {
        [self load3];
   }
    //[self load2];


	// Do any additional setup after loading the view, typically from a nib.
   
}

- (void)loginSuccess:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self load];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.fbphotocache removeAllObjects];
    self.fbphotocache = nil;
    self.fbphotocache = [[NSMutableDictionary alloc]init];
    [self.fbprofilecache removeAllObjects];
    self.fbprofilecache = nil;
    self.fbprofilecache = [[NSMutableDictionary alloc]init];
    [self.linkImageCache removeAllObjects];
    self.linkImageCache = nil;
    self.linkImageCache = [[NSMutableDictionary alloc]init];
    
    [self.igprofilecache removeAllObjects];
    self.igprofilecache = nil;
    self.igprofilecache = [[NSMutableDictionary alloc]init];
    [self.igphotocache removeAllObjects];
    self.igphotocache = nil;
    self.igphotocache = [[NSMutableDictionary alloc]init];
    
    [self.twprofilecache removeAllObjects];
    self.twprofilecache = nil;
    self.twprofilecache = [[NSMutableDictionary alloc]init];
    // Dispose of any resources that can be recreated.
}

- (void) load {
    self.fbManager.fbDelegate = self;
    NSCalendar *iCal = [[NSCalendar alloc]initWithCalendarIdentifier:[[NSCalendar currentCalendar]calendarIdentifier]];
    [iCal setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [iCal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    [components setHour:[components hour]-4];
    NSDate *fourHoursAgo = [iCal dateFromComponents:components];
    NSLog(@"%@",fourHoursAgo);
    [self.fbManager getFeedWithUntil:[fourHoursAgo timeIntervalSince1970] Completion:^(NSMutableArray *result){
        if (result) {
            [self feedDataFinishedWithData:result nextPage:nil load:0];
        }
    }];
    
                /*
            if (error.localizedDescription != nil) {
                NSLog(@"%@ \n",error);
                NSLog(@"desc %@ \n \n",error.localizedDescription);
                NSDictionary *erroruserinfo = [[NSDictionary alloc]initWithDictionary:error.userInfo];
                if ([erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]) {
                    NSLog(@"%@",[erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]);
                    if ([[erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]isKindOfClass:[NSError class]]) {
                        NSLog(@"is an error");
                        NSError *innererror = [erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Error" message:innererror.localizedDescription delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry", nil];
                        [alert show];
                    }
                }
                
                
            }
        }
        
        
        }];
             */
    
}
- (void)load2 {
    /*
    self.igManager = [[InstagramManager alloc]init];
    [self.igManager getFeedWithCompletion:^(id completion) {
        if ([completion isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *array = completion;
            self.numberofcells = array.count;
            self.arrayofposts = array;
            self.tableView.scrollEnabled = TRUE;
            [self.tableView reloadData];
            [DejalBezelActivityView removeViewAnimated:YES];
            self.igManager = nil;
            
        }
    }];
     */
}

- (void)load3 {
    GlobalManager *gbManager = [[GlobalManager alloc]init];
    [gbManager getFeedWithCompletionBlock:^(NSArray *result){
        NSArray *array = result;
        self.numberofcells = array.count;
        self.arrayofposts = [array mutableCopy];
        self.tableView.scrollEnabled = TRUE;
        [self.tableView reloadData];
        [DejalBezelActivityView removeViewAnimated:YES];
      
        Delegate.addStatusBar.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0.957 green:0.9686 blue:0.97647 alpha:1.0];
    }];
}
- (void)feedDataFinishedWithData:(NSMutableArray *)result nextPage:(NSString *)next load:(int)load {
    if (load == 0) {
        self.numberofcells = result.count;
        self.arrayofposts = result;
        self.tableView.scrollEnabled = TRUE;
        [self.tableView reloadData];
        [DejalBezelActivityView removeViewAnimated:YES];
        [self.refreshControl endRefreshing];
        NSLog(@"done");
        loads++;
        NSLog(@"%i",result.count);
        
        
        //if (next) {
        //    FacebookManager *manager = [[FacebookManager alloc]init];
          //  manager.load = loads;
          //  manager.fbDelegate = self;
           // [manager getFeedUntil:next];
       // }
    } else {
        NSUInteger oldCount = self.arrayofposts.count;
        [self.arrayofposts addObjectsFromArray:result];
        [self.tableView reloadData];
        
    }
    

}
- (void)failedToGetFeed:(NSError *)error {
    NSDictionary *erroruserinfo = [[NSDictionary alloc]initWithDictionary:error.userInfo];
    if ([erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]) {
        NSLog(@"%@",[erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]);
        if ([[erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]isKindOfClass:[NSError class]]) {
            NSLog(@"is an error");
            NSError *innererror = [erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Error" message:innererror.localizedDescription delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry", nil];
            [alert show];
        }
    }
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //check for presence of monocle jailbreak tweak
    /*  NSString *monoclelocation = @"/Library/MobileSubstrate/DynamicLibraries/Monocle.dylib";
     if ([[NSFileManager defaultManager] fileExistsAtPath:monoclelocation]) {
     NSLog(@"monocle installed");
     }
     */
}






- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
            
        case 0:
            exit(0);
            break;
        case 1:
            self.tableView.scrollEnabled = FALSE;
            
            [self load];
            break;
        default:
            break;
    }
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return self.numberofcells-1;
    return self.arrayofposts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EasyShareCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    Post *cellpost = [[Post alloc]init];
    cellpost = [self.arrayofposts objectAtIndex:indexPath.row];
    [cell setup:cellpost];
    cell.delegate = self;
        
    
      return cell;
}
- (void)like:(NSInteger)index {
    Post *tappedPost = [self.arrayofposts objectAtIndex:index];
    EasyShareCell *cell = (EasyShareCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.likeButton.actionButton.hidden = TRUE;
    [cell.likeButton.spinner startAnimating];
    void(^likeCompletion)(BOOL) = ^(BOOL success) {
        if (success == TRUE) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Succesfully Liked Post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            tappedPost.userLikes = TRUE;
            NSInteger oldNumberOfLikes = [tappedPost.likeCount integerValue];
            oldNumberOfLikes++;
            tappedPost.likeCount = [NSString stringWithFormat:@"%i",oldNumberOfLikes];
            cell.likeButton.actionCount.text = tappedPost.likeCount;
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
    void(^unLikeCompletion)(BOOL) = ^(BOOL success) {
        if (success == TRUE) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:@"Succesfully unliked post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            tappedPost.userLikes = FALSE;
            NSInteger oldNumberOfLikes = [tappedPost.likeCount integerValue];
            oldNumberOfLikes--;
            tappedPost.likeCount = [NSString stringWithFormat:@"%i",oldNumberOfLikes];
            cell.likeButton.actionCount.text = tappedPost.likeCount;
            [cell.likeButton.actionButton setTitle:@"Like" forState:UIControlStateNormal];
            [cell.likeButton.spinner stopAnimating];
            cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failure!" message:@"Could not unlike post!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [cell.likeButton.spinner stopAnimating];
            cell.likeButton.actionButton.hidden = FALSE;
            [alert show];
        }

    };
    if (tappedPost.network == Facebook) {
        FacebookManager *faceManager = [[FacebookManager alloc]init];
        if (tappedPost.userLikes == FALSE) {
            [faceManager likePost:tappedPost.objectId completion:likeCompletion];
        } else if (tappedPost.userLikes == TRUE) {
            [faceManager unLikePost:tappedPost.objectId completion:unLikeCompletion];
        }
    } else if (tappedPost.network == Instagram) {
        if (tappedPost.userLikes == FALSE) {
            [self.igManager likePost:tappedPost.objectId WithCompletion:likeCompletion];
        } else if (tappedPost.userLikes == TRUE) {
            [self.igManager unLikePost:tappedPost.objectId WithCompletion:unLikeCompletion];
        }
    }
     
}
- (InstagramManager *)igManager {
    if (!_igManager) {
        _igManager = [[InstagramManager alloc]init];
    }
    return _igManager;
}
- (void)goToCommentsWithFrame:(CGRect)imageFrame imageColor:(UIColor *)photoBackgroundColor andPost:(Post *)tappedPost {
    [self dismissWithFrame:imageFrame imageColor:photoBackgroundColor];
    /*
    if (tappedPost.originalAuthor != tappedPost.author) {
          Post *newPost = [Post FBconvertToSharedPhotoPost:tappedPost];
        [self commentsScreen:newPost backButton:FALSE];
    } else {
     */
        [self commentsScreen:tappedPost backButton:FALSE];
    
  

    

}
- (IBAction)openURL:(UIButton *)sender {

    
    Post *tappedlinkPost = [self.arrayofposts objectAtIndex:sender.tag];
    if (tappedlinkPost.type == Link && ![tappedlinkPost.fullURL isEqualToString:@"shared_post"]) {
        
        WebViewController *webViewer = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webViewer.theURL = [NSURL URLWithString:tappedlinkPost.fullURL];
        [self.navigationController pushViewController:webViewer animated:YES];
        NSLog(@"%@",tappedlinkPost.fullURL);

        //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:tappedlinkPost.fullURL]];
        NSLog(@"%@",tappedlinkPost.fullURL);
    } else if ([tappedlinkPost.fullURL isEqualToString:@"shared_post"]) {
        [self commentsScreen:tappedlinkPost backButton:FALSE];
    }
}
- (void)commentsScreen:(Post *)objectid backButton:(BOOL)button {
    
    CommentsTableViewController *comments = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsTableViewController"];
    EasyShareCell *cell = [self.tableView
                           dequeueReusableCellWithIdentifier:@"ImageCell"];
    cell.delegate = comments;
    if ([objectid.fullURL isEqualToString:@"shared_post"] && button == FALSE) {
        
        FacebookManager *manage = [[FacebookManager alloc]init];
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."];
        [manage getMorePostInfoWithID:objectid.photo_objectid completion:^(id results){
            
            [DejalBezelActivityView removeViewAnimated:YES];
            if ([results isKindOfClass:[Post class]]) {
                
                comments.cellPost = results;
                Post *result = results;
         
                CGSize size = [result.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(287, 200000000)];
                CGFloat height = size.height;
                if (result.type == Photo || result.type == Video) {
                    height += result.imageheight;
                } else if (result.type == Link) {
                    height += 80;
                }
                CGFloat cellHeight = height + 100;
                comments.cellHeight = cellHeight;
                [cell setup:results];
                comments.postCell = cell;
                AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
                [delegate.postCache setObject:result forKey:result.objectId];
                [self.navigationController pushViewController:comments animated:YES];
            } else if ([results isKindOfClass:[NSError class]]){
                NSError *error = results;
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }];
       
    } else {
    EasyShareCell *cellInTable = (EasyShareCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:objectid.index inSection:0]];
    
    comments.cellPost = objectid;
    [cell setup:objectid];
    comments.postCell = cell;
    
    
    CGSize size = [objectid.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(287, 200000000)];
    CGFloat height = size.height;
    if (objectid.type == Photo || objectid.type == Video) {
        height += objectid.imageheight;
    } else if (objectid.type == Link) {
        height += 80;
    }
    CGFloat cellHeight = height + 100;
    comments.cellHeight = cellHeight;
    [cellInTable.mainView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [cellInTable.mainView.layer setPosition:CGPointMake(cell.oldposition, cell.mainView.layer.position.y)];
    cellInTable.backView.hidden = TRUE;
    [self.navigationController pushViewController:comments animated:YES];
    
    }
    
}
- (void)comment:(NSInteger)index {
  ;
    Post *thePost = [self.arrayofposts objectAtIndex:index];
    [self commentsScreen:thePost backButton:TRUE];
}
- (void)didDownloadImage:(UIImage *)image typeOfImage:(imageType)type withIndex:(NSInteger)index{
    Post *cellPost = [self.arrayofposts objectAtIndex:index];
    if (image != nil && type == ProfileImage) {
        switch (cellPost.network) {
            case Facebook:
                [self.fbprofilecache setObject:image forKey:cellPost.objectId];
                break;
            case Instagram:
                [self.igprofilecache setObject:image forKey:cellPost.objectId];
                break;
            case Twitter:
                [self.twprofilecache setObject:image forKey:cellPost.objectId];
                break;
            default:
                break;
        }
    
    } else if (image != nil && type == PostImage) {
        switch (cellPost.network) {
            case Facebook:
                [self.fbphotocache setObject:image forKey:cellPost.objectId];
                break;
            case Instagram:
                [self.igphotocache setObject:image forKey:cellPost.objectId];
            default:
                break;
        }
        
    } else if (image != nil && type == LinkImage) {
        [self.linkImageCache setObject:image forKey:cellPost.objectId];
    }
}
- (UIImage *)getImageWithIndex:(NSInteger)index ofType:(imageType)type{
    Post *cellPost = [self.arrayofposts objectAtIndex:index];
    UIImage *lookupResult;
    switch (type) {
        case ProfileImage:
        
            if (cellPost.network == Facebook) {
                lookupResult = [self.fbprofilecache objectForKey:cellPost.objectId];
            } else if (cellPost.network == Instagram) {
                lookupResult = [self.igprofilecache objectForKey:cellPost.objectId];
            } else if (cellPost.network == Twitter) {
                lookupResult = [self.twprofilecache objectForKey:cellPost.objectId];
            }
        break;
        
        case PostImage:
    
            if (cellPost.network == Facebook) {
                lookupResult = [self.fbphotocache objectForKey:cellPost.objectId];
            } else {
                lookupResult = [self.igphotocache objectForKey:cellPost.objectId];
            }
            break;
        case LinkImage:
            lookupResult = [self.linkImageCache objectForKey:cellPost.objectId];
            break;
        default:
            break;
    }
    return lookupResult;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"scrollingstarted" object:nil];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.navigationController.navigationBar.alpha = 1.0 - (scrollView.contentOffset.y/100);
        
       // if (self.navigationController.navigationBar.alpha == 0.0) {
       //     self.navigationController.navigationBar.hidden = TRUE;
        //}
    } else {
      
        if (scrollView.contentOffset.y > 200 && self.navigationController.navigationBar.hidden == FALSE) {
           [self.navigationController setNavigationBarHidden:YES animated:YES];
        } else {
            if (self.navigationController.navigationBar.hidden == TRUE && scrollView.contentOffset.y <= 200) {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
        }
        
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *cellPost = [self.arrayofposts objectAtIndex:indexPath.row];
    if (cellPost.network == Twitter) {
        WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webView.theURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@/status/%@",cellPost.altUserName,cellPost.objectId]];
        
        [self.navigationController pushViewController:webView animated:YES];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* In this example, there is a different cell for
     the top, middle and bottom rows of the tableView.
     Each type of cell has a different height.
     self.model contains the data for the tableview
     */
    Post *cellpost = [[Post alloc]init];
    cellpost = [self.arrayofposts objectAtIndex:indexPath.row];
    CGSize size = [cellpost.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(287, 200000000)];
    CGFloat height = size.height;
    if (cellpost.type == Photo || cellpost.type == Video) {
        height += cellpost.imageheight;
    } else if (cellpost.type == Link) {
        height += 80;
    }
    return height + 100;
}
#pragma mark Cell Tap Methods
@synthesize zoomedImageView = _zoomedImageView;
@synthesize imagecontainer = _imagecontainer;
@synthesize fullscreenimageindex = _fullscreenimageindex;
- (UIImageView *)zoomedImageView {
    if (!_zoomedImageView) {
        _zoomedImageView = [[UIImageView alloc]init];
        _zoomedImageView.contentMode = UIViewContentModeScaleAspectFit;
        _zoomedImageView.userInteractionEnabled = TRUE;
        
    }
    return _zoomedImageView;
}

- (NSIndexPath *)fullscreenimageindex{
    if (!_fullscreenimageindex) {
        _fullscreenimageindex = [[NSIndexPath alloc]init];
    }
    return _fullscreenimageindex;
}
- (IBAction)seeProfile:(UIButton *)sender {
    NSLog(@"%i",sender.tag);
    EasyShareCell *cell = (EasyShareCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    if (cell.Network == Facebook) {
        [self.fbManager goToProfile:cell.associatedUsername viewController:self];
    } else if (cell.Network == Twitter) {
        TwitterManager *tm = [[TwitterManager alloc]init];
        [tm goToProfile:cell.associatedUsername viewController:self];
    } else if (cell.Network == Instagram) {
        InstagramManager *im = [[InstagramManager alloc]init];
        [im goToProfile:cell.associatedUsername viewController:self];
    }
}

- (void)cellTapped:(NSInteger)row {
    Post *tmppost = [self.arrayofposts objectAtIndex:row];
    if (tmppost.type == Photo) {
        CellImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CellImageViewController"];
        self.fullscreenimageindex = [NSIndexPath indexPathForItem:row inSection:0];
        Delegate.addStatusBar.hidden = TRUE;
        [vc setupWithViewController:self andPost:tmppost inRow:row imageView:self.zoomedImageView inTable:self.tableView];
    } else if (tmppost.type == Video){
        [GlobalManager playVideoWithViewController:self post:tmppost];
    }
    /*
    self.fullscreenimageindex = cellposition;
    NSIndexPath *cellposition = [NSIndexPath indexPathForRow:row inSection:0];
    EasyShareCell *cellselected = (EasyShareCell *)[self.tableView cellForRowAtIndexPath:cellposition];
    Post *tmppost = [self.arrayofposts objectAtIndex:cellselected.index];
    Post *cellpost;
    if (tmppost.isAShare == TRUE) {
        AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
        cellpost = [delegate.postCache objectForKey:tmppost.photo_objectid];
    } else {
        cellpost = tmppost;
    }
    
    if (cellpost.type == Photo) {
        CellImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CellImageViewController"];
        vc.delegate = self;
        self.tableView.scrollEnabled = FALSE;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [[self navigationController]setNavigationBarHidden:YES animated:YES];
        
        NSLog(@"tap");
        self.fullscreenimageindex = cellposition;
        UIView *backgroundview = [[UIView alloc]initWithFrame:self.tableView.bounds];
        backgroundview.backgroundColor = [UIColor clearColor];
        [self.tableView addSubview:backgroundview];
        [backgroundview addSubview:self.zoomedImageView];
        
        self.zoomedImageView.image = cellselected.viewimage.image;
        
        self.zoomedImageView.frame = [cellselected.viewimage convertRect:cellselected.viewimage.bounds toView:backgroundview];
        self.zoomedImageView.tag = cellposition.row;
        self.zoomedImageView.hidden = TRUE;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
            UIGraphicsBeginImageContextWithOptions(self.tableView.frame.size, NO, [UIScreen mainScreen].scale);
        else
            UIGraphicsBeginImageContext(self.tableView.frame.size);
        [self.tableView.superview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *parentViewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.zoomedImageView.hidden = FALSE;
        
        
        [UIView animateWithDuration:1.0 animations:^{
            
            backgroundview.backgroundColor = [UIColor blackColor];
            self.zoomedImageView.frame = backgroundview.bounds;
            self.isinfullscreen = TRUE;
        } completion:^(BOOL finished) {
            
            [self presentViewController:vc animated:NO completion:^{
                               
                vc.cellimage.image = self.zoomedImageView.image;
                vc.bgimagepic = parentViewImage;
                vc.bgimage.image = vc.bgimagepic;
                
                    vc.caption.text = cellpost.caption;
                    vc.userLabel.text = cellpost.author;
                    
                if (cellpost.likeCount && cellpost.commentCount && cellpost.time) {
                    vc.date.text = [GlobalManager stringDistanceToDate:cellpost.time];
                    vc.likesCount.text = [NSString stringWithFormat:@"%@ Likes", cellpost.likeCount];
                    NSLog(@"comments are %@",cellpost.originalCommentCount);
                    vc.commentsCount.text = [NSString stringWithFormat:@"%@ Comments",cellpost.commentCount];
                    vc.tappedPost = cellpost;
         
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
                                    vc.likesCount.text = [NSString stringWithFormat:@"%@ Likes",[[[datas objectAtIndex:0]objectForKey:@"like_info"]objectForKey:@"like_count"]];
                                    vc.commentsCount.text = [NSString stringWithFormat:@"%@ Comments",[[[datas objectAtIndex:0]objectForKey:@"comment_info"]objectForKey:@"comment_count"]];
                                    NSTimeInterval seconds = [[[datas objectAtIndex:0]objectForKey:@"created"]doubleValue];
                                    NSDate *postedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                                    cellpost.time = postedDate;
                                    
                                    vc.date.text = [GlobalManager stringDistanceToDate:postedDate];
                                    vc.tappedPost = cellpost;
                                    
                                }
                                
                            }
                        }];
                    }
                    
                    
                }
                
                    
                
                
                NSLog(@"%@",vc.bgimage.image);
                backgroundview.hidden = TRUE;
                if (cellpost.story == FALSE || cellpost.originalCaption) {
                    CGSize size = [vc.caption.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-16, INT_MAX)];
                    size.height += 16;
                    vc.captionHeightConstraint.constant = MIN(size.height, vc.captionHeightConstraint.constant);
                } else {
                    vc.captionHeightConstraint.constant = 0;
                    vc.captionBottomConstraint.constant = 0;
                    vc.caption.hidden = TRUE;
                    vc.borderView.hidden = TRUE;
                }
                
            }];
            
        }];
        
        // cellselected.viewimage.hidden = TRUE;
        self.tableView.scrollEnabled = FALSE;

    } else if (cellpost.type == Video){
        [GlobalManager playVideoWithViewController:self url:cellpost.url];
    }
       
    */
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
- (void)dismissWithFrame:(CGRect)imageFrame imageColor:(UIColor *)photoBackgroundColor {

    [self dismissViewControllerAnimated:NO completion:nil];
 
    self.zoomedImageView.superview.backgroundColor = photoBackgroundColor;
   
    EasyShareCell *cellselected = (EasyShareCell *)[self.tableView cellForRowAtIndexPath:self.fullscreenimageindex];
    self.zoomedImageView.superview.hidden = FALSE;
    self.isinfullscreen = FALSE;
    self.zoomedImageView.frame = [self.zoomedImageView convertRect:imageFrame toView:self.zoomedImageView.superview];
    oldorientation = UIDeviceOrientationPortrait;
    [UIView animateWithDuration:0.4 animations:^{
        self.imagecontainer.transform = CGAffineTransformIdentity;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[self navigationController]setNavigationBarHidden:NO animated:YES];
        [self.zoomedImageView setFrame: [cellselected.viewimage convertRect:cellselected.viewimage.bounds toView:self.zoomedImageView.superview]];
        self.zoomedImageView.superview.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished){
        [self.zoomedImageView.superview removeFromSuperview];
        cellselected.viewimage.hidden = FALSE;

        self.tableView.scrollEnabled = TRUE;
        Delegate.addStatusBar.hidden = FALSE;
    }];
    

}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        // Portrait frames
        self.imagecontainer.frame = CGRectMake(self.tableView.bounds.origin.x, self.tableView.bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.zoomedImageView.frame = self.imagecontainer.bounds;
      
    } else {
        // Landscape frames
        self.imagecontainer.frame = CGRectMake(self.tableView.bounds.origin.x, self.tableView.bounds.origin.y, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        self.zoomedImageView.frame = self.imagecontainer.bounds;
    }
}
#pragma mark Orientation
//@synthesize landscapesupported = _landscapesupported;
- (BOOL)shouldAutorotate {
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

/*- (void)deviceDidRotate:(NSNotification *)notification {
    CGAffineTransform transform;
    switch (oldorientation) {
            //moving clockwise
        case UIDeviceOrientationPortrait:
            if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft && self.isinfullscreen == TRUE) {
                transform = CGAffineTransformMakeRotation(M_PI_2);
                [self applychanges:transform];
            } else if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeRight && self.isinfullscreen == TRUE) {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                [self applychanges:transform];
            }
            
            break;
        case UIDeviceOrientationLandscapeLeft:
            if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationPortrait && self.isinfullscreen == TRUE) {
                transform = CGAffineTransformIdentity;
                [self applychanges:transform];
            } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight && self.isinfullscreen == TRUE) {
                transform = CGAffineTransformMakeRotation(M_PI);
                [self applychanges:transform];
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationPortrait && self.isinfullscreen == TRUE) {
                transform = CGAffineTransformIdentity;
                [self applychanges:transform];
            } else if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft && self.isinfullscreen == TRUE) {
                transform = CGAffineTransformMakeRotation(-M_PI);
                [self applychanges:transform];
            }
            
            break;
        case UIDeviceOrientationUnknown:
            oldorientation = [[UIDevice currentDevice]orientation];
            break;
        default:
            break;
    }
    NSLog(@"old orientation is %d, new is %d",oldorientation,[[UIDevice currentDevice]orientation]);
}
- (void)applychanges:(CGAffineTransform)newtransform {
    CGRect newbounds;
    if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeRight) {
        newbounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height , 320);
    } else {
        newbounds = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
    }
   
    oldorientation = [[UIDevice currentDevice]orientation];
    __unsafe_unretained ViewController *self_ = self;
    
    CABasicAnimation* spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                                       spinAnimation.fromValue = [NSNumber numberWithFloat:0];
                                        spinAnimation.toValue = [NSNumber numberWithFloat:M_PI_2];
                                        spinAnimation.removedOnCompletion = FALSE;
                                       spinAnimation.duration = 0.6;
                                            animationCompletionBlock = ^{
                                               
                                                    self_.imagecontainer.transform = newtransform;
                                                    self_.imagecontainer.bounds = newbounds;
                                                    self_.zoomedImageView.frame = self_.zoomedImageView.superview.bounds;
                                               
                                                
                                           // [self_.zoomedImageView.layer removeAllAnimations];
                                        };
    
                                        spinAnimation.delegate = self;
                                       [self.zoomedImageView.layer addAnimation:spinAnimation forKey:@"spinAnimation"];


    [UIView animateWithDuration:0.6 animations:^{
        self.zoomedImageView.bounds = newbounds;
    }];
    
    
}
 */


- (void)animationDidStart:(CAAnimation *)anim {
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (animationCompletionBlock) {
        animationCompletionBlock();
    }
    
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}
#pragma mark UIScrollViewMethods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.zoomedImageView;
}
@end
