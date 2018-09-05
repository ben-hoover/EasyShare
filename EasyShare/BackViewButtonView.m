//
//  BackViewButtonView.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "BackViewButtonView.h"

@implementation BackViewButtonView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithName:nil andFrame:frame];
    
}
- (id)initWithName:(NSString *)name andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = FALSE;
        self.actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.actionButton.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.actionButton setTitle:name forState:UIControlStateNormal];
        [self addSubview:self.actionButton];
        self.actionCount = [[UILabel alloc]init];
        self.actionCount.backgroundColor = [UIColor clearColor];
        self.actionCount.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self addSubview:self.actionCount];
        self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.spinner.translatesAutoresizingMaskIntoConstraints = FALSE;
        self.spinner.hidesWhenStopped = TRUE;
        [self addSubview:self.spinner];
        NSDictionary *objectDict = [[NSDictionary alloc]initWithObjectsAndKeys:self.actionButton, @"actionButton",self.actionCount,@"actionCount",self.spinner,@"spinner", nil];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[actionButton(==43)]-(3)-[actionCount(==25)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:objectDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[actionButton]|" options:0 metrics:nil views:objectDict]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.actionButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.actionButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
      
    }
    return self;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
