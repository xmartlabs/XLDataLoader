//
//  NSError+Additions.m
//  XLDataLoader Example
//
//  Created by Gaston Borba on 4/21/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "NSError+Additions.h"

@implementation NSError (Additions)

-(void)showAlertView
{
    [self showAlertViewWithTitle:@"Error" andMessage:self.localizedFailureReason ?: self.localizedDescription];
}

-(void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
    });
}

@end
