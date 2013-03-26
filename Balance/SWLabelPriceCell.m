//
//  SWLabelPriceCell.m
//  Balance
//
//  Created by Samuel Warmuth on 3/25/13.
//  Copyright (c) 2013 Sam Warmuth. All rights reserved.
//

#import "SWLabelPriceCell.h"

@implementation SWLabelPriceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.leftLabel = [[SWLabel alloc] init];
    self.leftLabel.textAlignment = NSTextAlignmentLeft;
    self.leftLabel.backgroundColor = [UIColor clearColor];
    self.leftLabel.minimumScaleFactor = 0.5;
    self.rightLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.leftLabel];
    
    self.rightLabel = [[SWLabel alloc] init];
    self.rightLabel.textAlignment = NSTextAlignmentRight;
    self.rightLabel.backgroundColor = [UIColor clearColor];
    self.rightLabel.minimumScaleFactor = 0.5;
    self.rightLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.rightLabel];
    [self updateFrames];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)updateFrames
{
    CGFloat leftOffset = 20.0;
    CGFloat rightOffset = 20.0;
    CGRect contentFrame = self.contentView.bounds;
    self.leftLabel.frame  = CGRectMake(contentFrame.origin.x + leftOffset, contentFrame.origin.y, contentFrame.size.width - (leftOffset + rightOffset), contentFrame.size.height - 2);
    self.rightLabel.frame = CGRectMake(contentFrame.origin.x + 90.0, contentFrame.origin.y, contentFrame.size.width - (rightOffset) - 90.0, contentFrame.size.height - 2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
