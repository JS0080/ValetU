//
//  ReturnViewController.m
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ReturnViewController.h"


@interface ReturnViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, UBSDKModalViewControllerDelegate>
{
   __block UIButton *btnRideRequest;
    CLLocationManager *locationManager;
    __block GMSMarker* myMarker;
    NSMutableSet *lotMarkerSet;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *estimateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupTimeLabel;

@end

@implementation ReturnViewController
@synthesize builder;
@synthesize ridesClient;

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Return";
    self.contentSizeInPopup = CGSizeMake(300, 450);
    self.landscapeContentSizeInPopup = CGSizeMake(450, 300);
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.didFindMyLocation = NO;
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [self updateRideRequest];
    
    CLLocationCoordinate2D pickuplocation = [Parkinglot sharedModel].dropoffLocation.coordinate;
    CLLocationCoordinate2D dropofflocation = [Parkinglot sharedModel].pickupLocation.coordinate;
    
    self.mapView.camera = [GMSCameraPosition cameraWithTarget: pickuplocation zoom:11 bearing:0 viewingAngle:0];
    [self.mapView setMinZoom:3 maxZoom:20];
    
    GMSMarker*  pickupMarker = [GMSMarker markerWithPosition:pickuplocation];
    pickupMarker.map = self.mapView;
    GMSMarker*  dropoffMarker = [GMSMarker markerWithPosition:dropofflocation];
    dropoffMarker.map = self.mapView;
    
    pickupMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeActive.png"]];
    dropoffMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icPlace.png"]];
    
     NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
     self.estimateLabel.text = [parkinglot objectForKey:@"estimate"];

    [self showRoute:pickuplocation dropOff:dropofflocation withMap:self.mapView];
    [self initRideRequestButton];
}


- (void) updateRideRequest
{
    [iCommon getUberETAWithCompletion:[Parkinglot sharedModel].dropoffLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
            NSInteger m = (estimate / 60) % 60;
            self.pickupTimeLabel.text = [NSString stringWithFormat:@"PICK UP TIME IS APPROXIMATELY %lu MINS", m];
        });
    }];
}

- (void) initRideRequestButton
{
    NSInteger width = self.view.frame.size.width;
    NSInteger height = self.view.frame.size.height;
    
    builder = [[UBSDKRideParametersBuilder alloc] init];
    [builder setPickupLocation:[Parkinglot sharedModel].dropoffLocation];
    [builder setDropoffLocation:[Parkinglot sharedModel].pickupLocation];
    //  [builder setPickupLocation:location];
    UBSDKRideParameters *parameters = [builder build];
    
    // Assign the delegate when you initialize your UBSDKRideRequestViewRequestingBehavior
    UBSDKRideRequestViewRequestingBehavior *requestBehavior = [[UBSDKRideRequestViewRequestingBehavior alloc] initWithPresentingViewController:self];
    // Subscribe as the delegete
    requestBehavior.modalRideRequestViewController.delegate = self;
    
    btnRideRequest = [[UBSDKRideRequestButton alloc] initWithRideParameters: parameters requestingBehavior: requestBehavior];
    btnRideRequest.frame = CGRectMake(8, height-74, width-16, 44);
    
    [self.view addSubview:btnRideRequest];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake(60, 0, 160, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UBSDKModalViewControllerDelegate>

- (void)modalViewControllerDidDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"did dismiss");
}

- (void)modalViewControllerWillDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"will dismiss");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
