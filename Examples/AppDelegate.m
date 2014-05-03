//
//  AppDelegate.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/6/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "Constants.h"
#import "UIColor+Additions.h"
#import <CoreData/CoreData.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>

// AFNetworking Activity Indicator
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [AFNetworkActivityLogger sharedLogger].filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//        NSURLRequest * requestToEvaluate = (NSURLRequest *)evaluatedObject;
//        return [requestToEvaluate.allHTTPHeaderFields[@"Accept"] isEqualToString:@"image/*"];
//    }];
//    [[AFNetworkActivityLogger sharedLogger] startLogging];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // AFNetworking Activity Indicator
    AFNetworkActivityIndicatorManager.sharedManager.enabled = YES;
    
    [self customizeAppearance];
    
    RootViewController * rootViewController = [[RootViewController alloc] init];
   
    [self.window setRootViewController:rootViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)customizeAppearance
{

    // Navigation Bar
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHex:__COLOR_CELESTIAL]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // Tab Bar
    [[UITabBar appearance] setBarTintColor:[UIColor grayColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    // Status Bar white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Background Color
    [self.window setBackgroundColor:[UIColor whiteColor]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
