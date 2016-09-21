//
//  NewAddressCell.h
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UILabel *startValue;
@property (weak, nonatomic) IBOutlet UILabel *address;

@end
