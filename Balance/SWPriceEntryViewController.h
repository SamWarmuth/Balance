//
//  SWPriceEntryViewController.h
//  Balance
//
//  Created by Samuel Warmuth on 3/26/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BButton.h"

@interface SWPriceEntryViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) void (^priceSelected)(NSNumber *price);
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *type;

- (IBAction)buttonPressed:(id)sender;

@end
