//
//  PostCell.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/16/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "PostCell.h"
#import "Constants.h"
#import "UIView+Additions.h"

@implementation PostCell

@synthesize userImage = _userImage;
@synthesize userName  = _userName;
@synthesize postText  = _postText;
@synthesize postDate  = _postDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self.contentView addSubview:self.userImage];
        [self.contentView addSubview:self.userName];
        [self.contentView addSubview:self.postText];
        [self.contentView addSubview:self.postDate];
        
        [self.contentView addConstraints:[self layoutConstraints]];
    }
    return self;
}

#pragma mark - Views

-(UIImageView *)userImage
{
    if (_userImage) return _userImage;
    _userImage = [UIImageView autolayoutView];
    _userImage.layer.masksToBounds = YES;
    _userImage.layer.cornerRadius = 10.0f;
    return _userImage;
}

-(UILabel *)userName
{
    if (_userName) return _userName;
    _userName = [UILabel autolayoutView];
    _userName.font = [UIFont fontWithName:FONT_NAME_HELVETICA_NEUE size:FONT_SIZE_USER_NAME];
    [_userName setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    
    return _userName;
}

-(PostTextLabel *)postText
{
    if (_postText) return _postText;
    _postText = [PostTextLabel autolayoutView];
    _postText.font = [UIFont fontWithName:FONT_NAME_HELVETICA_NEUE size:FONT_SIZE_POST_TEXT];
    
    _postText.lineBreakMode = NSLineBreakByWordWrapping;
    _postText.numberOfLines = 0;

    return _postText;
}

-(UILabel *)postDate
{
    if (_postDate) return _postDate;
    _postDate = [UILabel autolayoutView];
    _postDate.textColor = [UIColor grayColor];
    _postDate.font = [UIFont fontWithName:FONT_NAME_HELVETICA_NEUE size:FONT_SIZE_TIME_AGO];
    [_postDate setTextAlignment:NSTextAlignmentRight];
    return _postDate;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Layout Constraints

-(NSArray *)layoutConstraints{
    
    NSMutableArray * result = [NSMutableArray array];
    
    NSDictionary * views = @{ @"image": self.userImage,
                              @"name": self.userName,
                              @"text": self.postText,
                              @"date" : self.postDate };
    
    NSDictionary *metrics = @{@"imgSize":@50.0,
                              @"margin" :@12.0};
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[image(imgSize)]-[name]"
                                                                        options:NSLayoutFormatAlignAllTop
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[name]-[date]-|"
                                                                        options:NSLayoutFormatAlignAllBaseline
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[image(imgSize)]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[name]-[text]-|"
                                                                        options:NSLayoutFormatAlignAllLeft
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[text]-|"
                                                                        options:NSLayoutFormatAlignAllBaseline
                                                                        metrics:metrics
                                                                          views:views]];
    return result;
}

@end
