//
//  MCAppDelegate.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCAppDelegate.h"

#import "MCServerListViewController.h"
#import "MCServerDetailViewController.h"

@implementation MCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create the master view controller
    MCServerListViewController *serverListController = [[MCServerListViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:serverListController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Make the master view controller the root view controller
        serverListController.detailNavigationController = navigationController;
        _window.rootViewController = navigationController;
    } else {
        // Create the detail view controller
        UINavigationController *detailNavigationController = [[UINavigationController alloc] init];
        serverListController.detailNavigationController = detailNavigationController;
    	
        // Create a split view controller with master and detail view controllers
        _splitViewController = [[UISplitViewController alloc] init];
        //_splitViewController.delegate = serverListController;
        _splitViewController.viewControllers = @[navigationController, detailNavigationController];
        
        // Make the split view controller the root view controller
        _window.rootViewController = _splitViewController;
    }
    
    // UIAppearance
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
    
    [_window makeKeyAndVisible];
    
    return YES;
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
