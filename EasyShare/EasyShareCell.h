//
//  EasyShareCell.h
//  EasyShare
//
//  Created by Benjamin Hoover on 6/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewButtonView.h"
#import "Enums.h"
@class Post;

@protocol EasyShareCellDelegate <NSObject>
//@optional
@required


@optional
-(void)like:(NSInteger)index;
-(void)comment:(NSInteger)index;
- (void)didDownloadImage:(UIImage *)image typeOfImage:(imageType)type withIndex:(NSInteger)index;
- (UIImage *)getImageWithIndex:(NSInteger)index ofType:(imageType)type;
- (void)cellTapped:(NSInteger)row;
@end
@interface EasyShareCell : UITableViewCell {
    CGPoint oldlayerposition;
    CGFloat oldposition;

}
@property int index;
@property (nonatomic) CGFloat oldposition;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *altUserNameHeight;
@property (strong, nonatomic) IBOutlet UIImageView *networkImage;
@property (strong, nonatomic) IBOutlet UIImageView *viewimage;
@property (strong, nonatomic) IBOutlet UILabel *timelabel;
@property (strong, nonatomic) IBOutlet UIButton *profileimg;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UITextView *post;
@property (strong, nonatomic) IBOutlet UILabel *altUserName;

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *cellspinner;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapdetector;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundimage;

@property (strong, nonatomic) BackViewButtonView *likeButton;
@property (strong, nonatomic) BackViewButtonView *commentButton;
@property (strong, nonatomic) BackViewButtonView *shareButton;

#pragma mark ImageConstraints 
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leadingspace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *trailingspace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imagebottomspace;

#pragma mark LinkView
@property (strong, nonatomic) IBOutlet UIView *linkView;
@property (strong, nonatomic) IBOutlet UIButton *linkButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *linkHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewSpace;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *linkNameHieght;
@property (strong, nonatomic) IBOutlet UIImageView *linkImage;

@property (strong, nonatomic) NSString *associatedUsername;
@property (weak, nonatomic) id <EasyShareCellDelegate> delegate;

//remove and replace with text view bottom
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imagetextviewflush;
@property (strong, nonatomic) NSString *fullURL;
#pragma mark BackViewConstraints



#pragma mark Cell Methods
@property (nonatomic) type Network;
- (void)setup:(Post *)info;
- (void)blackout: (NSNotification *)notification;
- (void)revealBackView;
- (void)cellWasSwiped:(UIGestureRecognizer *)recognizer;
- (void)tableDidScroll:(NSNotification *)notification;
- (UIImage*)getVideoImageWithOriginal:(UIImage *)origi;
@end
