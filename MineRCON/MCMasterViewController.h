//
//  MCMasterViewController.h
//  MineRCON
//
//  Created by Conrad Kramer on 7/29/12.
//  Copyright (c) 2012 Conrad Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCDetailViewController;

@interface MCMasterViewController : UITableViewController

@property (strong, nonatomic) MCDetailViewController *detailViewController;

@end
