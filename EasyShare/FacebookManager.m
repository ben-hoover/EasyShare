
//
//  FacebookManager.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/11/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "FacebookManager.h"
#import "Post.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "WebViewController.h"
@implementation FacebookManager
#pragma mark Feed
#define Image_Width 292
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Retry"]) {
        self.retry(TRUE);
    } else {
        self.retry(FALSE);
    }
}
- (void)handleNSError:(NSError *)error {
    NSDictionary *erroruserinfo = [[NSDictionary alloc]initWithDictionary:error.userInfo];
    if ([[erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]isKindOfClass:[NSError class]]) {
        NSLog(@"%@",[erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"]);
        NSLog(@"is an error");
        NSError *innererror = [erroruserinfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Error" message:innererror.localizedDescription delegate:self cancelButtonTitle:@"Skip Network"otherButtonTitles:@"Retry", nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Retry", nil];
        [alert show];
    }

}
- (void)goToProfile:(NSString *)profileID viewController:(UIViewController *)vc {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@",profileID]];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
         [[UIApplication sharedApplication] openURL:url];
    } else if (vc){
        WebViewController *webView = [vc.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webView.theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://facebook.com/%@",profileID]];
        [vc.navigationController pushViewController:webView animated:YES];
    }
   
}
- (void)getFeedWithUntil:(NSInteger)time Completion:(void (^)(NSMutableArray *result))completionBlock {
    __weak FacebookManager *self_ = self;
    self.retry = ^(BOOL retry) {
        if (retry == TRUE) {
            [self_ getFeedWithUntil:time Completion:completionBlock];
        } else {
            completionBlock(nil);
        }
    };
    results = [[NSMutableArray alloc]init];
    completedDownloads = 0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString*query = [NSString stringWithFormat:@"{\"query1\" : \"SELECT post_id, actor_id, target_id, message, description, type,like_info,attachment,comment_info,created_time,parent_post_id,message_tags, share_count FROM stream WHERE filter_key IN (SELECT filter_key FROM stream_filter WHERE uid=me() AND type='newsfeed') AND is_hidden = 0 AND created_time >= %i ORDER BY created_time desc LIMIT 200\", \"query2\" : \"SELECT uid, name FROM user WHERE uid in (SELECT actor_id FROM #query1)\", \"query3\" : \"SELECT page_id,name FROM page WHERE page_id in (SELECT actor_id FROM #query1)\"}",time];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:query,@"q", nil];
    FBRequestConnection *request = [[FBRequestConnection alloc]initWithTimeout:30];
    [request addRequest:[FBRequest requestWithGraphPath:@"fql" parameters:params HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

    
    if (error) {
        NSLog(@"%@",connection.urlRequest.URL);
        [self handleNSError:error];
     } else {
        NSLog(@"%@",connection.urlRequest.URL);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([result isKindOfClass:[NSDictionary class]] && [[result objectForKey:@"data"]isKindOfClass:[NSArray class]]) {
            NSArray *requests = [result objectForKey:@"data"];
            
           
                postData = [[requests objectAtIndex:0]objectForKey:@"fql_result_set"];
                userIDData = [[requests objectAtIndex:1]objectForKey:@"fql_result_set"];
                pageIDData = [[requests objectAtIndex:2]objectForKey:@"fql_result_set"];
                
     
            for (int i = 0; i < postData.count; i++) {
                Post *cellpost;
                
                NSDictionary *postDictionary = [postData objectAtIndex:i];
                cellpost = [self getPostWithDictionary:postDictionary];
                cellpost.index = i;
                if ([cellpost.time timeIntervalSince1970] < time) {
                    break;
                } else {
                    [results addObject:cellpost];
                }
                
            }
            while (results.count % 200 == 0) {
                [self getMoreFeedWithFrom:[[(Post *)results.lastObject time]timeIntervalSince1970] to:time array:results];
            }
            
            
            
        completionBlock(results);
        }
        
        }
    }];
    [request start];
}

-(void)getMoreFeedWithFrom:(NSInteger)from to:(NSInteger)to array:(NSMutableArray*)array {
    NSString *path = [NSString stringWithFormat:@"{\"query1\" : \"SELECT post_id, actor_id, target_id, message, description, type,like_info,attachment,comment_info,created_time,parent_post_id,message_tags, share_count FROM stream WHERE filter_key IN (SELECT filter_key FROM stream_filter WHERE uid=me() AND type='newsfeed') AND is_hidden = 0 AND created_time < %i AND created_time >= %i ORDER BY created_time desc LIMIT 200\", \"query2\" : \"SELECT uid, name FROM user WHERE uid in (SELECT actor_id FROM #query1)\", \"query3\" : \"SELECT page_id,name FROM page WHERE page_id in (SELECT actor_id FROM #query1)\"}",from,to];
    [FBRequestConnection startWithGraphPath:path completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        NSArray *requests = [result objectForKey:@"data"];
        
        
        postData = [[requests objectAtIndex:0]objectForKey:@"fql_result_set"];
        userIDData = [[requests objectAtIndex:1]objectForKey:@"fql_result_set"];
        pageIDData = [[requests objectAtIndex:2]objectForKey:@"fql_result_set"];
        
        for (int i = 0; i < postData.count; i++) {
            Post *cellpost;
            
            NSDictionary *postDictionary = [postData objectAtIndex:i];
            cellpost = [self getPostWithDictionary:postDictionary];
            cellpost.index = i;
            if ([cellpost.time timeIntervalSince1970] < to) {
                break;
            } else {
                [results addObject:cellpost];
            }
            
        }
    }];
    
}
- (id)safeGetObjectAtIndex:(NSInteger)index array:(NSArray *)array {
    if (array.count > index) {
        return [array objectAtIndex:index];
    } else {
        return nil;
    }
}
- (Post *)getPostWithDictionary:(NSDictionary *)postDictionary {
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    Post *cellpost = [[Post alloc]init];
    cellpost.type = Status;
    if ([postDictionary objectForKey:@"type"] != [NSNull null]) {
        cellpost.typeID = [[postDictionary objectForKey:@"type"]intValue];
    }
    
    cellpost.objectId = [postDictionary objectForKey:@"post_id"];
    cellpost.authorid = [postDictionary objectForKey:@"actor_id"];
    cellpost.author = [self getNameForID:cellpost.authorid];
    
    NSTimeInterval time = [[postDictionary objectForKey:@"created_time"]doubleValue];
    cellpost.time = [NSDate dateWithTimeIntervalSince1970:time];
    
    
    NSLog(@"%@",[postDictionary objectForKey:@"type"]);
    if ([postDictionary objectForKey:@"message"] && ![[postDictionary objectForKey:@"message"]isEqualToString:@""]) {
        cellpost.message = [postDictionary objectForKey:@"message"];
        
    } else if ([postDictionary objectForKey:@"description"] && ![[postDictionary objectForKey:@"description"]isEqual:[NSNull null]] && ![[postDictionary objectForKey:@"description"]isEqualToString:@""]) {
        cellpost.message = [postDictionary objectForKey:@"description"];
        cellpost.story = TRUE;
    } else if ([postDictionary objectForKey:@"name"]){
        cellpost.message = [postDictionary objectForKey:@"name"];
    } else {
        cellpost.message = @"";
    }
    cellpost.likeCount = [NSString stringWithFormat:@"%@",[[postDictionary objectForKey:@"like_info"]objectForKey:@"like_count"]];
    if ([[postDictionary objectForKey:@"can_like"]isEqualToString:@"false"]) {
        cellpost.canLike = FALSE;
    } else {
        cellpost.canLike = TRUE;
    }
    cellpost.userLikes = [[[postDictionary objectForKey:@"like_info"]objectForKey:@"user_likes"]boolValue];
    cellpost.canComment = [[[postDictionary objectForKey:@"comment_info"]objectForKey:@"can_comment"]boolValue];
    cellpost.commentCount = [NSString stringWithFormat:@"%@",[[postDictionary objectForKey:@"comment_info"]objectForKey:@"comment_count"]];
    cellpost.shareCount = [NSString stringWithFormat:@"%@",[postDictionary objectForKey:@"share_count"]];
    cellpost.network = Facebook;
    
    if ([[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"type"]isEqualToString:@"photo"]) {
        cellpost.type = Photo;
        double percent = 0;
        cellpost.photo_objectid = [NSString stringWithFormat:@"%@",[[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"photo"]objectForKey:@"fbid"]];
        int width = [[[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"photo"]objectForKey:@"width"]intValue];
        
        int height = [[[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"photo"]objectForKey:@"height"]intValue];
        
        if (width != 0) {
            percent = 292.0/width;
        }
        cellpost.imageheight = percent * height;
        
        
        if ([[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"properties"]]objectForKey:@"text"]) {
            cellpost.isAShare = TRUE;
            
            
            Post *originalPost = [[Post alloc]init];
            originalPost.author = [[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"properties"]]objectForKey:@"text"];
            originalPost.network = Facebook;
            if ([[postDictionary objectForKey:@"attachment"]objectForKey:@"caption"] && ![[[postDictionary objectForKey:@"attachment"]objectForKey:@"caption"]isEqualToString:@""]) {
                originalPost.message = [[postDictionary objectForKey:@"attachment"]objectForKey:@"caption"];
                originalPost.caption = originalPost.message;
            }
            originalPost.photo_objectid = cellpost.photo_objectid;
            originalPost.objectId = originalPost.photo_objectid;
            originalPost.type = cellpost.type;
            originalPost.typeID = cellpost.typeID;
            NSString *theID = [[postDictionary objectForKey:@"attachment"]objectForKey:@"fb_object_id"];
            NSRange authorID = [theID rangeOfString:@"_"];
            if (authorID.location != NSNotFound) {
                originalPost.authorid = [theID substringToIndex:authorID.location];
            }
            originalPost.imageheight = cellpost.imageheight;
            
            [delegate.postCache setObject:originalPost forKey:originalPost.objectId];
        } else {
            cellpost.isAShare = FALSE;
            if ([[postDictionary objectForKey:@"attachment"]objectForKey:@"caption"] && ![[[postDictionary objectForKey:@"attachment"]objectForKey:@"caption"]isEqualToString:@""]) {
                cellpost.caption = [[postDictionary objectForKey:@"attachment"]objectForKey:@"caption"];
            } else {
                cellpost.caption = cellpost.message;
            }
            
        }
        
        
        
    } else if ([[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"type"]isEqualToString:@"link"]) {
        cellpost.type = Link;
        
        NSRange posts = [[[postDictionary objectForKey:@"attachment"]objectForKey:@"href"] rangeOfString:@"/posts/"];
        cellpost.urlTitle = [[postDictionary objectForKey:@"attachment"]objectForKey:@"name"];
        cellpost.imageUrl = [[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"src"];
        if ([[[postDictionary objectForKey:@"attachment"]objectForKey:@"href"] rangeOfString:@"://www.facebook.com/"].location != NSNotFound && posts.location != NSNotFound) {
            cellpost.fullURL = @"shared_post";
            cellpost.url = @"Post";
            cellpost.photo_objectid = [[[postDictionary objectForKey:@"attachment"]objectForKey:@"href"] substringFromIndex:posts.location+7];
            
        } else {
            cellpost.fullURL = [[postDictionary objectForKey:@"attachment"]objectForKey:@"href"];
            cellpost.url = [[postDictionary objectForKey:@"attachment"]objectForKey:@"caption"];
        }
        
    } else if (cellpost.typeID == 245 || cellpost.typeID == 257) {
        cellpost.type = Link;
        NSRange endID = [cellpost.objectId rangeOfString:@"_"];
        
        cellpost.photo_objectid = [cellpost.objectId substringFromIndex:endID.location + 1];
        cellpost.type = Link;
        cellpost.fullURL = @"shared_post";
        cellpost.urlTitle = @"Facebook";
        Post *originalPost = [[Post alloc]init];
        originalPost.likeCount = cellpost.likeCount;
        cellpost.likeCount = nil;
        originalPost.commentCount =cellpost.commentCount;
        cellpost.commentCount = nil;
        originalPost.canComment = cellpost.canComment;
        originalPost.canLike = cellpost.canLike;
        originalPost.userLikes = cellpost.userLikes;
  
        
        cellpost.canLike = FALSE;
        cellpost.canComment = FALSE;
        
        originalPost.objectId = cellpost.photo_objectid;
        originalPost.photo_objectid = originalPost.objectId;
        originalPost.type = cellpost.type;
        if ([cellpost.message rangeOfString:@"status"].location != NSNotFound) {
            cellpost.url = @"Status";
        } else if ([cellpost.message rangeOfString:@"photo"].location != NSNotFound) {
            cellpost.url = @"Photo";
        } else if ([cellpost.message rangeOfString:@"video"].location != NSNotFound) {
            cellpost.url = @"Video";
        }
        
        [delegate.postCache setObject:originalPost forKey:originalPost.objectId];
        
    } else if ([[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"type"]isEqualToString:@"video"]) {
        if ([[[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"video"]objectForKey:@"source_url"]rangeOfString:@"https://fbcdn-video"].location != NSNotFound) {
            cellpost.type = Video;
            cellpost.url = [[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"video"]objectForKey:@"source_url"];
            cellpost.imageUrl = [[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"src"];
            cellpost.imageheight = 200.0;
            
        } else {
            cellpost.type = Link;
            cellpost.url = [[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"video"]objectForKey:@"source_url"];
            cellpost.fullURL = [[[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"video"]objectForKey:@"source_url"];
            cellpost.urlTitle = [[postDictionary objectForKey:@"attachment"]objectForKey:@"name"];
            cellpost.imageUrl = [[self safeGetObjectAtIndex:0 array:[[postDictionary objectForKey:@"attachment"]objectForKey:@"media"]]objectForKey:@"src"];
            cellpost.imageheight = 200.0;
            
        }
        
    }
    return cellpost;
}

- (NSString *)getNameForID:(id)userID {
    userID = [NSString stringWithFormat:@"%@",userID];
    NSString *result;
    NSDictionary *post;
    result = [IDCache objectForKey:userID];
    
    if (result) {
        return result;
    } else {
        for (post in pageIDData) {
            if ([[NSString stringWithFormat:@"%@",[post objectForKey:@"page_id"]]isEqualToString:userID] && [post objectForKey:@"name"]) {
                [IDCache setValue:[post objectForKey:@"name"] forKey:[post objectForKey:@"page_id"]];
                return [post objectForKey:@"name"];
            }
        }
        
        for (post in userIDData) {
            if ([[NSString stringWithFormat:@"%@",[post objectForKey:@"uid"]]isEqualToString:userID] && [post objectForKey:@"name"]) {
                [IDCache setValue:[post objectForKey:@"name"] forKey:[post objectForKey:@"uid"]];
                return [post objectForKey:@"name"];
            }
        }
        
    }
    return @"";
}
- (void)getMoreImageInfoWithID:(NSString *)pid completion:(void (^)(id results))completionBlock {
    NSDictionary *parameterz = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"SELECT comment_info, like_info, created FROM  photo  WHERE object_id = %@",pid],@"q", nil];
    
    [FBRequestConnection startWithGraphPath:@"fql" parameters:parameterz HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, NSError *error, id result){
        NSLog(@"%@",connection.urlRequest.URL);
        if (error) {
            completionBlock(error);
        } else {
            completionBlock(result);
        }
        
    }];
}
- (void)getMorePostInfoWithID:(NSString *)ID completion:(void (^)(id results))completionBlock {
    NSString *path = [NSString stringWithFormat:@"/%@",ID];
    NSLog(@"%@",path);
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    __block Post *thePost = [delegate.postCache objectForKey:ID];
    
    if (thePost.imageheight && thePost.time && thePost.message && thePost.objectId && thePost.photo_objectid && thePost.author && thePost.authorid && thePost.caption) {
        thePost = [delegate.postCache objectForKey:ID];
        completionBlock(thePost);
    } else {
        
        [FBRequestConnection startWithGraphPath:path parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
            if (!error) {
                if (!thePost) {
                    thePost = [[Post alloc]init];
                }
                
                if ([result objectForKey:@"images"]) {
                    thePost.type = Photo;
                    NSNumber *resultwidth = [result objectForKey:@"width"];
                    NSNumber *resultheight = [result objectForKey:@"height"];
                    if (!resultheight || !resultwidth) {
                        thePost.imageheight = 200;
                    } else {
                        double percent = 0;
                        if ([resultwidth intValue] != 0) {
                            percent = 292/[resultwidth doubleValue];
                        }
                        thePost.imageheight = percent * [resultheight intValue];
                    }
                } else if ([result objectForKey:@"embed_html"]){
                    thePost.type = Video;
                    thePost.url = [result objectForKey:@"source"];
                    thePost.imageUrl = [result objectForKey:@"picture"];
                    thePost.imageheight = 200;
                } else {
                    thePost.type = Status;
                }
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                NSDate *postDate;
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
                if ([result objectForKey:@"created_time"]) {
                    postDate = [formatter dateFromString:[result objectForKey:@"created_time"]];
                } else {
                    postDate = [formatter dateFromString:[result objectForKey:@"updated_time"]];
                }
                thePost.time = postDate;
                if ([result objectForKey:@"message"]) {
                    thePost.message = [result objectForKey:@"message"];
                } else if ([result objectForKey:@"story"]) {
                    thePost.message = [result objectForKey:@"story"];
                    thePost.story = TRUE;
                } else if ([result objectForKey:@"name"]) {
                    thePost.message = [result objectForKey:@"name"];
                    
                } else {
                    thePost.message = @"";
                }
                thePost.objectId = [result objectForKey:@"id"];
                thePost.photo_objectid = thePost.objectId;
                thePost.author = [[result objectForKey:@"from"]objectForKey:@"name"];
                thePost.authorid = [[result objectForKey:@"from"]objectForKey:@"id"];
                thePost.caption = thePost.message;
                thePost.network = Facebook;
                
                completionBlock(thePost);
                
                
                
            } else {
                NSLog(@"%@",error);
                completionBlock(error);
            }
        }];
    }
}
/*
 - (void) getFeedUntil:(NSString *)until {
 
 results = [[NSMutableArray alloc]init];
 completedDownloads = 0;
 
 NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObject:@"50"] forKeys:[NSArray arrayWithObject:@"limit"]];
 if (until) {
 // [params setObject:until forKey:@"until"];
 }
 __block NSArray *data = [[NSArray alloc]init];
 [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
 [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
 if (error) {
 [self.fbDelegate failedToGetFeed:error];
 } else {
 
 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
 //  NSLog(@"result %@",result);
 //  NSLog(@"%@, %@",error, error.localizedDescription);
 if ([result isKindOfClass:[NSArray class]]) {
 
 } else if ([result isKindOfClass:[NSDictionary class]]) {
 
 data = [result objectForKey:@"data"];
 }
 
 NSDictionary *post = [[NSDictionary alloc]init];
 NSMutableString *next = [[result objectForKey:@"paging"]objectForKey:@"next"];
 
 NSRange rangeOfTime = [next rangeOfString:@"until="];
 NSLog(@"%@, %i",next,rangeOfTime.location);
 if (rangeOfTime.location != NSNotFound) {
 nextPage = [next substringFromIndex:rangeOfTime.location+6];
 NSLog(@"%@",nextPage);
 }
 
 NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
 [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
 for (int i= 0; i < data.count; i++) {
 post = [data objectAtIndex:i];
 Post *cellpost;
 cellpost = [[Post alloc]init];
 cellpost.index = i;
 cellpost.type = Status;
 cellpost.objectId = [post objectForKey:@"id"];
 NSDictionary *from = [post objectForKey:@"from"];
 cellpost.author = [from objectForKey:@"name"];
 cellpost.authorid = [from objectForKey:@"id"];
 if ([post objectForKey:@"message"]!=nil) {
 cellpost.message = [post objectForKey:@"message"];
 } else if ([post objectForKey:@"story"]!= nil){
 cellpost.message = [post objectForKey:@"story"];
 
 cellpost.story = TRUE;
 } else {
 cellpost.message = @"";
 }
 cellpost.likeCount = [NSString stringWithFormat:@"%@",[[post objectForKey:@"likes"]objectForKey:@"count"]];
 cellpost.shareCount = [NSString stringWithFormat:@"%@",[[post objectForKey:@"shares"]objectForKey:@"count"]];
 NSLog(@"%@",[cellpost.likeCount class]);
 
 
 cellpost.time = [formatter dateFromString:[post objectForKey:@"created_time"]];
 cellpost.comments = [post objectForKey:@"comments"];
 
 cellpost.network = Facebook;
 if (([post objectForKey:@"properties"] || [post objectForKey:@"story_tags"]) && [[post objectForKey:@"type"]isEqualToString:@"photo"]) {
 cellpost.isAShare = TRUE;
 Post *originalPost = [[Post alloc]init];
 cellpost.originalCaption = [post objectForKey:@"caption"];
 cellpost.originalAuthor = [[[post objectForKey:@"properties"]objectAtIndex:0]objectForKey:@"text"];
 NSLog(@"%@",cellpost.originalAuthor);
 
 }
 if ([[post objectForKey:@"type"]isEqualToString:@"photo"] || [[post objectForKey:@"type"]isEqualToString:@"video"]) {
 if ([[post objectForKey:@"type"]isEqualToString:@"video"]) {
 cellpost.type = Video;
 } else {
 cellpost.type = Photo;
 }
 cellpost.photo_objectid = [post objectForKey:@"object_id"];
 
 cellpost.imageUrl = [post objectForKey:@"picture"];
 cellpost.url = [post objectForKey:@"source"];
 //[cellpost startImageDownloadWithObjectId:[post objectForKey:@"object_id"]];
 [results addObject:cellpost];
 [self getImagePropertiesWithIndex:i];
 
 
 } else if ([[post objectForKey:@"type"]isEqualToString:@"link"]) {
 cellpost.type = Link;
 NSString *tempURL = [post objectForKey:@"link"];
 NSRange rangeForHTTP = [tempURL rangeOfString:@"://"];
 if (rangeForHTTP.location != NSNotFound) {
 NSRange searchRange;
 searchRange.location = rangeForHTTP.location + 3;
 searchRange.length = tempURL.length - searchRange.location;
 NSRange endRange = [tempURL rangeOfString:@"/" options:0 range:searchRange];
 NSRange finalRange;
 finalRange.location = rangeForHTTP.location + 3;
 if (endRange.location == NSNotFound) {
 finalRange.length = tempURL.length - rangeForHTTP.location - 3;
 } else {
 finalRange.length = endRange.location - rangeForHTTP.location - 3;
 }
 cellpost.url = [tempURL substringWithRange:finalRange];
 cellpost.fullURL = tempURL;
 
 
 } else {
 cellpost.url = @"";
 }
 
 cellpost.urlTitle = [post objectForKey:@"name"];
 cellpost.imageUrl = [post objectForKey:@"picture"];
 [results addObject:cellpost];
 [self getCommentCountWithIndex:i];
 } else {
 cellpost.type = Status;
 [results addObject:cellpost];
 [self getCommentCountWithIndex:i];
 }
 }
 }
 }];
 }
 - (void)getImagePropertiesWithIndex:(int)index {
 Post *photoPostIndex = [results objectAtIndex:index];
 NSString *graphpath = [NSString stringWithFormat:@"/%@",photoPostIndex.photo_objectid];
 
 [FBRequestConnection startWithGraphPath:graphpath parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
 
 CGFloat width;
 CGFloat height;
 NSString *resultwidth;
 NSString *resultheight;
 //  if () {
 //
 //  }
 if (photoPostIndex.type == Photo) {
 resultwidth = [result objectForKey:@"width"];
 resultheight = [result objectForKey:@"height"];
 
 
 if (!resultheight || !resultwidth) {
 photoPostIndex.imageheight = 200;
 } else {
 width = [resultwidth intValue];
 height = [resultheight intValue];
 
 double percent = 0;
 if (width != 0) {
 percent = 292/width;
 }
 if (error) {
 NSLog(@"%@",error);
 NSLog(@"%@",result);
 }
 if (index == 0) {
 
 }
 photoPostIndex.imageheight = percent * height;
 }
 } else {
 photoPostIndex.imageheight = 275;
 }
 if (!photoPostIndex.originalAuthor) {
 [results replaceObjectAtIndex:index withObject:photoPostIndex];
 [self getCommentCountWithIndex:index];
 } else {
 NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
 [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
 
 
 NSDate *currenttime = [NSDate date];
 NSDate *postDate = [formatter dateFromString:[result objectForKey:@"created_time"]];
 NSTimeInterval timesinceposted = [currenttime timeIntervalSinceDate:postDate];
 
 int time = (float)timesinceposted;
 if (time == 1) {
 photoPostIndex.originalTime = @"1 second ago";
 } else if (time < 60){
 photoPostIndex.originalTime = [NSString stringWithFormat:@"%i seconds ago",time];
 } else if (time >= 60 && time < 120) {
 photoPostIndex.originalTime = @"1 minute ago";
 } else if (time >= 120 && time < 3600) {
 photoPostIndex.originalTime = [NSString stringWithFormat:@"%i minutes ago",time/60];
 } else if (time >= 3600 && time < 7200) { //one hour
 photoPostIndex.originalTime = @"1 hour ago";
 } else if (time >= 7200 && time < 86400) { //greater or equal to two hours and less than one day
 photoPostIndex.originalTime = [NSString stringWithFormat:@"%i hours ago",time/3600]; //time divided by hours
 } else if (time >= 86400 && time < 172800) {
 [formatter setDateFormat:@"HH:mm"];
 [formatter setTimeZone:[NSTimeZone systemTimeZone]];
 photoPostIndex.originalTime = [NSString stringWithFormat:@"Yesterday at %@",[formatter stringFromDate:postDate]];
 }
 
 [self likesAndCommentsForObjectID:photoPostIndex];
 
 }
 
 
 }];
 
 
 }
 - (void)likesAndCommentsForObjectID:(Post *)ID {
 NSString *graphPath = [NSString stringWithFormat:@"/%@/likes?summary=true",ID.photo_objectid];
 NSString *graphPath2 = [NSString stringWithFormat:@"/%@/comments?summary=true",ID.photo_objectid];
 [FBRequestConnection startWithGraphPath:graphPath completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
 NSString *totalCount = [NSString stringWithFormat:@"%@",[[result objectForKey:@"summary"]objectForKey:@"total_count"]];
 ID.originalLikeCount = totalCount;
 [FBRequestConnection startWithGraphPath:graphPath2 completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
 NSString *commentCount = [NSString stringWithFormat:@"%@",[[result objectForKey:@"summary"]objectForKey:@"total_count"]];
 ID.originalCommentCount = commentCount;
 [results replaceObjectAtIndex:ID.index withObject:ID];
 [self getCommentCountWithIndex:ID.index];
 }];
 }];
 }
 */
- (void)getCommentCountWithIndex:(int)index {
    Post *photoPostIndex = [results objectAtIndex:index];
    NSString *graphpath = [NSString stringWithFormat:@"/%@/comments?summary=true",photoPostIndex.objectId];
    [FBRequestConnection startWithGraphPath:graphpath parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        photoPostIndex.commentCount = [[NSString alloc]init];
        photoPostIndex.commentCount= [NSString stringWithFormat:@"%@",[[result objectForKey:@"summary"]objectForKey:@"total_count"]];
        [results replaceObjectAtIndex:index withObject:photoPostIndex];
        ++completedDownloads;
        if (completedDownloads == results.count) {
            [self.fbDelegate feedDataFinishedWithData:results nextPage:nextPage load:self.load];
        }
    }];
}

- (void)getCommentsWithCursor:(NSString *)cursor objectID:(NSString *)iD completion:(void (^)(NSError *resultingError, id comments))completionBlock {
    NSString *path;
    if (cursor) {
        path = [NSString stringWithFormat:@"/%@/comments?after=%@",iD,cursor];
    }else {
        path = [NSString stringWithFormat:@"/%@/comments",iD];
    }
    
    [FBRequestConnection startWithGraphPath:path parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection,id result, NSError *error) {
        completionBlock(error,result);
    }];
    
    
}
- (BOOL)checkForPermission:(NSString *)permission {
    __block BOOL authenticated = FALSE;
    [[FBSession activeSession].permissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        if ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:permission]) {
            authenticated = TRUE;
            *stop = TRUE;
        }
    }];
    return authenticated;
    
    
}
- (void)unLikePost:(NSString *)postId completion:(void (^)(BOOL success))completionBlock {
    NSString *grathPath = [NSString stringWithFormat:@"/%@/likes",postId];
    if ([self checkForPermission:@"publish_actions"]) {
        [FBRequestConnection startWithGraphPath:grathPath parameters:nil HTTPMethod:@"DELETE" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
                completionBlock(FALSE);
            } else {
                NSLog(@"Liked");
                completionBlock(TRUE);
            }
        }];
        
    } else {
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"publish_actions", nil];
        
        [FBSession.activeSession requestNewPublishPermissions:permissions
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session,
                                                                NSError *error) {
                                                if (error) {
                                                    [self handleRequestPermissionError:error];
                                                    completionBlock(FALSE);
                                                } else {
                                                    [FBRequestConnection startWithGraphPath:grathPath parameters:nil HTTPMethod:@"DELETE" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"%@",error);
                                                            completionBlock(FALSE);
                                                        } else {
                                                            NSLog(@"Liked");
                                                            completionBlock(TRUE);
                                                        }
                                                    }];
                                                    
                                                }
                                                // Handle new permissions callback
                                            }];
        
    }
    
    
}

- (void)likePost:(NSString *)postId completion:(void (^)(BOOL success))completionBlock {
    NSString *grathPath = [NSString stringWithFormat:@"/%@/likes",postId];
    if ([self checkForPermission:@"publish_actions"]) {
        [FBRequestConnection startWithGraphPath:grathPath parameters:nil HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
                completionBlock(FALSE);
            } else {
                NSLog(@"Liked");
                completionBlock(TRUE);
            }
        }];
        
    } else {
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"publish_actions", nil];
        
        [FBSession.activeSession requestNewPublishPermissions:permissions
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session,
                                                                NSError *error) {
                                                if (error) {
                                                    [self handleRequestPermissionError:error];
                                                    completionBlock(FALSE);
                                                } else {
                                                    [FBRequestConnection startWithGraphPath:grathPath parameters:nil HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"%@",error);
                                                            completionBlock(FALSE);
                                                        } else {
                                                            NSLog(@"Liked");
                                                            completionBlock(TRUE);
                                                        }
                                                    }];
                                                    
                                                }
                                                // Handle new permissions callback
                                            }];
        
    }
    
    
}
- (void)handleRequestPermissionError:(NSError *)error
{
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                    message:error.fberrorUserMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        if (error.fberrorCategory == FBErrorCategoryUserCancelled){
            // The user has cancelled the request. You can inspect the value and
            // inner error for more context. Here we simply ignore it.
            NSLog(@"User cancelled post permissions.");
        } else {
            NSLog(@"Unexpected error requesting permissions:%@", error);
            [[[UIAlertView alloc] initWithTitle:@"Permission Error"
                                        message:@"Unable to request publish permissions"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }
}
- (void)addComment:(NSString *)comment withID:(NSString *)postID {
    __block NSError *resultError;
    NSString *graphPath = [NSString stringWithFormat:@"/%@/comments",postID];
    NSDictionary *parametersDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:comment,@"message",nil];
    if ([self checkForPermission:@"publish_stream"]) {
        
        [FBRequestConnection startWithGraphPath:graphPath parameters:parametersDictionary HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {
                
                resultError = error;
                
            } else {
                NSLog(@"added comment!");
                
            }
            [self.fbDelegate commentAddDidFinish:resultError];
        }];
    } else {
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"publish_actions", nil];
        
        [FBSession.activeSession requestNewPublishPermissions:permissions
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session,
                                                                NSError *error) {
                                                if (error) {
                                                    resultError = error;
                                                    [self handleRequestPermissionError:error];
                                                    [self.fbDelegate commentAddDidFinish:resultError];
                                                } else {
                                                    [FBRequestConnection startWithGraphPath:graphPath parameters:parametersDictionary HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                        if (error) {
                                                            resultError = error;
                                                        } else {
                                                            NSLog(@"added comment!");
                                                        }
                                                        [self.fbDelegate commentAddDidFinish:resultError];
                                                    }];
                                                    
                                                }
                                                // Handle new permissions callback
                                            }];
        
    }
    
}


@end
