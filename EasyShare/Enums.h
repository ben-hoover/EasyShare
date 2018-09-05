//
//  Enums.h
//  EasyShare
//
//  Created by Benjamin Hoover on 7/24/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Enums : NSObject
typedef NS_ENUM(NSUInteger, type) {
    Facebook,
    Twitter,
    Instagram
};
typedef NS_ENUM(NSUInteger,postType) {
    Photo,
    Video,
    Link,
    Status
};
typedef NS_ENUM(NSUInteger,postMode) {
    Comment,
    Share
};
typedef NS_ENUM(NSUInteger, imageType) {
    ProfileImage,
    PostImage,
    LinkImage
};
typedef NS_ENUM(NSUInteger, downloadType) {
    Get,
    GetWithJSON,
    POST,
    Delete
};
@end
