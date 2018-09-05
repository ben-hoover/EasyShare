//
//  CellImageViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 6/26/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomImageView.h"
@class EasyShareCell;
@class Post;
@class InstagramManager;
@protocol CellImageViewControllerDelgate <NSObject>
@required
- (void)dismissWithFrame:(CGRect)imageFrame imageColor:(UIColor *)photoBackgroundColor;
- (void)goToCommentsWithFrame:(CGRect)imageFrame imageColor:(UIColor *)photoBackgroundColor andPost:(Post *)tappedPost;//to remove post with caching
@end

@interface CellImageViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate> {
    CGPoint oldPosition;
    NSMutableArray *imagePosition;
    UIColor *finalColor;
    double distancefromcenter;
}
@property (nonatomic, strong) InstagramManager *igManager;
@property (weak, nonatomic) id <CellImageViewControllerDelgate> delegate;
@property (strong, nonatomic) UIImage *bgimagepic;
@property (strong, nonatomic) Post *tappedPost;
@property (strong, nonatomic) IBOutlet UIScrollView *scroller;
@property (strong, nonatomic) UIImageView *cellimage;
@property (weak, nonatomic) EasyShareCell *cell;
//@property (strong, nonatomic) IBOutlet UIToolbar *topControlBar;
@property (strong, nonatomic) IBOutlet UIView *topControlBar;
@property (strong, nonatomic) IBOutlet UIView *bottomControlBar;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIImageView *bgimage;
//@property (strong, nonatomic) IBOutlet UIToolbar *bottomControlBar;
@property (strong, nonatomic) IBOutlet UITextView *caption;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesCount;
@property (strong, nonatomic) IBOutlet UILabel *commentsCount;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UIView *borderView;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionBottomConstraint;
- (void)setupWithViewController:(UIViewController *)controller andPost:(Post *)post inRow:(NSInteger)row imageView:(UIImageView *)zoomedImageView inTable:(UITableView *)tableView;
- (void)flashControls;
- (void)moveImage:(UIPanGestureRecognizer *)recognizer;
@end
