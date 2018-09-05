//
//  TwitterManager.h
//  EasyShare
//
//  Created by Benjamin Hoover on 8/21/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
@interface TwitterManager : NSObject <UIAlertViewDelegate>
@property (strong) void(^authCompletion)(ACAccount *);
- (void)goToProfile:(NSString *)profileID viewController:(UIViewController *)vc;
- (void)getFeedWithCompletion:(void(^)(NSArray *result))completionBlock;
- (void)authenticateWithCompletion:(void(^)(ACAccount *))completion;
@end
