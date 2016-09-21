//
//  NewAddressCell.m
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "NewAddressCell.h"

@implementation NewAddressCell
@synthesize starView;
@synthesize startValue;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)starChange:(id)sender {
    startValue.text = [NSString stringWithFormat:@"%d", (int)starView.value];
    [Parkinglot sharedModel].starValue = (NSInteger) starView.value;
}


@end
