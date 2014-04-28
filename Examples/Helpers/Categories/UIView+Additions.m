//
//  UIView+Additions.m
//  XLDataLoader Example
//
//  Created by Gaston Borba on 4/21/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

+(id)autolayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

@end
