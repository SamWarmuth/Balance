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
    
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.price) self.textField.text = [NSString stringWithFormat:@"%.2f", round([self.price doubleValue])];
    if (self.buttonColor) self.button.color = self.buttonColor;
    if (self.buttonText) [self.button setTitle:self.buttonText forState:UIControlStateNormal];
    [self.textField becomeFirstResponder];
}

- (IBAction)buttonPressed:(id)sender
{
    NSNumber *number = @([self.textField.text doubleValue]);
    if ([number doubleValue] == 0) [SVProgressHUD showErrorWithStatus:@"Please enter a number."];
    if (self.priceSelected) self.priceSelected(number);
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
