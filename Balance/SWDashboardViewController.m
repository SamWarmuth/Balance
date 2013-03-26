//
//  SWDashboardViewController.m
//  Balance
//
//  Created by Samuel Warmuth on 3/25/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWDashboardViewController.h"
#import "SWPriceEntryViewController.h"
#import "SWLabelPriceCell.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface SWDashboardViewController ()

@property (nonatomic, strong) NSArray *transactions;
@property (nonatomic, strong) NSDate *lastLoad;
@property (nonatomic, strong) NSNumber *balance;

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
    self.cashOutButton.color = GRAY;
    self.sellChipsButton.color = GREEN;
    [self.cashOutButton setTitle:@"" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nameLabel.text = [[PFUser currentUser] objectForKey:@"name"];
    if (!self.lastLoad || [self.lastLoad timeIntervalSinceNow] * -1 > 60*60) [self updateBalanceAndTransactions];
}

- (void)updateBalanceAndTransactions
{
    [SVProgressHUD show];
    self.lastLoad = [NSDate date];
    [PFCloud callFunctionInBackground:@"balance" withParameters:@{} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            self.lastLoad = nil;
            NSLog(@"ERROR: %@ %@",error, result);
        } else {
            [SVProgressHUD dismiss];
            if (![result isKindOfClass:[NSNumber class]]) return [SVProgressHUD showErrorWithStatus:@"Error: Unexpected Response"];
            self.balance = (NSNumber *)result;
            
            [self updateUI];
        }
    }];
    
    [PFCloud callFunctionInBackground:@"transactions" withParameters:@{} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@",error, result);
        } else {
            [SVProgressHUD dismiss];
            if (![result isKindOfClass:[NSArray class]]) return [SVProgressHUD showErrorWithStatus:@"Error: Unexpected Response"];

            self.transactions = (NSArray *)result;
            [self.tableView reloadData];
        }
    }];
}

- (void)updateUI
{
    NSString *currencyString = [NSNumberFormatter localizedStringFromNumber:@([self.balance integerValue] / 100.0) numberStyle:NSNumberFormatterCurrencyStyle];
    self.balanceLabel.text = [NSString stringWithFormat:@"%@", currencyString];
    self.cashOutButton.alpha = 1.0;
    if ([self.balance integerValue] < 0) {
        self.balanceLabel.textColor = RED;
        self.cashOutButton.color = DARKGRAY;
        [self.cashOutButton setTitle:@"PAY DEBT" forState:UIControlStateNormal];
        self.cashOutButton.enabled = YES;
        
    }  else if ([self.balance integerValue] > 0) {

        self.balanceLabel.textColor = [UIColor blackColor];
        self.cashOutButton.color = DARKGRAY;
        [self.cashOutButton setTitle:@"CASH OUT" forState:UIControlStateNormal];
        self.cashOutButton.enabled = YES;
        
    } else {
        self.balanceLabel.textColor = [UIColor blackColor];
        self.cashOutButton.color = [UIColor darkGrayColor];
        [self.cashOutButton setTitle:@"EVEN" forState:UIControlStateNormal];
        self.cashOutButton.enabled = NO;
        self.cashOutButton.alpha = 0.5;
    }
    
    [self.tableView reloadData];
}

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

    [dateFormatter setDateFormat:@"M/d h:mma"];
    
    NSString *dateString = [dateFormatter stringFromDate:transaction.createdAt];
    
    cell.leftLabel.text = [NSString stringWithFormat:@"%@ %@", dateString, [[transaction objectForKey:@"type"] uppercaseString]];
    cell.rightLabel.text = currencyString;
    
    if (integerValue < 0) {
        cell.rightLabel.textColor = RED;
    } else {
        cell.rightLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)buyChipsTapped:(id)sender
{
    [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:@"buy"];
}



- (void)cashOutTapped:(id)sender
{
    if ([self.balance doubleValue] < 0) {
        [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:SWPAY];
    }  else if ([self.balance doubleValue] > 0) {
        [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:SWCASHOUT];
    } else {
        NSLog(@"Zero Debt");
    }
}

- (void)sellChipsTapped:(id)sender
{
    [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:SWSELL];
}

- (void)cashOut:(NSNumber *)amount
{
    [self makeTransaction:@"cashout" amount:amount];
}

- (void)buyChips:(NSNumber *)amount
{
    [self makeTransaction:@"buy" amount:amount];
}

- (void)sellChips:(NSNumber *)amount
{
    [self makeTransaction:@"sell" amount:amount];
}

- (void)payDebt:(NSNumber *)amount
{
    [self makeTransaction:@"pay" amount:amount];
}

- (void)makeTransaction:(NSString *)type amount:(NSNumber *)amount
{
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"makeTransaction" withParameters:@{@"amount":amount,@"type":type} block:^(NSObject *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@",error, result);
            
        } else {
            [SVProgressHUD dismiss];
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSDictionary *response = (NSDictionary *)result;
                if (response[@"balance"] && response[@"transaction"]) {
                    self.balance = response[@"balance"];
                    self.transactions = [@[response[@"transaction"]] arrayByAddingObjectsFromArray:self.transactions];
                    [self updateUI];
                } else {
                    [self updateBalanceAndTransactions];
                }
            }
        }
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SWDashboardToPriceEntry"]) {
        NSString *type = (NSString *)sender;
        SWPriceEntryViewController *destinationController = segue.destinationViewController;
        destinationController.type = type;
        if ([type isEqualToString:SWBUY]) {
            destinationController.priceSelected = ^(NSNumber *number) { [self buyChips:number]; };
        } else if ([type isEqualToString:SWSELL]) {
            destinationController.priceSelected = ^(NSNumber *number) { [self sellChips:number]; };
        } else if ([type isEqualToString:SWPAY]) {
            [destinationController setPrice:@([self.balance integerValue] * -1.0)];
            destinationController.priceSelected = ^(NSNumber *number) { [self payDebt:number]; };
        }  else if ([type isEqualToString:SWCASHOUT]) {
            [destinationController setPrice:@([self.balance integerValue])];
            destinationController.priceSelected = ^(NSNumber *number) { [self cashOut:number]; };
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
