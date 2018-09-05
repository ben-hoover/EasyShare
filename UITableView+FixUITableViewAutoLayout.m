//
//  UITableView+FixUITableViewAutoLayout.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/5/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "UITableView+FixUITableViewAutoLayout.h"
#import <Objc/runtime.h>
#import <objc/message.h>
@implementation UITableView (FixUITableViewAutoLayout)
+ (void)load
{
    Method existing = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method new = class_getInstanceMethod(self, @selector(_autolayout_replacementLayoutSubviews));
    
    method_exchangeImplementations(existing, new);
}

- (void)_autolayout_replacementLayoutSubviews
{
    [super layoutSubviews];
    [self _autolayout_replacementLayoutSubviews]; // not recursive due to method swizzling
    [super layoutSubviews];
}

@end
