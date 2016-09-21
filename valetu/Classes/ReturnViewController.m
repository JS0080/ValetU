//
//  ReturnViewController.m
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ReturnViewController.h"


@interface ReturnViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate>
{
   __block UIButton *btnRideRequest;
    CLLocationManager *locationManager;
    __block GMSMarker* myMarker;
    NSMutableSet *lotMarkerSet;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation ReturnViewController
@synthesize builder;
@synthesize ridesClient;


- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.mapView.delegate = self;
    self.didFindMyLocation = NO;
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    self.ridesClient = [[UBSDKRidesClient alloc] init];
    
    [self createMarker:[Parkinglot sharedModel].selectedLocationId];
    
    [self initNavigation];
    
    [self initRideRequestButton];
    
    [self updateRideRequestButton];
    
    [Parkinglot sharedModel].isReturning = YES;
    
//    [ridesClient fetchPriceEstimatesWithPickupLocation:[Parkinglot sharedModel].dropoffLocation dropoffLocation:[Parkinglot sharedModel].pickupLocation completion:^(NSArray<UBSDKPriceEstimate *> * _Nonnull priceEstimates, UBSDKResponse * _Nonnull response) {
//        NSString* estimate = [NSString stringWithFormat:@"%ld~%ld", priceEstimates[0].lowEstimate, priceEstimates[0].highEstimate];
//        GMSMarker*  pickupMarker = [GMSMarker markerWithPosition:[Parkinglot sharedModel].dropoffLocation.coordinate];
//        GMSMarker*  dropoffMarker = [GMSMarker markerWithPosition:[Parkinglot sharedModel].pickupLocation.coordinate];
//        pickupMarker.map = self.mapView;
//        pickupMarker.userData = @{@"type": @"nearby"};
//        pickupMarker.iconView = [[UIImageView alloc] initWithImage:[self drawMarkerImage: estimate]];
//        dropoffMarker.userData = @{@"type": @"dest"};
//        dropoffMarker.map = self.mapView;
//    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
//    [self addPickupMarker];
    self.mapView.myLocationEnabled = true;
    
    [self checkUserState];
    
     if ([Parkinglot sharedModel].userState == kStateNone) {
         [self.navigationController popupController];
     }
}

- (GMSMarker*) createMarker: (NSInteger) i
{
    lotMarkerSet = [[NSMutableSet alloc] init];
    NSString* title = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"address"];

    GMSMarker *marker = [GMSMarker markerWithPosition:[Parkinglot sharedModel].pickupLocation.coordinate];
    marker.userData = @{@"type": @"dropoff"};
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    marker.flat = YES;
    marker.title = title;
    [lotMarkerSet addObject:marker];
    return marker;
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation; // meters
    [locationManager requestAlwaysAuthorization];
}

#pragma mark - location manager

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        self.mapView.myLocationEnabled = true;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CLLocation* myLocation  = change[NSKeyValueChangeNewKey];
    [Parkinglot sharedModel].currentLocation = myLocation;
    
    if (!self.didFindMyLocation) {
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:[Parkinglot sharedModel].dropoffLocation.coordinate  zoom:11 bearing:0 viewingAngle:0];
        
        self.mapView.settings.myLocationButton = true;
        self.mapView.settings.compassButton = YES;
        
        [self.mapView setMinZoom:3 maxZoom:20];
        
        self.didFindMyLocation = true;
        
        [self updateDestMarker:[Parkinglot sharedModel].dropoffLocation.coordinate];
    }
}

- (void) addPickupMarker
{
    myMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(41.8194152,-72.6562)];
    myMarker.flat = YES;
    myMarker.appearAnimation = kGMSMarkerAnimationPop;
    myMarker.map = nil;
    myMarker.userData = @{@"type": @"pickup"};
}

- (void) updateDestMarker: (CLLocationCoordinate2D) position
{
    [ridesClient fetchPriceEstimatesWithPickupLocation:[Parkinglot sharedModel].dropoffLocation dropoffLocation:[Parkinglot sharedModel].pickupLocation completion:^(NSArray<UBSDKPriceEstimate *> * _Nonnull priceEstimates, UBSDKResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *estimate = priceEstimates[0].estimate;
            UIImage* resultImg = [self drawMarkerImage: estimate];
            dispatch_async(dispatch_get_main_queue(), ^{
                myMarker = [GMSMarker markerWithPosition:position];
                myMarker.tracksViewChanges = YES;
                myMarker.flat = YES;
                myMarker.appearAnimation = kGMSMarkerAnimationPop;
                myMarker.map = self.mapView;
                myMarker.userData = @{@"type": @"pickup"};
                myMarker.iconView = [[UIImageView alloc] initWithImage:resultImg];
            });
        });
    }];
}

- (void) initRideRequestButton
{
    btnRideRequest = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    CGFloat x = 20.0f;
    CGFloat y = self.view.frame.size.height - 40;
    CGFloat width = self.view.frame.size.width - 40;
    CGFloat height = 40;
    btnRideRequest.frame = CGRectMake(x, y, width, height);
    btnRideRequest.layer.cornerRadius = 5;
    btnRideRequest.alpha = 1.0;
    [btnRideRequest setBackgroundColor:[UIColor blackColor]];
    btnRideRequest.tintColor = [UIColor whiteColor];
    [btnRideRequest setTitle:@"Get Ride" forState:UIControlStateNormal];
    [btnRideRequest addTarget:self action:@selector(initReturnScheduleForETA) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRideRequest];
}

- (void) updateRideRequestButton
{
   [self getUberETAWithCompletion:[Parkinglot sharedModel].dropoffLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
       NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
       NSUInteger m = (estimate / 60) % 60;
//       NSUInteger s = estimate % 60;
       
       NSString *away = [NSString stringWithFormat:@"%02lu", m];
       NSString* title = [NSString stringWithFormat:@"Get Ride     %@ mins away", away];
       dispatch_async(dispatch_get_main_queue(), ^{
           [btnRideRequest setTitle:title forState:UIControlStateNormal];
        [self showRoute:[Parkinglot sharedModel].dropoffLocation.coordinate dropOff:[Parkinglot sharedModel].pickupLocation.coordinate withMap:self.mapView];
       });
   }];
}

#pragma mark - GMSMapViewDelegate

- (void) mapView:		(GMSMapView *) 	mapView
didTapAtCoordinate:		(CLLocationCoordinate2D) 	coordinate
{
    // [self showDetailView];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL) mapView:		(GMSMapView *) 	mapView
    didTapMarker:		(GMSMarker *) 	marker
{
    NSString* type = [marker.userData objectForKey:@"type"];
    if (type == nil) {
        return NO;
    }
    else if ([type isEqualToString:@"pickup"])
    {
        //update user state
        [Parkinglot sharedModel].userState = kReturnPrepareRequestRide;
        
        [self updateRideRequestButton];
    }
    
    return NO;
}

- (void) noThankyou
{
    
}

- (void)initNavigation
{
    [super initNavigation];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(noThankyou)];
    
    [newBackButton setEnabled:FALSE];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    self.title = @"Return to car";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
