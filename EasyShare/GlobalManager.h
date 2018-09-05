//
//  GlobalManager.h
//  EasyShare
//
//  Created by Benjamin Hoover on 8/5/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

//Help the situation at Fukushima-Daiichi
#import <Foundation/Foundation.h>
@class Post;
@class InstagramManager;
@class FacebookManager;
@class TwitterManager;
@interface GlobalManager : NSObject {
    int networksToGet;
    int networksDone;
}
+ (NSString *)stringDistanceToDate:(NSDate *)date;
+ (void)showImage:(UIViewController *)theController;
+ (void)playVideoWithViewController:(UIViewController *)view post:(Post *)cellPost;
+ (NSMutableArray *)listOfOptionsForPost:(Post *)info showCount:(BOOL)count;
- (void)getFeedWithCompletionBlock:(void(^)(NSArray *result))completion;
- (void)doCleanupWithArray:(NSMutableArray *)feedArray;
@property (nonatomic, strong) FacebookManager *fbManager;
@property (nonatomic, strong) TwitterManager *twManager;
@property (nonatomic, strong) InstagramManager *igManager;
@property (nonatomic, strong) void(^feedCompletion)(NSArray *);
@end
