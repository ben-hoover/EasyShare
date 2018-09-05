//
//  CommentsTableViewController.h
//  EasyShare
//
//  Created by Benjamin Hoover on 7/19/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "CommentCell.h"

@interface CommentsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, EasyShareCellDelegate, CellImageViewControllerDelgate, UIActionSheetDelegate> {
    BOOL isLoading;
}
@property (nonatomic, strong) UIView *tableFooter;
@property (nonatomic, strong) UIImageView *zoomedImageView;
@property (nonatomic, strong) Post *cellPost;
@property (strong, nonatomic) IBOutlet CommentCell *comcell;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSMutableDictionary *profilecache;
@property (nonatomic, strong) NSString *nextPageID;
@property (nonatomic, strong) EasyShareCell *postCell;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic, strong) NSMutableArray *arrayOfOptions;
@property (nonatomic, strong) InstagramManager *igManager;
@property (nonatomic, strong) void(^likeCompletion)(BOOL success);
- (UIView *)tableFooter;
- (void)reload;
- (void)addComment;
- (void)loadWithPostID:(NSString *)postID;
@end
