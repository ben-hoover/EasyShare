//
//  ProfilePictureDownloader.h
//  EasyShare
//
//  Created by Benjamin Hoover on 6/10/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfilePictureDownloader : NSObject <NSURLConnectionDelegate>
- (void) startWithUserId:(NSString *)userid;
- (void) startWithObjectId:(NSString *)objectid;
- (void) startWithURL:(NSString *)url;
@property (nonatomic, strong) NSString *objectid;
@property NSMutableData *imagedata;
@property (nonatomic, copy) void (^completionHandler)(void);
@property UIImage *profilepic;

@end
