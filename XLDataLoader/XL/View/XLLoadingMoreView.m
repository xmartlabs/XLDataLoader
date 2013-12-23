//
//  XLLoadingMoreCell.m
//  XLKit
//
//  Created by Martin Barreto on 7/27/13.
//  Copyright (c) 2013 Xmartlabs. All rights reserved.
//

#import "XLLoadingMoreView.h"

@interface XLLoadingMoreView()

@end

@implementation XLLoadingMoreView

@synthesize activityViewIndicator = _activityViewIndicator;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 50.f)];
    
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.activityViewIndicator];
        [self addConstraints:[self constraints]];
    }
    return self;
}


-(UIActivityIndicatorView*)activityViewIndicator
{
    if (_activityViewIndicator) return _activityViewIndicator;
    _activityViewIndicator = [[UIActivityIndicatorView  alloc] init];
    [_activityViewIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_activityViewIndicator setColor:[UIColor grayColor]];
    [_activityViewIndicator hidesWhenStopped];
    [_activityViewIndicator startAnimating];
    [_activityViewIndicator sizeToFit];
    return _activityViewIndicator;
}

#pragma mark - Costraints

-(NSArray *)constraints
{
    NSMutableArray * result = [NSMutableArray array];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.activityViewIndicator
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.f constant:0.f]];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.activityViewIndicator
                                                   attribute:NSLayoutAttributeCenterY
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeCenterY
                                                  multiplier:1.f constant:0.f]];
    
    //[result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[activity]-|" options:0 metrics:0 views:@{@"activity": self.activityViewIndicator}]];
    return result;
}

@end
