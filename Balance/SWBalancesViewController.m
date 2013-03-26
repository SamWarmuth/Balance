//
//  SWBalancesViewController.m
//  balance
//
//  Created by Samuel Warmuth on 3/26/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWBalancesViewController.h"
#import "SWLabelPriceCell.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface SWBalancesViewController ()

@property (nonatomic,strong) NSArray *users;

@end

@implementation SWBalancesViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"allBalances" withParameters:@{} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@", error, result);
        } else {
            [SVProgressHUD dismiss];
            if (![result isKindOfClass:[NSArray class]]) return [SVProgressHUD showErrorWithStatus:@"Error: Unexpected Response"];
            self.users = (NSArray *)result;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SWLPCell";
    SWLabelPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [SWLabelPriceCell new];
    
    if (indexPath.row % 2 == 0) cell.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    else cell.contentView.backgroundColor = [UIColor whiteColor];
    
    
    PFUser *user = self.users[indexPath.row];
    
    NSInteger integerValue = [[user objectForKey:@"estBalance"] integerValue];
    NSNumber *value = @(integerValue / 100.0);
    
    NSString *currencyString = [NSNumberFormatter localizedStringFromNumber:value numberStyle:NSNumberFormatterCurrencyStyle];
    
    NSString *name = @"";
    if (user.isDataAvailable) name = [[user objectForKey:@"firstName"] uppercaseString];
    
    cell.leftLabel.text = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"firstName"], [user objectForKey:@"lastName"]];
    cell.rightLabel.text = currencyString;
    
    if (integerValue < 0) {
        cell.rightLabel.textColor = RED;
    } else {
        cell.rightLabel.textColor = [UIColor blackColor];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
