//
//  Downloader.h
//  EasyShare
//
//  Created by Benjamin Hoover on 8/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"
@interface Downloader : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property (nonatomic, strong) void(^completion)(id results, NSError *error);
@property (nonatomic) downloadType type;
@property (nonatomic, strong) NSMutableData *data;
- (void)downloadWithURL:(NSString *)url toJSON:(BOOL)json completion:(void(^)(id results, NSError *error))completion;
- (void)postWithURL:(NSString *)url completion:(void(^)(id results, NSError  *error))competion;
- (void)deleteWithURL:(NSString *)url completion:(void(^)(id results, NSError *error))completion;
@end
