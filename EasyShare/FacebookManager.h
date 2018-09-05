//
//  FacebookManager.h
//  EasyShare
//
//  Created by Benjamin Hoover on 7/11/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FacebookManagerDelegate <NSObject>
//@optional
@required

@optional
- (void)feedDataFinishedWithData:(NSMutableArray *)result nextPage:(NSString *)next load:(int)load;
- (void)failedToGetFeed:(NSError *)error;
- (void)commentAddDidFinish:(NSError *)error;
@end
@interface FacebookManager : NSObject <UIAlertViewDelegate>
{
    __block NSMutableArray *results;
    __block int completedDownloads;
    __block NSString* nextPage;
    __block NSMutableDictionary *userIDcache;
    __block NSArray *postData;
    __block NSArray *userIDData;
    __block NSArray *pageIDData;
    __block NSDictionary *IDCache;
    

}
- (void)goToProfile:(NSString *)profileID viewController:(UIViewController *)vc;
- (void)getFeedWithUntil:(NSInteger)time Completion:(void (^)(NSMutableArray *result))completionBlock;
- (void)getImagePropertiesWithIndex:(int)index;
- (void)getCommentCountWithIndex:(int)index;
- (void)getFeedUntil:(NSString *)until;
- (void)likePost:(NSString *)postId completion:(void (^)(BOOL success))completionBlock;
- (void)unLikePost:(NSString *)postId completion:(void (^)(BOOL success))completionBlock;
- (void)generatePostWithDictionary:(NSDictionary *)dict;
- (BOOL) checkForPermission:(NSString *)permission;
- (void)addComment:(NSString *)comment withID:(NSString *)postID;
- (void)getCommentsWithCursor:(NSString *)cursor objectID:(NSString *)iD completion:(void (^)(NSError *resultingError, id comments))completionBlock;
- (void)getMoreImageInfoWithID:(NSString *)pid completion:(void (^)(id results))completionBlock;
- (void)getMorePostInfoWithID:(NSString *)ID completion:(void (^)(id results))completionBlock;
@property (nonatomic, strong) void(^retry)(BOOL);
@property (nonatomic, weak) id <FacebookManagerDelegate> fbDelegate;
@property (nonatomic) int load;
@end
