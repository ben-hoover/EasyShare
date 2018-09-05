//
//  CommentCell.m
//  EasyShare
//
//  Created by Benjamin Hoover on 7/19/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)confirm {
    NSLog(@"success!");
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)prepareForReuse {
    self.profileImage.image = nil;
}

@end
