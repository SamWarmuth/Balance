//
//  SWTransactionsViewController.m
//  Balance
//
//  Created by Samuel Warmuth on 3/26/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWTransactionsViewController.h"
#import "SWLabelPriceCell.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface SWTransactionsViewController ()

@property (nonatomic, strong) NSArray *transactions;

@end

@implementation SWTransactionsViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"allTransactions" withParameters:@{} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@", error, result);
        } else {
            [SVProgressHUD dismiss];
            if (![result isKindOfClass:[NSArray class]]) return [SVProgressHUD showErrorWithStatus:@"Error: Unexpected Response"];
            self.transactions = (NSArray *)result;
            [self.tableView reloadData];
        }
    }];
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
    return self.transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SWLPCell";
    SWLabelPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [SWLabelPriceCell new];
    
    if (indexPath.row % 2 == 0) cell.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    else cell.contentView.backgroundColor = [UIColor whiteColor];
    
    
    PFObject *transaction = self.transactions[indexPath.row];
    NSInteger integerValue = [[transaction objectForKey:@"amount"] integerValue];
    NSNumber *value = @(integerValue / 100.0);
    
    NSString *currencyString = [NSNumberFormatter localizedStringFromNumber:value numberStyle:NSNumberFormatterCurrencyStyle];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([transaction.createdAt timeIntervalSinceNow] * -1 > 60*60*24) {
        [dateFormatter setDateFormat:@"M/d"];
    } else {
        [dateFormatter setDateFormat:@"h:mma"];
    }
    
    NSString *dateString = [dateFormatter stringFromDate:transaction.createdAt];

    PFUser *user = [transaction objectForKey:@"user"];
    NSString *name = @"";
    if (user.isDataAvailable) name = [[user objectForKey:@"firstName"] uppercaseString];
    
    cell.leftLabel.text = [NSString stringWithFormat:@"%@ %@ %@", dateString, name,[[transaction objectForKey:@"type"] uppercaseString]];
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
