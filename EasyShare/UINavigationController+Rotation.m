//
//  UINavigationController+Rotation.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/5/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "UINavigationController+Rotation.h"

@implementation UINavigationController (Rotation)
-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
