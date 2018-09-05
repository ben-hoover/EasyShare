//
//  ZoomImageView.h
//  EasyShare
//
//  Created by Benjamin Hoover on 7/4/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomImageView : UIImageView
{
    CGPoint oldLocation;
    UIDeviceOrientation oldorientation;
}
- (void)devicedidrotate: (NSNotification *)notif;
- (void)applychanges: (CGAffineTransform)transform;
@end
