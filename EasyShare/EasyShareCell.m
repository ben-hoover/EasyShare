//
//  EasyShareCell.m
//  EasyShare
//
//  Created by Benjamin Hoover on 6/9/13.
//  Copyright (c) 2013 Benjamin Hoover. All rights reserved.
//

#import "EasyShareCell.h"
#import "ProfilePictureDownloader.h"
#import <QuartzCore/QuartzCore.h>
#import "Post.h"
#import "GlobalManager.h"

#define Delegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])
@implementation EasyShareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.post.scrollEnabled = FALSE;
        // Initialization code
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)cellWasSwiped:(UIGestureRecognizer *)recognizer {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"scrollingstarted" object:nil];
    self.backView.hidden = FALSE;
    
    //we go from the right side, and shove 150 over?
    
    CGRect cellframe;
    [self.mainView.layer setAnchorPoint:CGPointMake(0, 0.5)];
    cellframe = self.mainView.frame;
    
    oldposition = self.mainView.layer.position.x;
    [self.mainView.layer setAnchorPoint:CGPointMake(1, 0.5)];
    [self.mainView.layer setPosition:CGPointMake(0, self.mainView.layer.position.y)];
    CALayer *newlayer = self.mainView.layer;
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    [animation setRemovedOnCompletion:YES];
    [animation setDelegate:self];
    [animation setDuration:0.1];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [self.mainView.layer addAnimation:animation forKey:@"reveal"];
    
}
- (void)tableDidScroll:(NSNotification *)notification {
    if (self.mainView.layer.anchorPoint.x != 0.5) {
        [self.mainView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
        [self.mainView.layer setPosition:CGPointMake(oldposition, self.mainView.layer.position.y)];
        self.backView.hidden = TRUE;
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        [animation setRemovedOnCompletion:YES];
        [animation setDelegate:self];
        [animation setDuration:0.1];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [self.mainView.layer addAnimation:animation forKey:@"hide"];
        //  [self.mainView setNeedsDisplay];
        
    }
    
}

- (void)blackout:(NSNotification *)notification {
    
    
    NSNumber *notificationnumber = notification.object;
    int selectedindex = [notificationnumber intValue];
    if (selectedindex != self.index) {
        [UIView animateWithDuration:0.4 animations:^{
            self.alpha = 0;
        }];
    }
    /*
     self.mainView.backgroundColor = [UIColor clearColor];
     self.backView.hidden = TRUE;
     self.contentView.backgroundColor = [UIColor clearColor];
     //  self.contentView.hidden = TRUE;
     self.backgroundColor = [UIColor clearColor];
     
     
     self.profileimg.hidden = TRUE;
     self.username.hidden = TRUE;
     self.post.hidden = TRUE;
     self.viewimage.hidden = TRUE;
     */
    
}
- (void)like:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate like:sender.tag];
    }
}
- (void)comment:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate comment:sender.tag];
    }
}
- (void)setup:(Post *)info {
    self.index = info.index;
    
    
    if (info.type == Photo || info.type == Video) {
        
        [self.viewimage removeGestureRecognizer:self.tapdetector];
        if (!self.tapdetector) {
            self.tapdetector = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellwastapped:)];
        }
        self.backgroundColor = [UIColor whiteColor];
        self.viewimage.image = nil;
        //constraints
        //[cell.mainView removeConstraint:cell.imagebottomspace];
        //cell.imagebottomspace.priority = 1;
        //[cell.mainView addConstraint:cell.imagebottomspace];
        self.imageHeightConstraint.constant = info.imageheight;
        
        self.imagebottomspace.constant = 14;
        self.linkHeight.constant = 0;
        self.textViewSpace.constant = 0;
        self.linkView.hidden = TRUE;
        if (info.imageheight == 0) {
            self.post.text = @"error";
        }
        if ([self.delegate respondsToSelector:@selector(getImageWithIndex:ofType:)] && [self.delegate getImageWithIndex:self.index ofType:PostImage] != nil) {
            self.viewimage.image = [self.delegate getImageWithIndex:self.index ofType:PostImage];
            [self.viewimage addGestureRecognizer:self.tapdetector];
            self.tapdetector.view.tag = self.index;
            
            
        }  else {
            
            self.viewimage.image = nil;
            ProfilePictureDownloader *downloader = [[ProfilePictureDownloader alloc]init];
            __weak ProfilePictureDownloader *_downloader = downloader; //__weak?
            [downloader setCompletionHandler:^{
                [self.cellspinner stopAnimating];
                self.viewimage.alpha = 0;
                [UIView animateWithDuration:0.2 animations:^{
                    if (info.type == Photo) {
                        self.viewimage.image = _downloader.profilepic;
                        self.viewimage.alpha = 1.0;
                        NSLog(@"the height of the image is %f",self.viewimage.bounds.size.height);
                    } else if (info.type == Video) {
                        self.viewimage.image = _downloader.profilepic;
                        self.viewimage.image = [self getVideoImageWithOriginal:self.viewimage.image];
                        self.viewimage.alpha = 1.0;
                    }
                    
                    
                }];
                if ([self.delegate respondsToSelector:@selector(didDownloadImage:typeOfImage:withIndex:)]) {
                    [self.delegate didDownloadImage:self.viewimage.image typeOfImage:PostImage withIndex:self.index];
                    self.viewimage.backgroundColor = [UIColor blackColor];
                }
                
                [self.viewimage addGestureRecognizer:self.tapdetector];
                self.tapdetector.view.tag = info.index;
            }];
            [self.cellspinner startAnimating];
            if (info.type == Photo && info.network == Facebook) {
                [downloader startWithObjectId:info.photo_objectid];
            } else if ((info.type == Photo || info.type == Video) && info.network == Instagram) {
                [downloader startWithURL:info.fullURL];
            } else if (info.type == Video && info.network == Facebook){
                [downloader startWithURL:info.imageUrl];
            }
            
        }
        
    } else if (info.type == Link) {
        
        self.imageHeightConstraint.constant = 0;
        self.imagebottomspace.constant = 14;
        self.linkHeight.constant = 66;
        self.textViewSpace.constant = 0;
        CALayer *linkLayer = self.linkView.layer;
        // linkLayer.borderWidth = 1.0f;
        //linkLayer.borderColor = [[UIColor lightGrayColor]CGColor];
        linkLayer.shadowOffset = CGSizeMake(1, 1);
        linkLayer.shadowColor = [[UIColor blackColor] CGColor];
        linkLayer.shadowRadius = 4.0f;
        linkLayer.shadowOpacity = 0.80f;
        linkLayer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 292, self.linkHeight.constant)] CGPath];
        
        self.linkView.hidden = FALSE;
        self.title.text = info.urlTitle;
        CGSize sizeForText = [self.title.text sizeWithFont:[UIFont boldSystemFontOfSize:14]constrainedToSize:CGSizeMake(207, INT_MAX)];
        self.linkNameHieght.constant = MIN(sizeForText.height,34);
        if ([info.url rangeOfString:@"://"].location != NSNotFound) {
            NSRange rangeForHTTP = [info.url rangeOfString:@"://"];
            
            NSRange searchRange;
            searchRange.location = rangeForHTTP.location + 3;
            searchRange.length = info.url.length - searchRange.location;
            NSRange endRange = [info.url rangeOfString:@"/" options:0 range:searchRange];
            NSRange finalRange;
            finalRange.location = rangeForHTTP.location + 3;
            if (endRange.location == NSNotFound) {
                finalRange.length = info.url.length - rangeForHTTP.location - 3;
            } else {
                finalRange.length = endRange.location - rangeForHTTP.location - 3;
            }
            info.url = [info.url substringWithRange:finalRange];
            
        }
        self.address.text = info.url;
       
        self.linkButton.tag = info.index;
        self.linkImage.image = nil;
        if ([self.delegate respondsToSelector:@selector(getImageWithIndex:ofType:)] && [self.delegate getImageWithIndex:self.index ofType:LinkImage] != nil) {
            self.linkImage.image = [self.delegate getImageWithIndex:self.index ofType:LinkImage];
        } else {
            
            ProfilePictureDownloader *downloader = [[ProfilePictureDownloader alloc]init];
            __weak ProfilePictureDownloader *_downloader = downloader;
            [downloader setCompletionHandler:^{
                self.linkImage.image = _downloader.profilepic;
                if ([self.delegate respondsToSelector:@selector(didDownloadImage:typeOfImage:withIndex:)]) {
                    [self.delegate didDownloadImage:_downloader.profilepic typeOfImage:LinkImage withIndex:self.index];
                }
                
            }];
            
            [downloader startWithURL:info.imageUrl];
        }
        
        
        
        
    } else {
        
        self.imageHeightConstraint.constant = 0;
        self.imagebottomspace.constant = 0;
        self.linkHeight.constant = 0;
        self.textViewSpace.constant = 0;
        self.linkView.hidden = TRUE;
    }
    
    //test gesture recognizer
    
    //etch line
    
    
    
    //reset all properties, setup back view
    
    self.backView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.jpg"]];
    self.backView.hidden = TRUE;
    //reset cell
    self.post.text = nil;
    [self.profileimg setBackgroundImage:nil forState:UIControlStateNormal];
 
    self.username.text = nil;
    [self.backView.layer removeAllAnimations];
    //back view constants
    static int itemSizeWidth = 85;
    static int itemSizeHeight = 71;
     self.profileimg.tag = info.index;
    NSArray *arrayOfOptions = [NSArray arrayWithArray:[GlobalManager listOfOptionsForPost:info showCount:NO]];
    
    
    if (info.typeID != 245 && info.typeID != 257 ) {
        
        
        for (int i = 0; i < arrayOfOptions.count; i++) {
            NSString *format;
            BackViewButtonView *backButton = [[BackViewButtonView alloc]initWithName:[arrayOfOptions objectAtIndex:i] andFrame:CGRectZero];
            
            if ([info.likeCount isKindOfClass:[NSString class]] &&([[arrayOfOptions objectAtIndex:i]isEqualToString:@"Like"] || [[arrayOfOptions objectAtIndex:i]isEqualToString:@"Unlike"]) && ![info.likeCount isEqualToString:@"(null)"]) {
                
                backButton.actionCount.text = info.likeCount;
                
                backButton.actionButton.tag = info.index;
                [backButton.actionButton addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
                self.likeButton = backButton;
                
            } else if ([info.commentCount isKindOfClass:[NSString class]] &&[[arrayOfOptions objectAtIndex:i]isEqualToString:@"Comment"] && ![info.commentCount isEqualToString:@"(null)"]) {
                backButton.actionCount.text = info.commentCount;
                
                [backButton.actionButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
                backButton.actionButton.tag = info.index;
                self.commentButton = backButton;
            } else if ([info.shareCount isKindOfClass:[NSString class]] && [[arrayOfOptions objectAtIndex:i]isEqualToString:@"Share"]  && ![info.shareCount isEqualToString:@"(null)"]) {
                backButton.actionCount.text = info.shareCount;
                self.shareButton = backButton;
            }
            [self.backView addSubview:backButton];
            NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(backButton);
            float distanceBetweenViews = [self distanceBetweeenViewsWithNumber:arrayOfOptions.count WithSuperViewWidth:[UIScreen mainScreen].bounds.size.width itemWidth:itemSizeWidth];
            float distanceFromSuperview = (distanceBetweenViews * (i)) + distanceBetweenViews + (itemSizeWidth*i);
            
            format = [NSString stringWithFormat:@"|-(%f)-[backButton(==%i)]",distanceFromSuperview,itemSizeWidth];
            [self.backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:viewsDictionary]];
            [self.backView addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:itemSizeHeight]];
            [self.backView addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.backView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            
            
        }
    }
    //number of views
    
    
    
    [self.mainView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableDidScroll:) name:@"scrollingstarted" object:nil];
    
    //profilepics
    if ([self.delegate respondsToSelector:@selector(getImageWithIndex:ofType:)] && [self.delegate getImageWithIndex:self.index ofType:ProfileImage])
    {
        
        [self.profileimg setBackgroundImage:[self.delegate getImageWithIndex:self.index ofType:ProfileImage] forState:UIControlStateNormal];
        self.profileimg.alpha = 1.0;
        
    } else {
        /*
        NSURL *url;
        if (info.network == Facebook) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=116&width=116",info.authorid]];
        } else if (info.network == Twitter) {
            NSMutableString *urltmp = [NSMutableString stringWithString:info.url];
            NSRange range = [urltmp rangeOfString:@"_normal"];
            if (range.location != NSNotFound) {
                [urltmp deleteCharactersInRange:range];
                if (Delegate.onWifi == FALSE) {
                    NSLog(@"CELLULAR");
                    [urltmp insertString:@"_bigger" atIndex:range.location];
                }
               
            }
            url = [NSURL URLWithString:urltmp];

        } else if (info.network == Instagram) {
            url = [NSURL URLWithString:info.url];
        }
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            UIImage *imageFromData = [UIImage imageWithData:data];
            [self.profileimg setBackgroundImage:imageFromData forState:UIControlStateNormal];
            self.profileimg.alpha = 1.0;
            
            if ([self.delegate respondsToSelector:@selector(didDownloadImage:typeOfImage:withIndex:)]) {
                [self.delegate didDownloadImage:imageFromData typeOfImage:ProfileImage withIndex:self.index];
            }
            
            
        });
    }
         */
        
        
        ProfilePictureDownloader *downloader = [[ProfilePictureDownloader alloc]init];
        
        __weak ProfilePictureDownloader *_downloader = downloader; //__weak?
        [downloader setCompletionHandler:^{
            NSLog(@"SET");
            [self.profileimg setBackgroundImage:_downloader.profilepic forState:UIControlStateNormal];
            self.profileimg.alpha = 1.0;
            
            if (_downloader.profilepic && [self.delegate respondsToSelector:@selector(didDownloadImage:typeOfImage:withIndex:)]) {
                [self.delegate didDownloadImage:_downloader.profilepic typeOfImage:ProfileImage withIndex:self.index];
            }
            
        }];
        if (info.network == Facebook) {
            [downloader startWithUserId:info.authorid];
        } else if (info.network == Instagram || info.network == Twitter) {
            if (info.network == Twitter) {
                NSMutableString *url = [NSMutableString stringWithString:info.url];
                NSRange range = [url rangeOfString:@"_normal"];
                if (range.location != NSNotFound) {
                    [url deleteCharactersInRange:range];
                    if (Delegate.onWifi == FALSE) {
                        NSLog(@"CELLULAR");
                        [url insertString:@"_bigger" atIndex:range.location];
                    }
                    [downloader startWithURL:url];
                }
            } else {
                [downloader startWithURL:info.url];
            }
        }
    
    
    }
    
    //set network icon
    switch (info.network) {
        case Facebook:
            self.networkImage.image = [UIImage imageNamed:@"Facebook.png"];
            self.Network = Facebook;
            break;
        case Instagram:
            self.networkImage.image = [UIImage imageNamed:@"Instagram.png"];
            self.Network = Instagram;
            break;
        case Twitter:
            self.networkImage.image = [UIImage imageNamed:@"twitter.png"];
            self.Network = Twitter;
            break;
        default:
            break;
    }
    
    //set cell content
    self.post.text = info.message;
    
    
    //set username stuff
    self.username.text = info.author;
    if (info.altUserName) {
        self.altUserName.text = info.altUserName;
        self.altUserNameHeight.constant = 21;
    } else {
        self.altUserName.text = @"";
        self.altUserNameHeight.constant = 3;
    }
    self.profileimg.contentMode = UIViewContentModeScaleAspectFit;
    self.associatedUsername = info.authorid;
    
    self.timelabel.text = [GlobalManager stringDistanceToDate:info.time];
    UISwipeGestureRecognizer * swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasSwiped:)];
    [swipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:swipeRecognizer];
    NSLog(@"%i",self.profileimg.tag);
    
}

- (void)cellwastapped:(UIGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(cellTapped:)]) {
        [self.delegate cellTapped:self.index];
    }
}
- (float)distanceBetweeenViewsWithNumber:(int)num WithSuperViewWidth: (float) width itemWidth: (float)itemWidth {
    //space remaing                      //divided among the number of spaces (1 less than views)
    float test =  (width - (num * itemWidth)) / (num + 1);
    return test;
    
}
- (UIImage*)getVideoImageWithOriginal:(UIImage *)origi{
    
    UIGraphicsBeginImageContextWithOptions(origi.size, NO, 0.0);
    
    [origi drawInRect:CGRectMake( 0, 0, origi.size.width, origi.size.height)];
    UIImage *loadImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Play" ofType:@"png"]];
    CGFloat imageWidth = 0;
   // if (origi.size.width < 292) {
        imageWidth = 60/(self.viewimage.frame.size.height/origi.size.height);
   // } else {
   //     imageWidth = 50/(self.viewimage.frame.size.width/origi.size.width);
   // }
    
    
    [loadImage drawInRect:CGRectMake( (origi.size.width/2)-(imageWidth/2), (origi.size.height/2)-(imageWidth/2),imageWidth ,imageWidth )];
    //we need to get a height and width of 50. to do this first get the scaling factor ie 0.5 then divide the 50 by it so it would be 100
    NSLog(@"%f",loadImage.size.width);
    NSLog(@"%f",origi.size.height);
    NSLog(@"%f",self.viewimage.frame.size.height);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}



//we want it to be 50 every time ok
- (void)prepareForReuse {
    self.profileimg.tag = 0;
    self.linkButton.tag = 0;
    [self.backView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger indx, BOOL *stop) {
        if ([obj isKindOfClass:[BackViewButtonView class]]) {
            [obj removeFromSuperview];
        }
        
    }];
    self.viewimage.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    
}
@end
