//
//  InstagramManager.m
//  EasyShare
//
//  Created by Benjamin Hoover on 8/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "InstagramManager.h"
#import "LoginWebView.h"
#import "AppDelegate.h"
#import "Enums.h"
#import "Downloader.h"
#import "Post.h"
#import "WebViewController.h"
#define appDelegate [[UIApplication sharedApplication]delegate]
@implementation InstagramManager
- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        
        for (UIView *view in [rootViewController.view subviews])
        {
            id subViewController = [view nextResponder];
            if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
            {
                return [self topViewControllerWithRootViewController:subViewController];
            }
        }
        return rootViewController;
    }
}
- (void)authenticate {
    UIViewController *vc = [self topViewController];
    LoginWebView *webView = [vc.storyboard instantiateViewControllerWithIdentifier:@"LoginWebView"];
    webView.delegate = self;
    [vc presentViewController:webView animated:YES completion:^{
        [webView loadWithURL:@"https://instagram.com/oauth/authorize/?client_id=REDACTED&redirect_uri=https://127.0.0.1&response_type=token&scope=comments+likes" ofType:Instagram andTitle:@"Login to Instagram"];
    }];
    
}//add login failed code a cola
- (void)loginDidSucceed {
    self.authenticationCompletion(TRUE);
}
- (void)loginDidFail {
    self.authenticationCompletion(FALSE);
}
- (id)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}
- (void)handleInstagramError:(NSDictionary *)error {
    if ([[error objectForKey:@"error_message"]isEqualToString:@"The \"access_token\" provided is invalid."]) {
        self.alert = [[UIAlertView alloc]initWithTitle:@"Instagram Error" message:@"Your login session has expired. Would you like to relogin?" delegate:self cancelButtonTitle:@"Skip Network" otherButtonTitles:@"Relogin", nil];
        [self.alert show];
    } else {
        self.alert = [[UIAlertView alloc]initWithTitle:@"Instagram Error" message:[error objectForKey:@"error_message"] delegate:self cancelButtonTitle:@"Skip Network" otherButtonTitles:@"Retry", nil];
   
        [self.alert show];
    }
}
- (void)handleNSError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:error.localizedDescription delegate:self cancelButtonTitle:@"Skip Network" otherButtonTitles:@"Retry", nil];
    [alert show];
}
- (void)handleUnknownError {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Instagram Error!" message:@"An unknown error occoured!" delegate:self cancelButtonTitle:@"Skip Network" otherButtonTitles:@"Retry", nil];
    [alert show];
}
- (void)likePost:(NSString *)ID WithCompletion:(void(^)(BOOL success))completionBlock {
    Downloader *download = [[Downloader alloc]init];
    NSString *request = [[NSString alloc]initWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@",ID, self.accessToken];
    __weak InstagramManager *self_ = self;
    self.authenticationCompletion = ^(BOOL success) {
        if (success == TRUE) {
            [self_ likePost:ID WithCompletion:completionBlock];
        } else {
            completionBlock(FALSE);
        }
    };
    [download postWithURL:request completion:^(id results, NSError *error){
        if (error) {
            [self handleNSError:error];
        } else {
            if ([results isKindOfClass:[NSDictionary class]] && [[results objectForKey:@"meta"]objectForKey:@"code"]) {
                if (![[[results objectForKey:@"meta"]objectForKey:@"code"]isEqual:@200]) {
                    [self handleInstagramError:[results objectForKey:@"meta"]];
                } else {
                    completionBlock(TRUE);
                }
                NSLog(@"%@",[[results objectForKey:@"meta"]objectForKey:@"code"]);
            } else {
                [self handleUnknownError];
            }
        }
    }];
}
- (void)unLikePost:(NSString *)ID WithCompletion:(void(^)(BOOL success))completionBlock {
    Downloader *download = [[Downloader alloc]init];
    NSString *request = [[NSString alloc]initWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@",ID, self.accessToken];
    __weak InstagramManager *self_ = self;
    self.authenticationCompletion = ^(BOOL success) {
        if (success == TRUE) {
            [self_ unLikePost:ID WithCompletion:completionBlock];
        } else {
            completionBlock(FALSE);
        }
    };
    [download deleteWithURL:request completion:^(id results, NSError *error){
        if (error) {
            [self handleNSError:error];
        } else {
            if ([results isKindOfClass:[NSDictionary class]] && [[results objectForKey:@"meta"]objectForKey:@"code"]) {
                if (![[[results objectForKey:@"meta"]objectForKey:@"code"]isEqual:@200]) {
                    [self handleInstagramError:[results objectForKey:@"meta"]];
                } else {
                    completionBlock(TRUE);
                }
            } else {
                [self handleUnknownError];
            }
       }
    }];
    
}
- (void)getFeedWithTime:(NSInteger)time Completion:(void (^)(NSMutableArray *result))completionBlock{
    Downloader *download = [[Downloader alloc]init];
    __weak InstagramManager *self_ = self;
    self.authenticationCompletion = ^(BOOL success){
        if (success == TRUE) {
            [self_ getFeedWithTime:time Completion:completionBlock];
        } else {
            completionBlock(nil);
        }    
    };
    if (self.accessToken != nil) {
        NSString *downloadURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?count=20&access_token=%@",self.accessToken];
        NSLog(@"%@",downloadURL);
        [download downloadWithURL:downloadURL toJSON:TRUE completion:^(id results, NSError *error){
            if (error) {
                NSLog(@"%@",results);
                [self handleNSError:error];
            } else {
                if ([results isKindOfClass:[NSMutableDictionary class]] && [[results objectForKey:@"meta"]objectForKey:@"code"]){
                    
                    if (![[[results objectForKey:@"meta"]objectForKey:@"code"]isEqual:@200]) {
                        [self handleInstagramError:[results objectForKey:@"meta"]];
                    } else {
                        NSMutableArray *arrayOfPosts = [[NSMutableArray alloc]init];
                        NSArray *data = [results objectForKey:@"data"];
                        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop){
                            Post *cellPost;
                            NSDictionary *thePost = [data objectAtIndex:idx];
                            if (![thePost isEqual:[NSNull null]]) {
                                cellPost = [self generatePostWithDictionary:thePost index:idx];
                                if ([cellPost.time timeIntervalSince1970] < time) {
                                    *stop = TRUE;
                                } else {
                                 [arrayOfPosts addObject:cellPost];
                                }
                            }
                            
                           
                        }];
                        completionBlock(arrayOfPosts);
                    }
                    
                } else {
                    [self handleUnknownError];
                }
            }
            
        }];
    } else {
        [self authenticate];
    }
    
}

- (void)getCommentsForPostID:(NSString *)objectID WithCompletion:(void(^)(NSMutableArray *comments))completionBlock {
    __weak InstagramManager *self_ = self;
    self.authenticationCompletion = ^(BOOL success){
        if (success == TRUE) {
            [self_ getCommentsForPostID:objectID WithCompletion:completionBlock];
        } else {
             completionBlock(nil);
        }
       
    };
    if (self.accessToken) {
        NSString *query = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/comments?access_token=%@",objectID,self.accessToken];
        Downloader *download = [[Downloader alloc]init];
        [download downloadWithURL:query toJSON:TRUE completion:^(id results, NSError *error){
            if (error) {
                [self handleNSError:error];
            } else if ([results isKindOfClass:[NSMutableDictionary class]] && [[results objectForKey:@"meta"]objectForKey:@"code"]){
                
                if (![[[results objectForKey:@"meta"]objectForKey:@"code"]isEqual:@200]){
                    [self handleInstagramError:[results objectForKey:@"meta"]];
                } else {
                    NSMutableArray *query = [results objectForKey:@"data"];
                    completionBlock(query);
                }
            } else {
                [self handleUnknownError];
            }
        }];
    } else {
        [self authenticate];
    }
}
- (id)safeGetObject:(id)obj key:(NSString *)theKey {
    id result;
    if (![obj isEqual:[NSNull null]]) {
        result = [obj objectForKey:theKey];
    } else {
        
    }
    return result;
}
- (Post *)generatePostWithDictionary:(NSDictionary *)dictionary index:(NSInteger)itemIndex {

    Post *info = [[Post alloc]init];
    info.network = Instagram;
    info.message = [self safeGetObject:[self safeGetObject:dictionary key:@"caption"]key:@"text"];
    info.caption = info.message;
    if ([dictionary objectForKey:@"videos"]) {
        info.type = Video;
        info.imageUrl = [[[dictionary objectForKey:@"videos"]objectForKey:@"standard_resolution"]objectForKey:@"url"];
    } else {
        info.type = Photo;
    }
    NSTimeInterval secondsSince1970 = [[dictionary objectForKey:@"created_time"]doubleValue];
    info.time = [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
    NSNumber *resultheight = [[[dictionary objectForKey:@"images"]objectForKey:@"standard_resolution"]objectForKey:@"height"];
    NSNumber *resultwidth = [[[dictionary objectForKey:@"images"]objectForKey:@"standard_resolution"]objectForKey:@"width"];
    if (!resultheight || !resultwidth) {
        info.imageheight = 292;
    } else {
        double percent = 0;
        if ([resultwidth intValue] != 0) {
            percent = 292/[resultwidth doubleValue];
        }
        info.imageheight = percent * [resultheight intValue];
    }
    info.url = [[dictionary objectForKey:@"user"]objectForKey:@"profile_picture"];
    info.fullURL = [[[dictionary objectForKey:@"images"]objectForKey:@"standard_resolution"]objectForKey:@"url"];
    info.author = [[dictionary objectForKey:@"user"]objectForKey:@"full_name"];
    info.authorid = [[dictionary objectForKey:@"user"]objectForKey:@"username"];
    NSLog(@"%@",info.authorid);
    info.likeCount = [NSString stringWithFormat:@"%@",[[dictionary objectForKey:@"likes"]objectForKey:@"count"]];
    info.commentCount = [NSString stringWithFormat:@"%@",[[dictionary objectForKey:@"comments"]objectForKey:@"count"]];
    info.comments = [[dictionary objectForKey:@"comments"]objectForKey:@"data"];
    NSLog(@"%@",info.comments);
    info.userLikes = [[dictionary objectForKey:@"user_has_liked"]boolValue];
    info.index = itemIndex;
    info.story = FALSE;
    info.objectId = [dictionary objectForKey:@"id"];
 

    
    return info;
}
- (void)goToProfile:(NSString *)profileID viewController:(UIViewController *)vc {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@",profileID]];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else if (vc){
        WebViewController *webView = [vc.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webView.theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://instagram.com/%@",profileID]];
        [vc.navigationController pushViewController:webView animated:YES];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"test");
    if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Retry"]) {
        self.authenticationCompletion(TRUE);
    } else if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Relogin"]) {
        [self authenticate];
    } else {
        self.authenticationCompletion(FALSE);
    }
}
- (void)dealloc {
    NSLog(@"dealloc");
}
- (void)loginSuccess: (NSNotification *)notification {
    [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
- (NSString *)accessToken {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"InstagramAccessToken"]) {
        return [[NSUserDefaults standardUserDefaults]objectForKey:@"InstagramAccessToken"];
    } else {
        return nil;
    }
    
}

@end
