//
//  InstagramManager.h
//  EasyShare
//
//  Created by Benjamin Hoover on 8/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "LoginWebView.h"
@interface InstagramManager : NSObject <UIAlertViewDelegate, LoginWebViewDelegate>
@property (nonatomic, strong)NSString *accessToken;
//@property (nonatomic, strong)void (^completion)(id result);
@property (nonatomic, strong)void (^authenticationCompletion)(BOOL success);
@property (nonatomic, strong)UIAlertView *alert;

- (void)likePost:(NSString *)ID WithCompletion:(void(^)(BOOL success))completionBlock;
- (void)authenticate;
- (void)getFeedWithTime:(NSInteger)time Completion:(void (^)(NSMutableArray *result))completionBlock;
- (void)getCommentsForPostID:(NSString *)objectID WithCompletion:(void(^)(NSMutableArray *comments))completionBlock;
- (void)unLikePost:(NSString *)ID WithCompletion:(void(^)(BOOL success))completionBlock;
- (Post *)generatePostWithDictionary:(NSDictionary *)dictionary;
- (void)goToProfile:(NSString *)profileID viewController:(UIViewController *)vc;
@end
