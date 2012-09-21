//
//  MCServerEditViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServerEditViewController.h"
#import "MCServerDetailViewController.h"

#import "MCAppDelegate.h"

#import "MCTextField.h"
#import "MCButton.h"

@interface MCServerEditViewController () {
    __weak UIScrollView *_containerView;
    __weak NSLayoutConstraint *_bottomConstraint;

    __weak MCTextField *_nameField;
    __weak MCTextField *_hostnameField;
    __weak MCTextField *_passwordField;
    __weak MCButton *_connectButton;
    
    __weak UITextField *_lastTextField;
    
}

@end

@implementation MCServerEditViewController

#pragma mark - Initialization

- (id)init {
    self = nil;
    return self;
}

- (id)initWithServer:(MCServer *)server {
    if ((self = [super init])) {
        _server = server;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    // Add container view to heirarchy
    UIScrollView *containerView = [[UIScrollView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _containerView = containerView;
    [self.view addSubview:_containerView];
    
    // Make container hug to the view frame (left, right, top)
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{ @"container" : _containerView }]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    
    // Make container hug to the view frame (bottom)
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    _bottomConstraint = bottomConstraint;
    [self.view addConstraint:_bottomConstraint];
    
    MCTextField *nameField = [[MCTextField alloc] init];
    nameField.text = _server.name;
    nameField.returnKeyType = UIReturnKeyNext;
    nameField.translatesAutoresizingMaskIntoConstraints = NO;
    nameField.delegate = self;
    _nameField = nameField;
    [_containerView addSubview:_nameField];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_nameField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    MCTextField *hostnameField = [[MCTextField alloc] init];
    hostnameField.text = _server.hostname;
    hostnameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    hostnameField.returnKeyType = UIReturnKeyNext;
    hostnameField.translatesAutoresizingMaskIntoConstraints = NO;
    hostnameField.delegate = self;
    _hostnameField = hostnameField;
    [_containerView addSubview:_hostnameField];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_hostnameField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    MCTextField *passwordField = [[MCTextField alloc] init];
    passwordField.text = _server.password;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.secureTextEntry = YES;
    passwordField.translatesAutoresizingMaskIntoConstraints = NO;
    passwordField.delegate = self;
    _passwordField = passwordField;
    [_containerView addSubview:_passwordField];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_passwordField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    MCButton *connectButton = [[MCButton alloc] init];
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [connectButton addTarget:self action:@selector(connectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    connectButton.translatesAutoresizingMaskIntoConstraints = NO;
    _connectButton = connectButton;
    [_containerView addSubview:_connectButton];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_connectButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    
    // Vertical layout
    NSDictionary *views = @{ @"name" : _nameField, @"hostname" : _hostnameField, @"password" : _passwordField, @"button" : _connectButton };
    NSDictionary *metrics = @{ @"spacing" : @(isPad ? 60 : 20) };
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[name]-(spacing)-[hostname]-(spacing)-[password]-(spacing)-[button]-(spacing)-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
}

#pragma mark - View state

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    
    if (!_server) {
        self.view.userInteractionEnabled = NO;
        _connectButton.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Determine whether or not to keep keyboard visible, based on its current state, and the device type
    MCAppDelegate *appDelegate = (MCAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        if (appDelegate.keyboardShowing) {
            if (_lastTextField) {
                [_lastTextField becomeFirstResponder];
            } else {
                [_nameField becomeFirstResponder];
            }
        } else {
            [_nameField resignFirstResponder];
            [_hostnameField resignFirstResponder];
            [_passwordField resignFirstResponder];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Get keyboard frame
    MCAppDelegate *appDelegate = (MCAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect keyboardFrame = [self.view convertRect:appDelegate.keyboardFrame fromView:nil];
    keyboardFrame = CGRectIntersection(self.view.bounds, keyboardFrame);
    
    // Initially adjust constraint for keyboard
    [self adjustViewWithKeyboardFrame:keyboardFrame];
    
    // Be aware of all future keyboard changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [@[ _nameField, _hostnameField, _passwordField] enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        if ([textField isFirstResponder]) {
            _lastTextField = textField;
        }
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - Keyboard state

- (void)adjustViewWithKeyboardFrame:(CGRect)keyboardFrame {
    [_bottomConstraint setConstant:(-1.0 * keyboardFrame.size.height)];
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;
    
    // Get duration
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Get options
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            options |= UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options |= UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options |= UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options |= UIViewAnimationOptionCurveLinear;
            break;
        default:
            break;
    }
    
    // Get frame
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view.window convertRect:keyboardFrame fromWindow:nil];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    keyboardFrame = CGRectIntersection(self.view.bounds, keyboardFrame);
    
    void (^animations)() = ^() {
        [self adjustViewWithKeyboardFrame:keyboardFrame];
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:animations completion:nil];
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_containerView scrollRectToVisible:textField.frame animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Update the server based on changes to the text fields
    if ([textField isEqual:_nameField]) {
        _server.name = _nameField.text;
    } else if ([textField isEqual:_hostnameField]) {
        NSMutableArray *components = [NSMutableArray arrayWithArray:[_hostnameField.text componentsSeparatedByString:@":"]];
        
        NSInteger port = 0;
        if (components.count > 1) {
            port = [[components lastObject] integerValue];
            [components removeObject:[components lastObject]];
        }
        
        _server.port = port;
        _server.hostname = [components componentsJoinedByString:@":"];
    } else if ([textField isEqual:_passwordField]) {
        _server.password = _passwordField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Switch to the next responder, or hide the keyboard
    if ([textField isEqual:_nameField]) {
        [_hostnameField becomeFirstResponder];
    } else if ([textField isEqual:_hostnameField]) {
        [_passwordField becomeFirstResponder];
    } else if ([textField isEqual:_passwordField]) {
        [_passwordField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark - External interface

- (void)connectButtonPressed:(id)sender {
    MCServerDetailViewController *parent = (MCServerDetailViewController *)[self parentViewController];
    [parent connectButtonPressed:sender];
}

@end
