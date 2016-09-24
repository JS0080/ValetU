#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>

@interface GSKNibStretchyHeaderView : GSKStretchyHeaderView

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *parkingLabel;
@property (weak, nonatomic) IBOutlet UILabel *spentLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;

@end
