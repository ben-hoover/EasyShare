//
//  TwitterManager.m
//  EasyShare
//
//  Created by Benjamin Hoover on 8/21/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "TwitterManager.h"
#import "Post.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "WebViewController.h"
#define Delegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])
@implementation TwitterManager
- (void)authenticateWithCompletion:(void(^)(ACAccount *))completion {
    self.authCompletion = completion;
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount *account = [accountStore accountWithIdentifier:[[NSUserDefaults standardUserDefaults]stringForKey:@"twitterAccountID"]];
    if (account) {

             self.authCompletion(account);
             
    } else {
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        NSArray *accounts = [accountStore accountsWithAccountType:accountType];
        if (accounts.count > 0 && granted) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Please Select an account to use with Easy Share" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            for (ACAccount *account in accounts) {
                [alert addButtonWithTitle:account.username];
            }
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:FALSE];
        } else {
            UIAlertView *alert;
            if (error.code == 6) {
                alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"In order to use Twitter you must setup a Twitter account in settings first. Please go to the Settings App -> Twitter and login, then try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            } else {
                alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Access to twitter denied" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            }
            
            NSLog(@"%@",error.localizedDescription);
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        }
    
    }];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    if (buttonIndex != 0 && accounts.count > 0 && ![[NSUserDefaults standardUserDefaults]objectForKey:@"twitterAccountID"]) {
        ACAccount *account = [accounts objectAtIndex:buttonIndex-1];
        [[NSUserDefaults standardUserDefaults]setObject:account.identifier forKey:@"twitterAccountID"];
        self.authCompletion([accounts objectAtIndex:buttonIndex - 1]);
    
    } else {
        
        
    
        self.authCompletion(nil);
    }
}
- (void)getFeedWithCompletion:(void(^)(NSArray *result))completionBlock {
    void(^authBlock)(ACAccount *) = ^(ACAccount *twitterAccount){
        

        // Check if the users has setup at least one Twitter account
        if (twitterAccount) {
            SLRequest *timelineRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"] parameters:[NSDictionary dictionaryWithObject:@"50" forKey:@"count"]];
            [timelineRequest setAccount:twitterAccount];
          
            [timelineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
                if ([urlResponse statusCode] == 429) {
                    NSLog(@"limit reached");
                    completionBlock(nil);
                } else if (error) {
                    completionBlock(nil);
                  //  NSLog(@"%@",error.localizedDescription);
                } else {
                    NSLog(@"%@",[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding]);
                    NSArray* json = [NSJSONSerialization
                                          JSONObjectWithData:responseData //1
                                          options:nil
                                          error:&error];
                    
                    
                    NSMutableArray *thePostArray = [[NSMutableArray alloc]init];
                    [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                        NSDateFormatter *formatDate = [[NSDateFormatter alloc]init];
                        [formatDate setDateFormat:@"E MMM d H:m:s Z yyyy"];
                        Post *cellPost = [self createPostWithDict:[json objectAtIndex:idx] dateFormatter:formatDate];
                        cellPost.index = idx;
                        [thePostArray addObject:cellPost];
                    }];
                    completionBlock([NSArray arrayWithArray:thePostArray]);
                }
             
            }];
        } else {
            completionBlock(nil);
        }
    };
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];

    //if (accounts.count == 0) {
        [self authenticateWithCompletion:authBlock];
   // } else {
    //    authBlock([accounts objectAtIndex:0]);
   // }

}
- (Post *)createPostWithDict:(NSDictionary *)postDict dateFormatter:(NSDateFormatter *)formatter {
    Post *thePost = [[Post alloc]init];
    thePost.network = Twitter;
    thePost.author = [self safeGetObjectForKey:@"name" dict:[self safeGetObjectForKey:@"user" dict:postDict]];
    thePost.altUserName = [NSString stringWithFormat:@"@%@",[self safeGetObjectForKey:@"screen_name" dict:[self safeGetObjectForKey:@"user" dict:postDict]]];
    thePost.message = [self safeGetObjectForKey:@"text" dict:postDict];
    thePost.authorid = [self safeGetObjectForKey:@"screen_name" dict:[self safeGetObjectForKey:@"user" dict:postDict]];
    NSLog(@"%@",thePost.authorid);
    thePost.objectId = [self safeGetObjectForKey:@"id_str" dict:postDict];
    thePost.likeCount = [NSString stringWithFormat:@"%@",[self safeGetObjectForKey:@"favorite_count" dict:postDict]];
    thePost.shareCount = [NSString stringWithFormat:@"%@",[self safeGetObjectForKey:@"retweet_count" dict:postDict]];
    thePost.userLikes = [[postDict objectForKey:@"favorited"]boolValue];
    thePost.type = Status;
    thePost.url = [self safeGetObjectForKey:@"profile_image_url" dict:[self safeGetObjectForKey:@"user" dict:postDict]];
    
    
    thePost.time = [formatter dateFromString:[self safeGetObjectForKey:@"created_at" dict:postDict]];
    return thePost;
}
- (id)safeGetObjectForKey:(NSString *)key dict:(NSDictionary *)dict {
    if ([[dict objectForKey:key]isEqual:[NSNull null]]) {
        return nil;
    } else {
        return [dict objectForKey:key];
    }
}
- (void)goToProfile:(NSString *)profileID viewController:(UIViewController *)vc {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",profileID]];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else if (vc){
        WebViewController *webView = [vc.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webView.theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@",profileID]];
        [vc.navigationController pushViewController:webView animated:YES];
    }
    
}
@end
