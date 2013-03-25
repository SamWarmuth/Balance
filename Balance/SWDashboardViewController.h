//
//  SWDashboardViewController.h
//  Balance
//
//  Created by Samuel Warmuth on 3/25/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BButton.h"

@interface SWDashboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel, *balanceLabel, *changeLabel;
@property (nonatomic, strong) IBOutlet BButton *cashOutButton;

- (IBAction)buyChipsTapped:(id)sender;

@end
