//
//  ProfilePictureDownloader.m
//  EasyShare
//
//  Created by Benjamin Hoover on 6/10/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "ProfilePictureDownloader.h"
#import <FacebookSDK/FacebookSDK.h>
@implementation ProfilePictureDownloader
- (void) startWithUserId:(NSString *)userid {
    self.imagedata = [NSMutableData data];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=116&width=116", userid]]]delegate:self];
    [connection start];
}
- (void) startWithObjectId:(NSString *)objectid; {
    self.objectid = objectid;
    self.imagedata = [NSMutableData data];
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", objectid,[[[FBSession activeSession]accessTokenData]accessToken]];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]delegate:self];

    [connection start];
}
- (void)startWithURL:(NSString *)url {
    self.imagedata = [NSMutableData data];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]delegate:self];
    [connection start];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imagedata appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 
    self.profilepic = [UIImage imageWithData:self.imagedata];
    if (self.completionHandler)
        self.completionHandler();

}
@end
