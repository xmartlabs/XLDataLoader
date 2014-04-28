//
//  UIColor+Additions.m
//  XLDataLoader Example
//
//  Created by Gaston Borba on 4/21/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+(UIColor *)colorWithHex:(int)hex alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:alpha];
}

+(UIColor *)colorWithHex:(int)hex
{
    return [UIColor colorWithHex:hex alpha:1.0];
}

@end
