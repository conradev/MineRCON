//
//  MCServerEditViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServerEditViewController.h"

#import "MCTextField.h"
#import "MCButton.h"

@interface MCServerEditViewController () {
    __weak MCTextField *_nameField;
    __weak MCTextField *_hostnameField;
    __weak MCTextField *_passwordField;
    __weak MCButton *_connectButton;
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
    
    MCTextField *nameField = [[MCTextField alloc] init];
    [nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    nameField.text = _server.name;
    nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    nameField.returnKeyType = UIReturnKeyNext;
    nameField.translatesAutoresizingMaskIntoConstraints = NO;
    nameField.delegate = self;
    _nameField = nameField;
    [self.view addSubview:_nameField];
    
    MCTextField *hostnameField = [[MCTextField alloc] init];
    [hostnameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    hostnameField.text = _server.hostname;
    hostnameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    hostnameField.returnKeyType = UIReturnKeyNext;
    hostnameField.translatesAutoresizingMaskIntoConstraints = NO;
    hostnameField.delegate = self;
    _hostnameField = hostnameField;
    [self.view addSubview:_hostnameField];

    MCTextField *passwordField = [[MCTextField alloc] init];
    [passwordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    passwordField.text = _server.password;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.secureTextEntry = YES;
    passwordField.translatesAutoresizingMaskIntoConstraints = NO;
    passwordField.delegate = self;
    _passwordField = passwordField;
    [self.view addSubview:_passwordField];
    
    MCButton *connectButton = [[MCButton alloc] init];
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    connectButton.translatesAutoresizingMaskIntoConstraints = NO;
    _connectButton = connectButton;
    [self.view addSubview:_connectButton];
}

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
    
    // Add the layout constraints
    NSDictionary *views = @{ @"name" : _nameField, @"hostname" : _hostnameField, @"password" : _passwordField, @"button" : _connectButton };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[name]-(60)-[hostname]-(60)-[password]-(60)-[button]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[name]-(>=0)-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hostname(==name)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[password(==name)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(==name)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
}

#pragma mark - Text field delegate

- (void)textFieldDidChange:(UITextField *)textField {
    // Update the server based on changes to the text fields
    if ([textField isEqual:_nameField]) {
        _server.name = _nameField.text;
    } else if ([textField isEqual:_hostnameField]) {
        _server.hostname = _hostnameField.text;
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

@end
