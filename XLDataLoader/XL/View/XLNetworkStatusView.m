//
//  NetworkStatusView.m
//  XLDataLoader
//
//  Created by Martin Barreto on 2/5/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "XLNetworkStatusView.h"

@implementation XLNetworkStatusView

@synthesize messageLabel = _messageLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor orangeColor]];
        [self addSubview:self.messageLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        self.layer.zPosition = MAXFLOAT;
    }
    return self;
}


#pragma mark - Properties

-(UILabel *)messageLabel
{
    if (_messageLabel) return _messageLabel;
    _messageLabel = [[UILabel alloc] init];
    [_messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_messageLabel setTextColor:[UIColor whiteColor]];
    [_messageLabel setText:NSLocalizedString(@"No internet connection", nil)];
    UIFont * font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [_messageLabel setFont:font];
    return _messageLabel;
}



@end
