//
//  MCServerConnectionViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServerConnectionViewController.h"

#import "MCAppDelegate.h"

@interface MCServerConnectionViewController () {
    UITextView *_outputView;
}

@end

@implementation MCServerConnectionViewController

#pragma mark - Initialization

- (void)loadView {
    [super loadView];
    
    if (!_outputView) {
        _outputView = [[UITextView alloc] init];
        _outputView.backgroundColor = [UIColor blackColor];
        _outputView.translatesAutoresizingMaskIntoConstraints = NO;
        _outputView.editable = NO;
        _outputView.font = [UIFont fontWithName:@"Minecraft" size:16.0f];
    }
    [self.view addSubview:_outputView];
    
    // Create the input field
    UITextField *inputField = [[UITextField alloc] init];
    inputField.translatesAutoresizingMaskIntoConstraints = NO;
    inputField.backgroundColor = [UIColor blueColor];
    inputField.delegate = _delegate;
    _inputField = inputField;
    [self.view addSubview:_inputField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Add the layout constraints
    NSDictionary *views = @{ @"input" : _inputField, @"output" : _outputView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[output]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[input]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[output][input(40)]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
}

#pragma mark - Public interface

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    if (_delegate != delegate) {
        _inputField.delegate = delegate;
        _delegate = delegate;
    }
}

- (void)appendOutput:(NSAttributedString *)response {
    // Append the output into the outputView
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:_outputView.attributedText];
    [content appendAttributedString:response];
    _outputView.attributedText = content;
}

@end
