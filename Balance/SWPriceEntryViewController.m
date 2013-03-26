//
//  SWPriceEntryViewController.m
//  Balance
//
//  Created by Samuel Warmuth on 3/26/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWPriceEntryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"

@interface SWPriceEntryViewController ()

@property (nonatomic, strong) IBOutlet BButton *button;
@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic, strong) IBOutlet UITextField *textField;

- (IBAction)cancelTapped:(id)sender;

@end

@implementation SWPriceEntryViewController

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
    self.container.layer.cornerRadius = 4.0;
    if (!self.price) self.price = @0;
    
	// Do any additional setup after loading the view.
}

- (void)setPrice:(NSNumber *)price
{
    _price = price;
    [self updatePrice];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updatePrice];
    

    [self.textField becomeFirstResponder];
    
    NSString *buttonText;
    UIColor *buttonColor;
    
    if (!self.type) {
        buttonText = @"";
    } else if ([self.type isEqualToString:SWBUY]) {
        buttonText = @"BUY CHIPS";
    } else if ([self.type isEqualToString:SWSELL]) {
        buttonColor = GREEN;
        buttonText = @"SELL CHIPS";
    } else if ([self.type isEqualToString:SWPAY]) {
        buttonColor = RED;
        buttonText = @"PAY DEBT";
    }  else if ([self.type isEqualToString:SWCASHOUT]) {
        buttonColor = GREEN;
        buttonText = @"CASH OUT";
    }
    
    if (buttonColor) self.button.color = buttonColor;
    if (buttonText) [self.button setTitle:buttonText forState:UIControlStateNormal];
}

- (void)updatePrice
{
    if (self.price) self.textField.text = [NSString stringWithFormat:@"$%.2f", [self.price integerValue] / 100.0];
    else self.textField.text = @"$0.00";
}

- (IBAction)buttonPressed:(id)sender
{
    if ([self.price integerValue] == 0) return [SVProgressHUD showErrorWithStatus:@"Please enter an amount."];
    NSString *message = @"";
    NSString *title = @"confirm";
    NSString *priceString = [NSString stringWithFormat:@"$%.2f", [self.price integerValue] / 100.0];
    
    if (!self.type) {
        return;
    } else if ([self.type isEqualToString:SWBUY]) {
        title = @"Buy Chips";
        message = [NSString stringWithFormat:@"Buy %@ in chips\nfrom the house?", priceString];
    } else if ([self.type isEqualToString:SWSELL]) {
        title = @"Sell Chips";
        message = [NSString stringWithFormat:@"Sell %@ in chips\nto the house?", priceString];
    } else if ([self.type isEqualToString:SWPAY]) {
        title = @"Pay Debt";
        message = [NSString stringWithFormat:@"Pay %@ of your debt\n to the house?", priceString];
    }  else if ([self.type isEqualToString:SWCASHOUT]) {
        title = @"Cash Out";
        message = [NSString stringWithFormat:@"Cash out %@ of your\nbalance from the house?", priceString];
    }
    
    
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:title, nil];
    confirm.delegate = self;
    [confirm show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    if (self.priceSelected) self.priceSelected(self.price);
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger price = [self.price integerValue];

    if (string.length == 0) { //delete
        self.price = @(price/10);
    } else {
        NSInteger number = [string integerValue];
        self.price = @(price * 10 + number);
    }
    
    //limit to 1k
    if ([self.price integerValue] > 1000*100) self.price = @(1000 * 100);
    
    [self updatePrice];
    return FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
