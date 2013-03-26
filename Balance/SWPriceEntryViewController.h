//
//  SWPriceEntryViewController.h
//  Balance
//
//  Created by Samuel Warmuth on 3/26/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BButton.h"

@interface SWPriceEntryViewController : UIViewController

@property (nonatomic, copy) void (^priceSelected)(NSNumber *price);
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, strong) NSString *buttonText;

- (IBAction)buttonPressed:(id)sender;

@end
