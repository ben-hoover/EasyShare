//
//  ZoomImageView.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/4/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "ZoomImageView.h"
#import "CellImageViewController.h"
@implementation ZoomImageView
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
*/
- (id)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = TRUE;
        
        
    }
    return self;
}

/*
- (void)moveImage: (UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        oldLocation = self.center;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissImage" object:nil];
    } else {
    CGPoint locationinsuperview = [recognizer translationInView:self.superview];
        NSArray *subviews = self.superview.superview.subviews;
        NSLog(@"%@",subviews);
 
        if ([[subviews objectAtIndex:1] isKindOfClass:[UIToolbar class]]) {
            UIToolbar *firsttoolbar = [subviews objectAtIndex:0];
            firsttoolbar.hidden = TRUE;
            (UIToolbar *)[self.superview.superview.subviews objectAtIndex:1].hidden = FALSE;
        }
        
    self.center = CGPointMake(self.frame.size.width/2, oldLocation.y +locationinsuperview.y);
    NSLog(@"%f, %f",locationinsuperview.x, locationinsuperview.y);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    double distancefromcenter = fabs(([UIScreen mainScreen].bounds.size.height/2)-self.center.y);
    NSLog(@"currently at %f, distance from center is %f", self.center.y, distancefromcenter);
    double alpha = 1 - (distancefromcenter/([UIScreen mainScreen].bounds.size.height/2));
    self.superview.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    }
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
