//
//  SWSettingsViewController.m
//  Balance
//
//  Created by Samuel Warmuth on 3/26/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWSettingsViewController.h"
#import "SWLabelPriceCell.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface SWSettingsViewController ()

@end

@implementation SWSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SWLPCell";
    SWLabelPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [SWLabelPriceCell new];
    
    if (indexPath.row % 2 == 0) cell.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    else cell.contentView.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.row == 0) {
        cell.leftLabel.text = @"Log Out";
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [PFUser logOut];
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
}

@end
