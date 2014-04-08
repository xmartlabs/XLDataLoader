//
//  XLLoadingMoreView.m
//  XLDataLoader ( https://github.com/xmartlabs/XLDataLoader )
//
//  Created by Martin Barreto on 10/25/13.
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
    
    return result;
}

@end
