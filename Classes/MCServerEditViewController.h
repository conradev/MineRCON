//
//  MCServerEditViewController.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCServer.h"

@interface MCServerEditViewController : UIViewController <UITextFieldDelegate>

@property (readonly, strong, nonatomic) MCServer *server;

- (id)initWithServer:(MCServer *)server;

@end