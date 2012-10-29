//
//  MCAppDelegate.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCAppDelegate.h"

#import "MCServerListViewController.h"

#import "HockeySDK.h"

#import "DDLog.h"
#import "DDFileLogger.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

NSString * const MCSplitViewIdentifier = @"MCSplitViewController";
NSString * const MCMasterNavigationIdentifier = @"MCNavigationController";
NSString * const MCServerListIdentifier = @"MCServerListViewController";

#if defined(CONFIGURATION_Debug) || defined(CONFIGURATION_AdHoc)
int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface MCAppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate> {
    DDFileLogger *_fileLogger;
    MCServerListViewController *_listViewController;
}

@end

@implementation MCAppDelegate

@synthesize keyboardFrame = _keyboardFrame;

#pragma mark - Application state changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set up logging
    [self setupLogging];
    
    // Set up view controllers
    [self setupViewControllers];
    
    // Set up HockeyApp
    BITHockeyManager *hockeyManager = [BITHockeyManager sharedHockeyManager];
    [hockeyManager configureWithBetaIdentifier:@"a7501c5e67fff3beee23f67033660276" liveIdentifier:@"56af34ce7a237742eb1db93c348cfb95" delegate:self];
    [hockeyManager startManager];
    
    // Make the window visible
    [_window makeKeyAndVisible];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    // Global keyboard event handling
    [center addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        DDLogInfo(@"(%@): Keyboard is showing", [[UIApplication sharedApplication] delegate]);
        _keyboardShowing = YES;
    }];
    [center addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        DDLogInfo(@"(%@): Keyboard is hidden", [[UIApplication sharedApplication] delegate]);
        _keyboardShowing = NO;
    }];
    [center addObserverForName:UIKeyboardDidChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        DDLogInfo(@"(%@): Keyboard did change frame", [[UIApplication sharedApplication] delegate]);
        CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _keyboardFrame = [_window convertRect:keyboardFrame fromWindow:nil];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Interface state restoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    // Create the base view controller heirarchy if it does not exist
    [self setupViewControllers];
    
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

- (void)setupViewControllers {
    if (_window != nil)
        return;
    
    DDLogInfo(@"(%@): Instantiating view heirarchy", [[UIApplication sharedApplication] delegate]);
    
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
    
    // Global appearance tweaks
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
}

#pragma mark - CocoaLumberjack

- (void)setupLogging {
    if (_fileLogger != nil)
        return;
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
#if defined(CONFIGURATION_Debug) || defined(CONFIGURATION_AdHoc)
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
    
    _fileLogger = [[DDFileLogger alloc] init];
    _fileLogger.maximumFileSize = (1024 * 1024); // 1 MB
    _fileLogger.rollingFrequency = 0;
    _fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    
    DDLogInfo(@"(%@): Instantiating file logger: %@", [[UIApplication sharedApplication] delegate], _fileLogger);
    
    // Roll log (upon application launch
    [_fileLogger performSelector:@selector(currentLogFileHandle)];
    [_fileLogger rollLogFile];
    [_fileLogger performSelector:@selector(currentLogFileHandle)];
    
    DDLogInfo(@"(%@): Rolled log file for logger: %@", [[UIApplication sharedApplication] delegate], _fileLogger);
    
    [DDLog addLogger:_fileLogger];
}

#pragma mark - HockeyApp

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
    
#if defined(CONFIGURATION_Debug) || defined(CONFIGURATION_AdHoc)
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    
    return nil;
}

- (NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager {
    // One log file exists per session
    // This will return the previous one, corresponding to the crash
    if (crashManager.didCrashInLastSession) {
        NSArray *logs = [_fileLogger.logFileManager sortedLogFilePaths];
        if (logs.count > 1) {
            NSError *error;
            NSString *applicationLog = [NSString stringWithContentsOfFile:logs[logs.count - 2] encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                DDLogError(@"Error loading log file: %@", error);
            }
            
            return applicationLog;
        }
    }
    
    return nil;
}

#pragma mark - Other

- (CGRect)keyboardFrame {
    if (!_keyboardShowing)
        return CGRectZero;
    return _keyboardFrame;
}

@end