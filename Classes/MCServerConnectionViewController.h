//
//  MCServerConnectionViewController.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCServerConnectionViewController : UIViewController <UITextFieldDelegate>

- (void)appendOutput:(NSAttributedString *)response;

@end