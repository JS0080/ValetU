//
//  CircleImageView.m
//  Pipol
//
//  Created by HiTechLtd on 2/27/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#import "CircleImageView.h"

@implementation CircleImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _setupDefault];
}

- (void)_setupDefault {
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.borderColor = [[UIColor colorWithRed:226.0/255 green:226.0/255 blue:226.0/255 alpha:1] CGColor];
    self.layer.borderWidth = 1;
}

@end
