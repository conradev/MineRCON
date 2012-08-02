//
//  MCServerDetailViewController.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCRCONClient.h"

@interface MCServerDetailViewController : UIViewController <UITextFieldDelegate>

- (id)initWithServer:(MCServer *)server;

@property (readonly, strong, nonatomic) MCServer *server;

@property (strong, nonatomic) MCRCONClient *client;

@end
