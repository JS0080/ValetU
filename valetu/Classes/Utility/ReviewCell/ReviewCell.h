//
//  CommentCell.h
//  valetu
//
//  Created by imobile on 2016-09-14.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *review;
@property (weak, nonatomic) IBOutlet CircleImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedDate;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@end
