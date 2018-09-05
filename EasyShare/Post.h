//
//  Post.h
//  EasyShare
//
//  Created by Benjamin Hoover on 6/17/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Enums.h"
@interface Post: NSObject

@property (nonatomic) type network;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) postType type;
@property (nonatomic) int typeID;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic) CGFloat imageheight;

@property (nonatomic, strong) NSString *url;
/*!
 @abstract
 A URL for part of the post
 
 @discussion
 For Facebook Videos: the url of the video
 For Facebook Links: the trimmed version of the link
 For Instagram Photos: the profile picture link
 For Twitter: the profile picture link
*/
@property (nonatomic, strong) NSString *fullURL;
/*!
 @abstract
 An additional URL, typically for the main object assosiated with the post
 
 @discussion
 For Facebook Links: the full url
 For Instagram Photos: the photo url
 For Instagram Videos: the video url
*/
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *altUserName;
@property (nonatomic, strong) NSString *authorid;
@property (nonatomic, strong) NSString *photo_objectid;
//facebook photo url...instagram not needed
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *likeCount;
@property (nonatomic, strong) NSString *commentCount;
@property (nonatomic, strong) NSString *shareCount;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSString *urlTitle;
@property (nonatomic, strong) NSString *imageUrl;
//for instagram videos..the video url
@property (nonatomic, strong) NSString *caption;
/*
@property (nonatomic, strong) NSString *originalCaption;
@property (nonatomic, strong) NSString *originalAuthor;
@property (nonatomic, strong) NSDate *originalTime;
@property (nonatomic, strong) NSString *originalLikeCount;
@property (nonatomic, strong) NSString *originalCommentCount;
@property (nonatomic, strong) NSString *videoThumnailImageURL;
@property (nonatomic, strong) NSString *originalAuthorID;
 */
@property(nonatomic) BOOL isAShare;
@property (nonatomic) BOOL canComment;
@property (nonatomic) BOOL canLike;
@property (nonatomic) BOOL userLikes;
@property (nonatomic) int index;
@property (nonatomic) BOOL story;

@end
