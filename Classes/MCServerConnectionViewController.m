//
//  MCServerConnectionViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServerConnectionViewController.h"
#import "MCServerDetailViewController.h"

#import "MCAppDelegate.h"
#import "MCTextField.h"

@interface MCServerConnectionViewController () {
    __weak UIView *_containerView;
    __weak NSLayoutConstraint *_bottomConstraint;

    __weak UITextView *_outputView;
    __weak MCTextField *_inputField;
}

@end

@implementation MCServerConnectionViewController

#pragma mark - Initialization

- (void)loadView {
    [super loadView];
    
    // Add container view to heirarchy
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView = containerView;
    [self.view addSubview:_containerView];
    
    // Make container hug to the view frame (left, right, top)
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{ @"container" : _containerView }]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    
    // Make container hug to the view frame (bottom)
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    _bottomConstraint = bottomConstraint;
    [self.view addConstraint:_bottomConstraint];
    
    // Add output view to heirarchy
    UITextView *outputView = [[UITextView alloc] init];
    outputView.backgroundColor = [UIColor blackColor];
    outputView.translatesAutoresizingMaskIntoConstraints = NO;
    outputView.editable = NO;
    outputView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    outputView.dataDetectorTypes = UIDataDetectorTypeLink;
    outputView.accessibilityLabel = @"Command Output";
    outputView.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently;
    _outputView = outputView;
    [_containerView addSubview:_outputView];
        
    // Add a tap recognizer to the output view
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outputViewTapped:)];
    [_outputView addGestureRecognizer:tapRecognizer];
    
    // Make output view hug to sides
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[output]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{ @"output" : _outputView }]];
    
    // Add input field to heirarchy
    MCTextField *inputField = [[MCTextField alloc] init];
    inputField.delegate = self;
    inputField.translatesAutoresizingMaskIntoConstraints = NO;
    inputField.backgroundColor = [UIColor grayColor];
    inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    inputField.spellCheckingType = UITextSpellCheckingTypeNo;
    inputField.enablesReturnKeyAutomatically = YES;
    inputField.returnKeyType = UIReturnKeySend;
    inputField.accessibilityLabel = @"Command Prompt";
    _inputField = inputField;
    [_containerView addSubview:_inputField];
        
    // Make input field hug to sides
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[input]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{ @"input" : _inputField }]];
    
    // Align the input field and output view vertically
    NSDictionary *views = @{ @"input" : _inputField, @"output" : _outputView };
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[output][input(40)]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
}

#pragma mark - View state

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Determine whether or not to keep keyboard visible, based on its current state, and the device type
    MCAppDelegate *appDelegate = (MCAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        appDelegate.keyboardShowing ? [_inputField becomeFirstResponder] : [_inputField resignFirstResponder];
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

    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, _inputField);
    
    // Be aware of all future keyboard changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - User Interface

- (void)outputViewTapped:(id)sender {
    [_inputField resignFirstResponder];
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
        
        [self scrollToBottomAnimated:NO];
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:animations completion:nil];
}

#pragma mark - Scroll state

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self scrollToBottomAnimated:NO];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint contentOffset = CGPointMake(_outputView.contentOffset.x, _outputView.contentSize.height - _outputView.bounds.size.height);
    if (contentOffset.y > 0) {
        [_outputView setContentOffset:contentOffset animated:animated];
    }
}

#pragma mark - Accessibility

- (BOOL)accessibilityPerformMagicTap {
    if (_inputField.text.length) {
        MCServerDetailViewController *parent = (MCServerDetailViewController *)self.parentViewController;
        if ([parent sendButtonPressed:_inputField.text]) {
            _inputField.text = nil;
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - External interface

- (void)clearOutput {
    _outputView.attributedText = nil;
}

- (void)appendOutput:(NSAttributedString *)response {
    if (response) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:_outputView.attributedText];
        [content appendAttributedString:response];
        _outputView.attributedText = content;
                
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Response received. %@", response.string]);
    }

    [self scrollToBottomAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_inputField]) {
        MCServerDetailViewController *parent = (MCServerDetailViewController *)self.parentViewController;
        if ([parent sendButtonPressed:_inputField.text]) {
            _inputField.text = nil;
        }
    }
    
    return NO;
}

@end
