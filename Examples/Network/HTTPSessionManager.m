//
//  HTTPSessionManager.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/6/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "HTTPSessionManager.h"

@implementation HTTPSessionManager

//// Server Base URL
static NSString * const AFAppDotNetAPIBaseURLString = @"http://obscure-refuge-3149.herokuapp.com";

// Server Base URL for Staging
// static NSString * const AFAppDotNetAPIBaseURLString = @"http://obscure-refuge-3149-staging.herokuapp.com";

+ (instancetype)sharedClient {
    static HTTPSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AFAppDotNetAPIBaseURLString]];
        [_sharedClient.reachabilityManager startMonitoring];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

@end
