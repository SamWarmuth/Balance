//
//  SWLoginViewController.m
//  Balance
//
//  Created by Samuel Warmuth on 3/25/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWLoginViewController.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface SWLoginViewController ()

@end

@implementation SWLoginViewController

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
	// Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"SWLoginToDashboard" sender:self];
    }
}

- (IBAction)loginTapped:(id)sender
{
    NSArray *permissionsArray = @[@"user_about_me"];
    
    [SVProgressHUD show];
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Uh oh. An error occurred: %@", error]];
            }
        } else {
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Uh oh. An error occurred: %@", error]];
                } else {
                    NSDictionary *userData = (NSDictionary *)result;
                    [user setObject:userData[@"first_name"] forKey:@"firstName"];
                    [user setObject:userData[@"last_name"] forKey:@"lastName"];
                    [user setObject:userData[@"name"] forKey:@"name"];

                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [SVProgressHUD dismiss];
                        [self performSegueWithIdentifier:@"SWLoginToDashboard" sender:self];
                    }];
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
