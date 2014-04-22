//
//  RootViewController.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/15/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "RootViewController.h"
#import "PostsTableViewController.h"
#import "UsersTableViewController.h"
#import "Constants.h"
#import "UsersTableWithFixedSearchViewController.h"
#import "UIColor+Additions.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    
    // Posts
    PostsTableViewController *postTableViewController = [[PostsTableViewController alloc] init];
    UINavigationController * postsNavigationController = [[UINavigationController alloc] initWithRootViewController:postTableViewController];
    [tabViewControllers addObject:postsNavigationController];
    
    //Users
    UsersTableViewController *usersTableViewController = [[UsersTableViewController alloc] init];
    UINavigationController * userNavigationController = [[UINavigationController alloc] initWithRootViewController:usersTableViewController];
    [tabViewControllers addObject:userNavigationController];
    
    UsersTableWithFixedSearchViewController * usersTableWithFixedSearchViewController = [[UsersTableWithFixedSearchViewController alloc] init];
    UINavigationController * userFixSearchNavigationController = [[UINavigationController alloc] initWithRootViewController:usersTableWithFixedSearchViewController];
    [tabViewControllers addObject:userFixSearchNavigationController];
    
    [self setViewControllers:tabViewControllers];
    
    UIImage * postsImageUnseledted = [[UIImage imageNamed:@"Posts_Unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * postsImageSelected   = [[UIImage imageNamed:@"Posts_Selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage * usersImageUnselected = [[UIImage imageNamed:@"Users_Unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * usersImageSelected   = [[UIImage imageNamed:@"Users_Selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    postTableViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Posts" image:postsImageUnseledted selectedImage:postsImageSelected];
    
    usersTableViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Users" image:usersImageUnselected selectedImage:usersImageSelected];
    
    usersTableWithFixedSearchViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Users" image:usersImageUnselected selectedImage:usersImageSelected];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
