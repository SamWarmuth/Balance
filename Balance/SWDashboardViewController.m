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

#define RED [UIColor colorWithRed:0.805 green:0.026 blue:0.000 alpha:1.000]
#define GREEN [UIColor colorWithRed:0.000 green:0.542 blue:0.040 alpha:1.000]
#define GRAY [UIColor colorWithRed:0.518 green:0.518 blue:0.518 alpha:1]
#define BLUE [UIColor colorWithRed:0.00f green:0.33f blue:0.80f alpha:1.00f]
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
    if (!self.lastLoad || [self.lastLoad timeIntervalSinceNow] * -1 > 5*60) [self updateBalance];
}

- (void)updateBalance
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
            
            NSString *currencyString = [NSNumberFormatter localizedStringFromNumber:self.balance numberStyle:NSNumberFormatterCurrencyStyle];
            self.balanceLabel.text = [NSString stringWithFormat:@"%@", currencyString];
            
            if ([self.balance floatValue] < 0) {
                self.balanceLabel.textColor = RED;
                self.cashOutButton.color = RED;
                [self.cashOutButton setTitle:@"PAY DEBT" forState:UIControlStateNormal];
                self.cashOutButton.enabled = YES;
                
            }  else if ([self.balance floatValue] > 0) {
                self.balanceLabel.textColor = [UIColor blackColor];
                self.cashOutButton.color = GREEN;
                [self.cashOutButton setTitle:@"CASH OUT" forState:UIControlStateNormal];
                self.cashOutButton.enabled = YES;

            } else {
                self.balanceLabel.textColor = [UIColor blackColor];
                self.cashOutButton.color = GRAY;
                [self.cashOutButton setTitle:@"EVEN" forState:UIControlStateNormal];
                self.cashOutButton.enabled = NO;
            }
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
    NSString *currencyString = [NSNumberFormatter localizedStringFromNumber:(NSNumber *)[transaction objectForKey:@"amount"] numberStyle:NSNumberFormatterCurrencyStyle];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d h:mma"];
    NSString *dateString = [dateFormatter stringFromDate:transaction.createdAt];
    
    cell.leftLabel.text = [NSString stringWithFormat:@"%@ %@", dateString, [[transaction objectForKey:@"type"] uppercaseString]];
    cell.rightLabel.text = currencyString;
    cell.rightLabel.textColor = [UIColor colorWithRed:0.805 green:0.026 blue:0.000 alpha:1.000];
    return cell;
}

- (void)buyChipsTapped:(id)sender
{
    [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:@"buy"];
}

- (void)buyChips:(NSNumber *)amount
{
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"makeTransaction" withParameters:@{@"amount":amount,@"type":@"buy"} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@",error, result);
            
        } else {
            [self updateBalance];
            NSLog(@"RESULT: %@", result);
        }
    }];
}

- (void)cashOutTapped:(id)sender
{
    if ([self.balance floatValue] < 0) {
        NSLog(@"Pay Debt");
        [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:@"debt"];
    }  else if ([self.balance floatValue] > 0) {
        [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:@"cashout"];
    } else {
        NSLog(@"Zero Debt");
    }
}

- (void)sellChipsTapped:(id)sender
{
    [self performSegueWithIdentifier:@"SWDashboardToPriceEntry" sender:@"sell"];
}

- (void)cashOut:(NSNumber *)amount
{
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"makeTransaction" withParameters:@{@"amount":amount,@"type":@"cashout"} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@",error, result);
            
        } else {
            [self updateBalance];
            NSLog(@"RESULT: %@", result);
        }
    }];
}

- (void)sellChips:(NSNumber *)amount
{
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"makeTransaction" withParameters:@{@"amount":amount,@"type":@"sell"} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@",error, result);
            
        } else {
            [self updateBalance];
            NSLog(@"RESULT: %@", result);
        }
    }];
}

- (void)payDebt:(NSNumber *)amount
{
    [SVProgressHUD show];
    [PFCloud callFunctionInBackground:@"makeTransaction" withParameters:@{@"amount":amount,@"type":@"pay"} block:^(NSString *result, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"]];
            NSLog(@"ERROR: %@ %@",error, result);
            
        } else {
            [self updateBalance];
            NSLog(@"RESULT: %@", result);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SWDashboardToPriceEntry"]) {
        NSString *type = (NSString *)sender;
        SWPriceEntryViewController *destinationController = segue.destinationViewController;
        if ([type isEqualToString:@"buy"]) {
            destinationController.priceSelected = ^(NSNumber *number) { [self buyChips:number]; };
            destinationController.buttonText = @"BUY CHIPS";
        } else if ([type isEqualToString:@"sell"]) {
            destinationController.priceSelected = ^(NSNumber *number) { [self sellChips:number]; };
            destinationController.buttonColor = GREEN;
            destinationController.buttonText = @"SELL CHIPS";
        } else if ([type isEqualToString:@"debt"]) {
            [destinationController setPrice:@([self.balance doubleValue] * -1)];
            destinationController.priceSelected = ^(NSNumber *number) { [self payDebt:number]; };
            destinationController.buttonColor = RED;
            destinationController.buttonText = @"PAY DEBT";
        }  else if ([type isEqualToString:@"cashout"]) {
            [destinationController setPrice:@([self.balance doubleValue])];
            destinationController.priceSelected = ^(NSNumber *number) { [self cashOut:number]; };
            destinationController.buttonColor = GREEN;
            destinationController.buttonText = @"CASH OUT";
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
