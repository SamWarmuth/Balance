//
//  SWDashboardViewController.m
//  Balance
//
//  Created by Samuel Warmuth on 3/25/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWDashboardViewController.h"
#import "SWLabelPriceCell.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface SWDashboardViewController ()


@end

@implementation SWDashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = @"";
    self.balanceLabel.text = @"--";
    self.changeLabel.text = @"--";
    self.cashOutButton.color = [UIColor colorWithRed:0.000 green:0.542 blue:0.040 alpha:1.000];
    [self.cashOutButton setTitle:@"CASH OUT" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nameLabel.text = [[PFUser currentUser] objectForKey:@"name"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SWLPCell";
    SWLabelPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [SWLabelPriceCell new];
    
    if (indexPath.row % 2 == 0) cell.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    else cell.contentView.backgroundColor = [UIColor whiteColor];
    
    cell.leftLabel.text = @"3/27 8PM CHIPS";
    cell.rightLabel.text = @"(20.00)";
    cell.rightLabel.textColor = [UIColor colorWithRed:0.805 green:0.026 blue:0.000 alpha:1.000];
    return cell;
}

- (void)buyChipsTapped:(id)sender
{
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"buyChips" withParameters:@{} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@",error, result);
            
        } else {
            [SVProgressHUD dismiss];

            NSLog(@"RESULT: %@", result);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
