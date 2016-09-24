#import "GSKTwitterStretchyHeaderView.h"


static const CGFloat kMinHeaderImageHeight = 64;
static const CGFloat kNavigationTitleTop = 30;

@interface GSKTwitterStretchyHeaderView ()

@property (nonatomic) UIView *navigationBar;
@property (nonatomic) UIImageView *navigationBackground;
@property (nonatomic) UILabel *navigationBarTitle;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *menuButton;

@property (nonatomic) GMSMapView  *headerMapView;
@property (nonatomic) UIImageView *headerImageView;
@property (nonatomic) HCSStarRatingView *starRatingView;
@property (nonatomic) UIImageView *markerView;
@property (nonatomic) UIButton *getDirectionButton;
@property (nonatomic) UIButton *writeareviewButton;
@property (nonatomic) UIButton *returntocarButton;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *distanceLabel;
@property (nonatomic) UILabel *etaLabel;
@property (nonatomic) UILabel *estLabel;
@property (nonatomic) UILabel *placeLabel;
@property (nonatomic) UILabel *starLabel;

@property (nonatomic) CGFloat initialHeaderImageHeight;
@property (nonatomic) BOOL headerImageOnTop;

@end

@implementation GSKTwitterStretchyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        [self setupHeaderImageView];
        [self setupMapView];
        [self setupMarkerView];
        [self setupstarRatingView];
        [self setupgetDirectionButton];
        [self setupLabels];
        [self setupTabs];
        [self setupNavigationBar];

        [self fillSubviews];
        
        [self setupConstraints];

        self.maximumContentHeight = 360;
        self.minimumContentHeight = 106;
    }
    return self;
}

- (void)setupNavigationBar {
    self.navigationBar = [[UIView alloc] init];
    self.navigationBar.clipsToBounds = YES;
    [self.contentView addSubview:self.navigationBar];

    self.navigationBackground = [[UIImageView alloc] init];
    self.navigationBackground.contentMode = UIViewContentModeScaleAspectFill;
    self.navigationBackground.clipsToBounds = YES;
    [self.navigationBar addSubview:self.navigationBackground];
    
    self.backButton = [[UIButton alloc] init];
    [self.backButton setTitle:@"< Map" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.backButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.backButton];

    self.navigationBarTitle = [[UILabel alloc] init];
    self.navigationBarTitle.textColor = [UIColor whiteColor];
    self.navigationBarTitle.font = [UIFont boldSystemFontOfSize:19];
    [self.navigationBar addSubview:self.navigationBarTitle];

    self.menuButton = [[UIButton alloc] init];
    [self.menuButton setImage:[UIImage imageNamed:@"icMenuWhite.png"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.menuButton];
}

- (void)setupHeaderImageView {
    self.headerImageView = [[UIImageView alloc] init];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.headerImageView];
}

- (void) setupMapView
{
    self.headerMapView = [[GMSMapView alloc] init];
    [self.contentView addSubview:self.headerMapView];
}

- (void) setupMarkerView
{
    self.markerView = [[UIImageView alloc] init];
    self.markerView.clipsToBounds = YES;
    [self.contentView addSubview:self.markerView];
}

- (void)setupstarRatingView {
    self.starRatingView = [[HCSStarRatingView alloc] init];
    self.starRatingView.minimumValue = 0;
    self.starRatingView.maximumValue = 5;
    self.starRatingView.allowsHalfStars = YES;
    self.starRatingView.value = 0;
    self.starRatingView.backgroundColor = [UIColor clearColor];
    self.starRatingView.tintColor = [UIColor colorWithRed:255 green:179 blue:0 alpha:1];
    self.starRatingView.userInteractionEnabled = NO;
    [self.contentView addSubview:self.starRatingView];
}

- (void)setupgetDirectionButton {
    self.getDirectionButton = [[UIButton alloc] init];
    [self.getDirectionButton setBackgroundImage:[UIImage imageNamed:@"btnGetDir.png"] forState:UIControlStateNormal];
    self.getDirectionButton.clipsToBounds = YES;
     [self.getDirectionButton addTarget:self action:@selector(didTapDirection:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.getDirectionButton];
}

- (void)setupLabels
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.titleLabel];

    self.etaLabel = [[UILabel alloc] init];
    self.etaLabel.font = [UIFont systemFontOfSize:13];
    self.etaLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.etaLabel];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [UIFont boldSystemFontOfSize:15];
    self.distanceLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.distanceLabel];

    self.estLabel = [[UILabel alloc] init];
    self.estLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.contentView addSubview:self.estLabel];

    self.placeLabel = [[UILabel alloc] init];
    self.placeLabel.font = [UIFont systemFontOfSize:13];
    self.placeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.placeLabel];
    
    self.starLabel = [[UILabel alloc] init];
    self.starLabel.font = [UIFont systemFontOfSize:13];
    self.starLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.starLabel];
}

- (void)setupTabs {
    self.writeareviewButton = [[UIButton alloc] init];
    [self.writeareviewButton setBackgroundImage:[UIImage imageNamed:@"btnWriteReview.png"] forState:UIControlStateNormal];
    [self.writeareviewButton addTarget:self action:@selector(addReviewClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.writeareviewButton.clipsToBounds = YES;
    [self.contentView addSubview:self.writeareviewButton];
    
    self.returntocarButton = [[UIButton alloc] init];
    [self.returntocarButton setBackgroundImage:[UIImage imageNamed:@"btnReturn.png"] forState:UIControlStateNormal];
    [self.returntocarButton addTarget:self action:@selector(didReturntoCar:) forControlEvents:UIControlEventTouchUpInside];
    self.returntocarButton.clipsToBounds = YES;
    [self.contentView addSubview:self.returntocarButton];
}

- (void)fillSubviews {
    self.markerView.image = [UIImage imageNamed:@"icPlaceSmall.png"];

    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    self.navigationBarTitle.text = [parkinglot objectForKey:@"address"];
    self.titleLabel.text = [parkinglot objectForKey:@"address"];
    self.placeLabel.text = [parkinglot objectForKey:@"address"];
    self.estLabel.text = [parkinglot objectForKey:@"estimate"];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ Km", [parkinglot objectForKey:@"distance"]];
    int duration = [[parkinglot objectForKey:@"duration"] intValue];
    self.etaLabel.text = [NSString stringWithFormat:@"%d min", duration/60];
    double star = [[parkinglot objectForKey:@"star"] doubleValue];
    
    self.starRatingView.value = star;
    self.starLabel.text = [NSString stringWithFormat:@"%.1f", star];
    CLLocationCoordinate2D pickupLocation = CLLocationCoordinate2DMake([[parkinglot objectForKey:@"latitude"] doubleValue], [[parkinglot objectForKey:@"longitude"] doubleValue]);
    self.headerMapView.camera = [GMSCameraPosition cameraWithTarget:pickupLocation  zoom:11 bearing:0 viewingAngle:0];
    GMSMarker*  pickupMarker = [GMSMarker markerWithPosition:pickupLocation];
    pickupMarker.map = self.headerMapView;
    pickupMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeActive.png"]];
    
    NSArray* comments = [parkinglot objectForKey:@"comments"];
    if([comments count] > 0)
    {
        [self.navigationBackground sd_setImageWithURL:[NSURL URLWithString:[comments[0] objectForKey:@"photourl"]]
                            placeholderImage:[UIImage imageNamed:@"streetview.jpeg"]];
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[comments[0] objectForKey:@"photourl"]]
                                     placeholderImage:[UIImage imageNamed:@"intro1.png"]];
    } else
    {
        NSString *phtoUrl = [NSString stringWithFormat:GOOGLE_STREET_VIEW_API_BIG, [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:phtoUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image;
                if (!error) {
                   image = [UIImage imageWithData:data];
                } else{
                    image  =[UIImage imageNamed:@"streetview.jpeg"];
                }
                self.navigationBackground.image = image;
                self.headerImageView.image = image;
            });
        }] resume];
    }
}

- (void)setupConstraints {
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@64);
    }];

    [self.navigationBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    [self.navigationBarTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(@0).offset(kNavigationTitleTop);
    }];

    [self.menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0).offset(10);
        make.right.equalTo(@(-12));
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0);
        make.left.equalTo(@12);
    }];

    [self.writeareviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(37));
        make.bottom.equalTo(@(-6));
        make.left.equalTo(@(8));
        make.right.equalTo(self.contentView.mas_centerX).offset(-8);
    }];
    
    [self.returntocarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(37));
        make.bottom.equalTo(@(-6));
        make.right.equalTo(@(-8));
        make.left.equalTo(self.contentView.mas_centerX).offset(8);
    }];
    
    [self.headerMapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.right.equalTo(@(0));
        make.bottom.equalTo(self.writeareviewButton.mas_top).offset(-16);
        make.top.equalTo(self.writeareviewButton.mas_top).offset(-137);
    }];
    
    [self.markerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(12));
        make.height.equalTo(@(18));
        make.bottom.equalTo(self.writeareviewButton.mas_top).offset(-158);
        make.left.equalTo(@(16));
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.markerView.mas_bottom);
        make.left.equalTo(self.markerView.mas_right).offset(8);
    }];

    [self.etaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.titleLabel.mas_bottom);
        make.right.equalTo(self.returntocarButton.mas_right);
    }];
    
    [self.distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.etaLabel.mas_top).offset(-1);
        make.right.equalTo(self.returntocarButton.mas_right);
    }];

    [self.estLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.placeLabel.mas_top).offset(-4);
        make.left.equalTo(self.writeareviewButton.mas_left);
        make.right.equalTo(self.writeareviewButton.mas_right);
    }];
    
    [self.starRatingView mas_makeConstraints:^(MASConstraintMaker *  make) {
        make.width.equalTo(@(73));
        make.height.equalTo(@(12));
        make.bottom.equalTo(self.returntocarButton.mas_top).offset(-40);
        make.left.equalTo(self.writeareviewButton.mas_left);
    }];
    
    [self.placeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.starRatingView.mas_top).offset(-4);
        make.left.equalTo(self.writeareviewButton.mas_left);
    }];
    
    [self.starLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.starRatingView.mas_bottom);
        make.left.equalTo(self.starRatingView.mas_right).offset(8);
    }];

    [self.getDirectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(37));
        make.right.equalTo(self.returntocarButton.mas_right);
        make.left.equalTo(self.returntocarButton.mas_left);
        make.bottom.equalTo(self.returntocarButton.mas_top).offset(-33);
    }];

    [self remakeHeaderImageConstraints];
}

- (void)remakeHeaderImageConstraints {
    [self.headerImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        if (self.headerImageOnTop) {
            make.height.equalTo(@(kMinHeaderImageHeight));
        } else {
            make.bottom.equalTo(self.getDirectionButton.mas_top).offset(-67);
        }
    }];
}

- (void)updateNavigationTitleConstraints {
    [self.navigationBarTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat titleTop = MAX(kNavigationTitleTop, self.estLabel.top);
        make.top.equalTo(@0).offset(titleTop);
    }];
}

- (void)didChangeStretchFactor:(CGFloat)stretchFactor {
    [super didChangeStretchFactor:stretchFactor];
    if (self.initialHeaderImageHeight == 0) {
        return;
    }

    if (self.headerImageOnTop) {
        [self updateNavigationTitleConstraints];
        CGFloat navigationBackgroundAlpha = CGFloatTranslateRange(self.markerView.bottom, self.navigationBar.bottom, self.navigationBar.bottom - 8, 0, 1);
        self.navigationBackground.alpha = MIN(1, MAX(0, navigationBackgroundAlpha));

    } else {
        [self updateNavigationTitleConstraints];
        self.navigationBackground.alpha = 0;
    }
}

- (void)contentViewDidLayoutSubviews {
    [super contentViewDidLayoutSubviews];
    if (self.stretchFactor == 1 && self.initialHeaderImageHeight == 0) {
        self.initialHeaderImageHeight = self.headerImageView.height;
        [self didChangeStretchFactor:1];
    }

    if (self.headerImageOnTop) {
        if (self.markerView.top > self.headerImageView.bottom) {
            self.headerImageOnTop = NO;
            [self.contentView sendSubviewToBack:self.headerImageView];
            [self remakeHeaderImageConstraints];
            [self updateNavigationTitleConstraints];
        }
    } else {
        if (self.headerImageView.height <= 64) {
            self.headerImageOnTop = YES;
            [self.contentView bringSubviewToFront:self.headerImageView];
            [self.contentView bringSubviewToFront:self.navigationBar];
            [self remakeHeaderImageConstraints];
            [self updateNavigationTitleConstraints];
        }
    }
}

#pragma mark - Callbacks

- (void)backButtonPressed:(id)sender {
    [self.delegate headerView:self didTapBackButton:sender];
}

- (void) addReviewClicked: (id) sender
{
    [self.delegate headerView:self didAddReview:sender];
}

- (void) didReturntoCar: (id) sender
{
    [self.delegate headerView:self didReturntoCar:sender];
}

- (void) menuButtonPressed: (id) sender
{
    [self.delegate headerView:self didMenuPressed:sender];
}

- (void) didTapDirection: (id) sender
{
    [self.delegate headerView:self didTapDirection:sender];
}

@end
