//
//  UserCollectionCell.m
//  XLDataLoader
//
//  Created by Martin Barreto on 5/4/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "UserCollectionCell.h"

@implementation UserCollectionCell

@synthesize userImage = _userImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.contentView addSubview:[self userImage]];
        
    }
    return self;
}


#pragma mark - Properties

-(UIImageView *)userImage
{
    if (_userImage) return _userImage;
    _userImage = [UIImageView new];
    [_userImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    _userImage.contentMode = UIViewContentModeScaleAspectFill;
    return _userImage;
}


@end
