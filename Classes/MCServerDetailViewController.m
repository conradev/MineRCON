//
//  MCServerDetailViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServerDetailViewController.h"

#import "MCServerConnectionViewController.h"
#import "MCServerEditViewController.h"

@interface MCServerDetailViewController () {
    MCServerEditViewController *_editViewController;
    MCServerConnectionViewController *_connectionViewController;
}

@end

@implementation MCServerDetailViewController

#pragma mark - Intitialization

- (id)init {
    self = nil;
    return self;
}

- (id)initWithServer:(MCServer *)server {
    if ((self = [super init])) {
        // Register for KVO on server's name property
        _server = server;
        self.title = _server.name;
        [_server addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
        
        // Create the server edit view controller
        _editViewController = [[MCServerEditViewController alloc] initWithServer:_server];
        
        // Create the server connection view controller
        _connectionViewController = [[MCServerConnectionViewController alloc] init];
        _connectionViewController.delegate = self;
        
        // Create the client
        _client = [[MCRCONClient alloc] initWithServer:_server];
        [_client addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [_client removeObserver:self forKeyPath:@"state"];
    [_server removeObserver:self forKeyPath:@"name"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Pick the initial view controller and display it immediately
    UIViewController *viewController = (_client.state == MCRCONClientReadyState || _client.state == MCRCONClientExecutingState) ? _connectionViewController : _editViewController;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    viewController.view.frame = self.view.bounds;
    [viewController didMoveToParentViewController:self];
}

#pragma mark - Connection view controller

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_connectionViewController.inputField]) {
        [_client sendCommand:textField.text callback:^(NSAttributedString *response, NSError *error) {
            [_connectionViewController appendOutput:response];
            // TODO: Handle error
        }];
        textField.text = @"";
    }
    
    return NO;
}

#pragma View controller switching

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:_client]) {
        if ([keyPath isEqualToString:@"state"]) {
            MCRCONClientState state = [change[NSKeyValueChangeNewKey] intValue];
            
            // If the connection is active, display the connection view controller
            // Otherwise, display the editing view controller
            if (state == MCRCONClientReadyState || state == MCRCONClientExecutingState) {
                [self displayChildViewController:_connectionViewController];
            } else {
                [self displayChildViewController:_editViewController];
            }
        }
    } else if ([object isEqual:_server]) {
        // Update the navigation bar if the title changes
        self.title = _server.name;
    }
}

- (void)displayChildViewController:(UIViewController *)toViewController {
    if ([self.childViewControllers containsObject:toViewController])
        return;
    
    // Get the currently displayed child view controller
    UIViewController *fromViewController = self.childViewControllers[0];
    
    // Begin transaction
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    // Begin the transition between the two view controllers
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:0.0f
                               options:0x0
                            animations:^{
                                toViewController.view.frame = self.view.bounds;
                            }
                            completion:^(BOOL finished) {
                                // Complete transaction
                                [fromViewController removeFromParentViewController];
                                [toViewController didMoveToParentViewController:self];
                            }];
}

@end
