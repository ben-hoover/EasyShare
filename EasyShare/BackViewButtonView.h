//
//  BackViewButtonView.h
//  EasyShare
//
//  Created by Benjamin Hoover on 7/15/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackViewButtonView : UIView {

}
- (id)initWithName:(NSString *)name andFrame:(CGRect)frame;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UILabel *actionCount;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end
