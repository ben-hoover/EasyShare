//
//  ViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 5/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyShareCell.h"
#import "FacebookManager.h"
#import "CellImageViewController.h"
@class InstagramManager;

@class Post;
@interface ViewController : UITableViewController <UIAlertViewDelegate, UIScrollViewDelegate, FacebookManagerDelegate, EasyShareCellDelegate, CellImageViewControllerDelgate> {
    UIDeviceOrientation oldorientation;
    void (^animationCompletionBlock)(void);
    int loads;
}
- (void)goToComments:(NSNotification *)notification;
- (void)commentsScreen:(Post *)objectid;
- (void)displaylogin: (NSNotification *)notification;
- (void)load;
- (void) fullscren;
- (void)cellwastapped: (UITapGestureRecognizer *)recognizer;
- (CGFloat) getImageViewHeight: (CGFloat)oldheight;
- (void)deviceDidRotate: (NSNotification *)notification;
- (void)applychanges:(CGAffineTransform)newtransform;
- (float)distanceBetweeenViewsWithNumber:(int)num WithSuperViewWidth: (float) width itemWidth: (float)itemWidth andPadding:(float)padding;
@property (nonatomic, strong) FacebookManager *fbManager;
@property (nonatomic, strong) InstagramManager *igManager;
@property (nonatomic) BOOL isinfullscreen;
@property NSMutableArray *arrayofposts;
@property NSMutableDictionary *fbphotocache;
@property (nonatomic, strong) NSMutableDictionary *igphotocache;
@property BOOL displayloginview;
@property int numberofcells;
@property NSMutableDictionary *fbprofilecache;
@property (nonatomic, strong) NSMutableDictionary *igprofilecache;
@property (nonatomic, strong) NSMutableDictionary *twprofilecache;
@property (nonatomic,strong) NSMutableDictionary *linkImageCache;
@property CGFloat neededheight;
@property UIImage *image;
@property (nonatomic, strong) NSIndexPath *fullscreenimageindex;
@property (strong, nonatomic, readonly) UIImageView *zoomedImageView;
@property (strong, nonatomic, readonly) UIScrollView *imagecontainer;
@end
