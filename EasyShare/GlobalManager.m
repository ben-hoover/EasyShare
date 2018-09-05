//
//  GlobalManager.m
//  EasyShare
//
//  Created by Benjamin Hoover on 8/5/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "GlobalManager.h"
#import "CellImageViewController.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "InstagramManager.h"
#import "AppDelegate.h"
#import "Post.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
@implementation GlobalManager
- (void)getFeedWithCompletionBlock:(void (^)(NSArray *result))completion {
    
    NSMutableArray *feedResults = [[NSMutableArray alloc]init];
    self.feedCompletion = completion;
    networksToGet = 3;
    networksDone = 0;
    NSCalendar *iCal = [[NSCalendar alloc]initWithCalendarIdentifier:[[NSCalendar currentCalendar]calendarIdentifier]];
    [iCal setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [iCal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    [components setHour:[components hour]-12];
    NSDate *fourHoursAgo = [iCal dateFromComponents:components];
    [self.fbManager getFeedWithUntil:[fourHoursAgo timeIntervalSince1970] Completion:^(NSMutableArray *results){
        [feedResults addObjectsFromArray:results];
        ++networksDone;
        if (networksDone == networksToGet) {
            [self doCleanupWithArray:feedResults];
        }
    }];
    [self.igManager getFeedWithTime:[fourHoursAgo timeIntervalSince1970] Completion:^(NSMutableArray *result)
    {
        [feedResults addObjectsFromArray:result];
        ++networksDone;
        if (networksDone == networksToGet) {
            [self doCleanupWithArray:feedResults];
        }
     }];
     
    [self.twManager getFeedWithCompletion:^(NSArray *result){
        [feedResults addObjectsFromArray:result];
        ++networksDone;
        if (networksDone == networksToGet) {
            [self doCleanupWithArray:feedResults];
        }
    }];
    
}
- (void)doCleanupWithArray:(NSMutableArray *)feedArray {

     NSArray *sortedArray;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                  ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedArray = [feedArray sortedArrayUsingDescriptors:sortDescriptors];
    [sortedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if ([obj isKindOfClass:[Post class]]) {
            Post *posAtIndex = obj;
            posAtIndex.index = idx;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.feedCompletion(sortedArray);
    });
    
}
- (FacebookManager *)fbManager {
    if (!_fbManager) {
        _fbManager = [[FacebookManager alloc]init];
    }
    return _fbManager;
}
- (TwitterManager *)twManager {
    if (!_twManager) {
        _twManager = [[TwitterManager alloc]init];
    }
    return _twManager;
}
- (InstagramManager *)igManager {
    if (!_igManager) {
        _igManager = [[InstagramManager alloc]init];
    }
    return _igManager;
}
+ (NSString *)stringDistanceToDate:(NSDate *)date {
    NSTimeInterval timesinceposted = [[NSDate date] timeIntervalSinceDate:date];
    NSString *result;
    int time = (float)timesinceposted;
    NSLog(@"%i",time);
    if (time == 1) {
        result = @"1 second ago";
    } else if (time < 60){
        result = [NSString stringWithFormat:@"%i seconds ago",time];
    } else if (time >= 60 && time < 120) {
        result = @"1 minute ago";
    } else if (time >= 120 && time < 3600) {
        result = [NSString stringWithFormat:@"%i minutes ago",time/60];
    } else if (time >= 3600 && time < 7200) { //one hour
        result = @"1 hour ago";
    } else if (time >= 7200 && time < 86400) { //greater or equal to two hours and less than one day
        result = [NSString stringWithFormat:@"%i hours ago",time/3600]; //time divided by hours
    } else if (time >= 86400 && time < [[NSDate date]timeIntervalSinceDate:[self yesterday]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"hh:mm a"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        result = [NSString stringWithFormat:@"Yesterday at %@",[formatter stringFromDate:date]];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"M/d/yy 'at' h:mm a"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        result = [formatter stringFromDate:date];
    }
    return result;

}
+ (NSDate *)yesterday {
    NSCalendar *ical2 = [[NSCalendar alloc] initWithCalendarIdentifier:[[NSCalendar currentCalendar]calendarIdentifier]];
    [ical2 setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [ical2 components:( NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit ) fromDate:[NSDate date]];
    [components setDay:[components day]-1];
    [components setHour:0];
    [components setMinute:0];
    
    return [ical2 dateFromComponents:components];
    
}
+ (void)playVideoWithViewController:(UIViewController *)view post:(Post *)cellPost{
    MPMoviePlayerViewController *videoPlayer;
    if (cellPost.network == Facebook) {
        videoPlayer = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:cellPost.url]];
    } else if (cellPost.network == Instagram) {
        videoPlayer = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:cellPost.imageUrl]];
    } else {
        videoPlayer = [[MPMoviePlayerViewController alloc]initWithContentURL:nil];
    }
    
    [view presentMoviePlayerViewControllerAnimated:videoPlayer];
    [videoPlayer.moviePlayer prepareToPlay];
    [videoPlayer.moviePlayer play];
}

+ (NSMutableArray *)listOfOptionsForPost:(Post *)info showCount:(BOOL)count {
    NSMutableArray *arrayOfOptions;
    switch (info.network) {
        case Facebook:
            arrayOfOptions = [[NSMutableArray alloc]init];
            if (info.userLikes == FALSE && info.canLike == TRUE) {
                if (count == TRUE && info.likeCount) {
                    [arrayOfOptions addObject:[NSString stringWithFormat:@"Like (%@)",info.likeCount]];
                } else {
                    [arrayOfOptions addObject:@"Like"];
                }
            } else if (info.userLikes == TRUE && info.canLike == TRUE) {
                if (count == TRUE && info.likeCount) {
                    [arrayOfOptions addObject:[NSString stringWithFormat:@"Unlike (%@)",info.likeCount]];
                } else {
                    [arrayOfOptions addObject:@"Unlike"];
                }
            }
            if (info.canComment == TRUE) {
                if (count == TRUE && info.commentCount) {
                    [arrayOfOptions addObject:[NSString stringWithFormat:@"Comment (%@)",info.commentCount]];
                } else {
                    [arrayOfOptions addObject:@"Comment"];
                }
            }
            if (count == TRUE && info.shareCount) {
                [arrayOfOptions addObject:[NSString stringWithFormat:@"Share (%@)",info.shareCount]];
            } else {
            [arrayOfOptions addObject:@"Share"];
            }
            break;
        case Instagram:
            arrayOfOptions = [[NSMutableArray alloc]init];
            if (info.userLikes == FALSE) {
                if (count == TRUE && info.likeCount) {
                    [arrayOfOptions addObject:[NSString stringWithFormat:@"Like (%@)",info.likeCount]];
                } else {
                    [arrayOfOptions addObject:@"Like"];
                }
            } else if (info.userLikes == TRUE) {
                if (count == TRUE && info.likeCount) {
                    [arrayOfOptions addObject:[NSString stringWithFormat:@"Unlike (%@)",info.likeCount]];
                } else {
                    [arrayOfOptions addObject:@"Unlike"];
                }
            }
            if (count == TRUE && info.commentCount) {
                [arrayOfOptions addObject:[NSString stringWithFormat:@"Comment (%@)",info.commentCount]];
            } else {
                [arrayOfOptions addObject:@"Comment"];
            }
            
            break;
        default:
            break;
    }
    return arrayOfOptions;
}
@end
