//
//  NSObject+Additions.m
//  XLDataLoader Example
//
//  Created by Gaston Borba on 4/21/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "NSObject+Additions.h"

@implementation NSObject (Additions)

-(id)valueOrNil
{
    return [self isMemberOfClass:[NSNull class]] ? nil : self;
}

@end
