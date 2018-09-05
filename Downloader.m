//
//  Downloader.m
//  EasyShare
//
//  Created by Benjamin Hoover on 8/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "Downloader.h"

@implementation Downloader
- (void)downloadWithURL:(NSString *)url toJSON:(BOOL)json completion:(void(^)(id results, NSError *error))completion {
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30.0] delegate:self startImmediately:FALSE];
    if (json) {
        self.type = GetWithJSON;
    } else {
        self.type = Get;
    }
    self.completion = completion;
    
    [connection start];
}
- (void)postWithURL:(NSString *)url completion:(void(^)(id results, NSError  *error))competion {
    self.completion = competion;
    self.type = POST;
    NSURL *theURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
    request.HTTPMethod = @"POST";
  // [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
   //NSString *postData = @"text=teest teeest";
    //[request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    //[request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}

- (void)deleteWithURL:(NSString *)url completion:(void(^)(id results, NSError *error))completion {
    self.completion = completion;
    self.type = Delete;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
    request.HTTPMethod = @"DELETE";
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}
- (id)init {
    self = [super init];
    if (self) {
        self.data = [NSMutableData data];
    }
    return self;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
   // NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.completion(nil, error);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    if (self.type == GetWithJSON || self.type == POST || self.type == Delete) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:self.data //1
                              options:nil
                              error:&error];
        NSLog(@"%@",json);
        self.completion(json, error);
    } else {
        self.completion(self.data, nil);
    }
    
}
@end
