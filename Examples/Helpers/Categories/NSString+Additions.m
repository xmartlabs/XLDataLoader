//
//  NSString+Additions.m
//  XLDataLoader Example
//
//  Created by Gaston Borba on 4/21/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+(BOOL)stringIsNilOrEmpty:(NSString *)string
{
    return !string || [string isEqualToString:@""];
}

@end
