//
//  MCAppDelegate.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCAppDelegate.h"

#import "MCServerListViewController.h"

NSString * const MCSplitViewIdentifier = @"MCSplitViewController";
NSString * const MCMasterNavigationIdentifier = @"MCNavigationController";
NSString * const MCServerListIdentifier = @"MCServerListViewController";

@interface MCAppDelegate () {
    MCServerListViewController *_listViewController;
}

@end

@implementation MCAppDelegate

@synthesize keyboardFrame = _keyboardFrame;

#pragma mark - Interface state restoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    // Create the base view controller heirarchy if it does not exist
    [self instantiateViewControllers];
    
    // Restore the state of the view controllers
    NSString *identifier = [identifierComponents lastObject];
    if ([identifier isEqualToString:MCSplitViewIdentifier]) {
        return _splitViewController;
    } else if ([identifier isEqualToString:MCMasterNavigationIdentifier]) {
        return _navigationController;
    } else if ([identifier isEqualToString:MCServerListIdentifier]) {
        return _listViewController;
    }
    
    return nil;
}

- (void)instantiateViewControllers {
    // Do not instantiate the view controllers twice!
    if (_window)
        return;
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create the master list view controller if it doesn't exist
    _listViewController = [[MCServerListViewController alloc] init];
    _listViewController.restorationIdentifier = MCServerListIdentifier;
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_listViewController];
    _navigationController.restorationIdentifier = MCMasterNavigationIdentifier;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Make the master view controller the root view controller
        _listViewController.detailNavigationController = _navigationController;
        _window.rootViewController = _navigationController;
    } else {
        // Create the detail view controller
        UINavigationController *detailNavigationController = [[UINavigationController alloc] init];
        _listViewController.detailNavigationController = detailNavigationController;
    	
        // Create a split view controller with master and detail view controllers
        _splitViewController = [[UISplitViewController alloc] init];
        _splitViewController.restorationIdentifier = MCSplitViewIdentifier;
        _splitViewController.delegate = _listViewController;
        _splitViewController.viewControllers = @[_navigationController, detailNavigationController];
        
        // Make the split view controller the root view controller
        _window.rootViewController = _splitViewController;
    }
}

#pragma mark - Application state changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Create the base view controller heirarchy if it does not exist
    [self instantiateViewControllers];
    
    // Appearance tweaks
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
    
    // Make the window visible
    [_window makeKeyAndVisible];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) { _keyboardShowing = YES; }];
    [center addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) { _keyboardShowing = NO; }];
    [center addObserverForName:UIKeyboardDidChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        CGRect keyboardFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _keyboardFrame = [_window convertRect:keyboardFrame fromWindow:nil];
    }];
}

- (CGRect)keyboardFrame {
    if (!_keyboardShowing)
        return CGRectZero;
    return _keyboardFrame;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end