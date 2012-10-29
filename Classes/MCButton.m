//
//  MCButton.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#import "MCButton.h"
#import "NSAttributedString+Minecraft.h"

@interface UIView (Debug)
- (id)recursiveDescription;
@end

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

@implementation MCButton

- (id)init {
    if ((self = [super init])) {
        [self addTarget:self action:@selector(playClickSound) forControlEvents:UIControlEventTouchUpInside];
        
        [self setBackgroundImage:[UIImage imageNamed:@"Button"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"Button_highlighted"] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"Button_disabled"] forState:UIControlStateDisabled];
    }
    return self;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    
    // I don't want mushy pixels on my button image!
    if ([subview isKindOfClass:[UIImageView class]]) {
        [[subview layer] setMagnificationFilter:kCAFilterNearest];
    }
}

- (void)setMinecraftText:(NSString *)text {
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:text attributes:[NSAttributedString minecraftInterfaceAttributes]] forState:UIControlStateNormal];
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:text attributes:[NSAttributedString minecraftSelectedInterfaceAttributes]] forState:UIControlStateHighlighted];
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:text attributes:[NSAttributedString minecraftSecondaryInterfaceAttributes]] forState:UIControlStateDisabled];
}

- (void)playClickSound {
    AudioServicesPlaySystemSound(click);
}

- (CGSize)intrinsicContentSize {
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    return (CGSize){ isPad ? 400 : 276 , isPad ? 40 : 28 };
}

@end
