//
//  MCButton.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "MCButton.h"

SystemSoundID click;

__attribute__((constructor))
static void initialize_click_sound() {
    NSURL *clickURL = [[NSBundle mainBundle] URLForResource:@"Click" withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)clickURL, &click);
}

__attribute__((destructor))
static void destroy_click_sound() {
    AudioServicesDisposeSystemSoundID(click);
}

@interface MCButton () {
    __weak UIEvent *_lastEvent;
}

@end

@implementation MCButton

- (id)init {
    if ((self = [super init])) {
        // TODO: Switch to attributed text
        self.titleLabel.font = [UIFont fontWithName:@"Minecraft" size:16.0f];
        self.titleLabel.shadowColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.21875f alpha:1.0f];
        self.titleLabel.shadowOffset = CGSizeMake(2, 2);
        
        [self setBackgroundImage:[UIImage imageNamed:@"Button"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.87843f alpha:1.0f] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"Button_highlighted"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:0.625f alpha:1.0f] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"Button_disabled"] forState:UIControlStateDisabled];
        [self setTitleColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.62745f alpha:1.0f] forState:UIControlStateDisabled];        
    }
    return self;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    // Don't play more than one sound per event
    if (![event isEqual:_lastEvent]) {
        NSArray *actions = [self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        if ([actions containsObject:NSStringFromSelector(action)]) {            
            AudioServicesPlaySystemSound(click);
            _lastEvent = event;
        }
    }
    
    [super sendAction:action to:target forEvent:event];
}

- (CGSize)intrinsicContentSize {
    return (CGSize){ 280, 40 };
}

@end
