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
    self = [self initWithServer:nil];
    return self;
}

- (id)initWithServer:(MCServer *)server {
    if ((self = [super init])) {
        _server = server;
        
        _editViewController = [[MCServerEditViewController alloc] initWithServer:_server];
        
        _connectionViewController = [[MCServerConnectionViewController alloc] init];
        
        _client = [[MCRCONClient alloc] initWithServer:_server];
        
        [_client addObserver:self forKeyPath:MCRCONClientStateKey options:NSKeyValueObservingOptionNew context:nil];
        [_server addObserver:self forKeyPath:MCServerNameKey options:NSKeyValueObservingOptionNew context:nil];
        [_server addObserver:self forKeyPath:MCServerHostnameKey options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [_client removeObserver:self forKeyPath:MCRCONClientStateKey];
    [_server removeObserver:self forKeyPath:MCServerNameKey];
    [_server removeObserver:self forKeyPath:MCServerHostnameKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _server.name.length ? _server.name : _server.hostname;
    
    // Pick the initial view controller and display it immediately
    UIViewController *viewController = (_client.state == MCRCONClientReadyState || _client.state == MCRCONClientExecutingState) ? _connectionViewController : _editViewController;
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    viewController.view.frame = self.view.bounds;
    [viewController didMoveToParentViewController:self];
}

#pragma mark - Edit view controller

- (void)connectButtonPressed:(id)sender {
    [_client connect:^(BOOL success, NSError *error) {
        if (error) {
            // TODO: Handle error
        }
    }];
}

#pragma mark - Connection view controller

- (BOOL)sendButtonPressed:(NSString *)input {
    [_client sendCommand:input callback:^(NSAttributedString *response, NSError *error) {
        // TODO: Handle error
        [_connectionViewController appendOutput:response];
    }];
    return YES;
}

#pragma View controller switching

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:_client]) {
        if ([keyPath isEqualToString:MCRCONClientStateKey]) {
            MCRCONClientState state = [change[NSKeyValueChangeNewKey] intValue];
            
            if (state == MCRCONClientReadyState || state == MCRCONClientExecutingState) {
                [self displayChildViewController:_connectionViewController];
            } else {
                [_connectionViewController clearOutput];
                
                [self displayChildViewController:_editViewController];
            }
        }
    } else if ([object isEqual:_server]) {
        self.title = _server.name.length ? _server.name : _server.hostname;
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