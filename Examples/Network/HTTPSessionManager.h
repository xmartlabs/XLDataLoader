//
//  HTTPSessionManager.h
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/6/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface HTTPSessionManager : AFHTTPSessionManager

+ (HTTPSessionManager *)sharedClient;

@end
