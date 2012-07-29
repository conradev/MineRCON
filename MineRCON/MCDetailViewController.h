//
//  MCDetailViewController.h
//  MineRCON
//
//  Created by Conrad Kramer on 7/29/12.
//  Copyright (c) 2012 Conrad Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
