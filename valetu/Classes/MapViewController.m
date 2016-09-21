	//
//  MapViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "MapViewController.h"
#import "SearchViewController.h"

static const NSUInteger kClusterItemCount = 10;
static const double kCameraLatitude = -33.8;
static const double kCameraLongitude = 151.2;

@interface MapViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, PlaceSearchTextFieldDelegate, GMUClusterManagerDelegate>
{
    CLLocationManager *locationManager;
//    CLLocation* currentLocation;
    GMSMarker* myMarker;
    NSMutableSet *lotMarkerSet;
    __block UIButton *btnRideRequest;

//    CLLocation *_pickupLocation;
//    CLLocation *_dropoffLocation;
    UIButton *btnNavigation;
    GMUClusterManager *_clusterManager;
    BOOL isNavigationStart;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet MVPlaceSearchTextField *inputDest;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailEST;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailviewBottomConstraint;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starValue;

@end

@implementation MapViewController
@synthesize ridesClient;
@synthesize builder;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.didFindMyLocation = NO;
    
    ridesClient = [[UBSDKRidesClient alloc] init];
    
    [_clusterManager setDelegate:self mapDelegate:self];
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [self initNavigation];
    
    [self initInputDest];
    
    [self initRideRequestButton];
    
    [self initNavigationButton];
    
    [self initTapGesture];
}

- (void) initTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
     tapRecognizer.numberOfTapsRequired = 1;
    [self.detailView addGestureRecognizer:tapRecognizer];
    
    self.detailviewBottomConstraint.constant = -90;
}

- (void) respondToTapGesture: (id) sender
{
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    detailViewController.index = [Parkinglot sharedModel].selectedLocationId;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void) initCluster {
    // Set up the cluster manager with a supplied icon generator and renderer.
    id<GMUClusterAlgorithm> algorithm =
    [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<GMUClusterIconGenerator> iconGenerator =
    [[GMUDefaultClusterIconGenerator alloc] init];
    id<GMUClusterRenderer> renderer =
    [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView
                                  clusterIconGenerator:iconGenerator];
    _clusterManager =
    [[GMUClusterManager alloc] initWithMap:_mapView
                                 algorithm:algorithm
                                  renderer:renderer];
    
    // Generate and add random items to the cluster manager.
    [self generateClusterItems];
    
    // Call cluster() after items have been added
    // to perform the clustering and rendering on map.
    [_clusterManager cluster];
}

- (void)generateClusterItems {
    const double extent = 0.2;
    for (int index = 1; index <= kClusterItemCount; ++index) {
        double lat = kCameraLatitude + extent * [self randomScale];
        double lng = kCameraLongitude + extent * [self randomScale];
        NSString *name = [NSString stringWithFormat:@"Item %d", index];
        id<GMUClusterItem> item =
        [[POIItem alloc] initWithPosition:CLLocationCoordinate2DMake(lat, lng)
                                     name:name];
        [_clusterManager addItem:item];
    }
}

// Returns a random value between -1.0 and 1.0.
- (double)randomScale {
    return (double)arc4random() / UINT32_MAX * 2.0 - 1.0;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initInputDestAfterViewAppear];
    
//    [Parkinglot sharedModel].userState = kParkinglotReview;
    
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake(60, 0, 160, 0);
}

- (void) initNavigationButton
{
    btnNavigation = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    CGFloat x = self.view.frame.size.width*3/4 + 20.0f;
    CGFloat y = self.view.frame.size.height - self.detailView.frame.size.height - 40;
    CGFloat width = 40;
    CGFloat height = 40;
    btnNavigation.frame = CGRectMake(x, y, width, height);
    btnNavigation.layer.cornerRadius = 5;
    btnNavigation.alpha = 0.0;
    [btnNavigation setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forState:UIControlStateNormal];
    [btnNavigation addTarget:self action:@selector(showNavigation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnNavigation];
}

- (void) initRideRequestButton
{
    btnRideRequest = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    CGFloat x =  20.0f;
    CGFloat y = self.view.frame.size.height - self.detailView.frame.size.height - 40;
    CGFloat width = self.view.frame.size.width - 80;
    CGFloat height = 40;
    btnRideRequest.frame = CGRectMake(x, y, width, height);
    btnRideRequest.layer.cornerRadius = 5;
    btnRideRequest.alpha = 0.0;
    [btnRideRequest setBackgroundColor:[UIColor blackColor]];
    btnRideRequest.tintColor = [UIColor whiteColor];
    [btnRideRequest setTitle:@"Get Ride" forState:UIControlStateNormal];
    [btnRideRequest addTarget:self action:@selector(initScheduleForETA) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRideRequest];
}

- (void) updateRideRequestButton
{
    [self getUberETAWithCompletion:[Parkinglot sharedModel].pickupLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
        NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
        NSUInteger m = (estimate / 60) % 60;
        //       NSUInteger s = estimate % 60;
        
        NSString *away = [NSString stringWithFormat:@"%02lu", m];
        NSString* title = [NSString stringWithFormat:@"Get Ride     %@ mins away", away];
        dispatch_async(dispatch_get_main_queue(), ^{
            [btnRideRequest setTitle:title forState:UIControlStateNormal];
        });
    }];
}

- (void) initInputDest
{
    self.inputDest.placeSearchDelegate                 = self;
    self.inputDest.strApiKey                           = @"AIzaSyCDi2dklT-95tEHqYoE7Tklwzn3eJP-MtM";
    self.inputDest.superViewOfList                     = self.view;  // View, on which Autocompletion list should be appeared.
    self.inputDest.autoCompleteShouldHideOnSelection   = NO;
    self.inputDest.maximumNumberOfAutoCompleteRows     = 4;
}

- (void) initInputDestAfterViewAppear
{
    //Optional Properties
    self.inputDest.autoCompleteRegularFontName =  @"HelveticaNeue-Bold";
    self.inputDest.autoCompleteBoldFontName = @"HelveticaNeue";
    self.inputDest.autoCompleteTableCornerRadius=0.0;
    self.inputDest.autoCompleteRowHeight=45;
    self.inputDest.autoCompleteTableCellTextColor=[UIColor colorWithWhite:0.131 alpha:1.000];
    self.inputDest.autoCompleteFontSize=14;
    self.inputDest.autoCompleteTableBorderWidth=1.0;
    self.inputDest.showTextFieldDropShadowWhenAutoCompleteTableIsOpen=YES;
    self.inputDest.autoCompleteShouldHideOnSelection=NO;
    self.inputDest.autoCompleteShouldHideClosingKeyboard=YES;
    self.inputDest.autoCompleteShouldSelectOnExactMatchAutomatically = YES;
    self.inputDest.autoCompleteTableFrame = CGRectMake((self.view.frame.size.width-self.inputDest.frame.size.width)*0.5, self.inputDest.frame.size.height+100.0, self.inputDest.frame.size.width, 200.0);
}

- (void)initNavigation
{
    [super initNavigation];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(listView:)];
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.title = @"Map";
}


- (void)listView:(id)sender {
    SearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    [self.navigationController pushViewController:searchViewController animated:YES];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self addCurrentMarker];
    [self startStandardUpdates];
    
    [self checkUserState];
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
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:myLocation.coordinate  zoom:11 bearing:0 viewingAngle:0];
        
        self.mapView.settings.myLocationButton = true;
        self.mapView.settings.compassButton = YES;
        
        [self.mapView setMinZoom:3 maxZoom:20];
        
        self.didFindMyLocation = true;
        
        [self updateMarkerAndAddress: myLocation.coordinate];
    }
}

- (void) addCurrentMarker
{
    myMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(41.8194152,-72.6562)];
    myMarker.flat = YES;
    myMarker.appearAnimation = kGMSMarkerAnimationPop;
    myMarker.map = nil;
}

- (GMSMarker*) createMarker: (NSInteger) i
{
    NSString* locationId = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"id"];
    NSString* title = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"address"];
    NSString* estimate = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"estimate"];
    CLLocationDegrees lat = [[[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees lng = [[[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lng);
    
    UIImage* resultImg = [self drawMarkerImage: estimate];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
     marker.userData = @{@"id": locationId, @"lat":[NSString stringWithFormat:@"%lf", position.latitude], @"lng": [NSString stringWithFormat:@"%lf", position.longitude], @"type": @"nearby"};
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.iconView = [[UIImageView alloc] initWithImage:resultImg];
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.flat = YES;
    marker.title = title;
    [lotMarkerSet addObject:marker];
    return marker;
}

- (void) createMultipleMarkers
{
    NSUInteger cnt = [[Parkinglot sharedModel].nearbyplaces count];
    lotMarkerSet = [[NSMutableSet alloc] initWithCapacity:cnt];
    for (int i = 0; i < cnt; i++) {
        [self createMarker: i];
    }
}

- (void) updateDestMarker: (CLLocationCoordinate2D) position title: (NSString*) title eta: (NSString*) eta
{
    myMarker.position = position;
    myMarker.userData = @{@"lat":[NSString stringWithFormat:@"%lf", position.latitude], @"lng": [NSString stringWithFormat:@"%lf", position.longitude], @"type": @"dest"};
    myMarker.title = title;
    myMarker.snippet = [NSString stringWithFormat:@"ETA to here is about %@", eta];
    myMarker.tracksViewChanges = YES;
    myMarker.appearAnimation = kGMSMarkerAnimationPop;
    myMarker.map = self.mapView;
}

- (void) updateMarkerAndAddress: (CLLocationCoordinate2D) location
{
    id handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error == nil) {
            GMSReverseGeocodeResult *result = response.firstResult;
            [self updateDestMarker: location title:result.lines[1] eta:@""];
            [self loadViewIfNeeded];
        }
    };
    
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location completionHandler:handler];
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
    else if ([type isEqualToString:@"nearby"])
    {
        //update user state
        [Parkinglot sharedModel].userState = kUserSelectParkinglot;
        
        [Parkinglot sharedModel].selectedLocationId = [[marker.userData objectForKey:@"id"] integerValue];
        
        CLLocationDegrees latitide = [[marker.userData objectForKey:@"lat"] doubleValue];
        CLLocationDegrees longitude = [[marker.userData objectForKey:@"lng"] doubleValue];
        CLLocationCoordinate2D pickup_location = CLLocationCoordinate2DMake(latitide, longitude);
        [Parkinglot sharedModel].pickupLocation = [[CLLocation alloc] initWithLatitude:latitide longitude:longitude];
        
        [self updateRideRequestButton];
        
        [self showRoute:pickup_location dropOff:[Parkinglot sharedModel].dropoffLocation.coordinate withMap:self.mapView];
        
        [self updateDetailView:marker.title];
    }
    
    return NO;
}

- (void) updateDetailView: (NSString*) title
{
    self.detailTitle.text = title;
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    self.detailEST.text = [parkinglot objectForKey:@"estimate"];
//    self.starView.value = [[parkinglot objectForKey:@"star"] doubleValue];
//    self.starValue.text = [parkinglot objectForKey:@"star"];
    NSArray* comments = [parkinglot objectForKey:@"comments"];
    if([comments count] > 0)
    {
        [self.detailImage sd_setImageWithURL:[NSURL URLWithString:[comments[0] objectForKey:@"photourl"]]
                            placeholderImage:[UIImage imageNamed:@"warning.png"]];
    } else
    {
        self.detailImage.image = [UIImage imageNamed:@"warning.png"];
    }
}

- (void) showNavigation: (id) sender
{
    if ([Parkinglot sharedModel].currentLocation.coordinate.latitude != [Parkinglot sharedModel].pickupLocation.coordinate.latitude || [Parkinglot sharedModel].currentLocation.coordinate.longitude != [Parkinglot sharedModel].pickupLocation.coordinate.longitude)
    {
        //update user state
        [Parkinglot sharedModel].userState = kUserStartNavigation;
        
        [self initScheduleForETA];
        
        if ([[UIApplication sharedApplication]
             canOpenURL:[NSURL URLWithString:@"waze://"]]) {
            
            // Waze is installed. Launch Waze and start navigation
            NSString *urlStr =
            [NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes",
             [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            
            // local notification
            isNavigationStart = YES;
            [self launchLocalNotificationWithoutAction:NAVIGATION_START];
            
        } else {
            // Waze is not installed. Launch AppStore to install Waze app
            [[UIApplication sharedApplication] openURL:[NSURL
                                                        URLWithString:@"https://itunes.apple.com/us/app/id323229106"]];
        }
    }
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
  //  [mapView clear];
    [self hideDetailView];
}

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    
    self.mapView = mapView;
    
    if ([Parkinglot sharedModel].selectedLocationId < 0) {
        [self hideDetailView];
    } else {
        [self showDetailView];
    }
   
//    [UIView animateWithDuration:5.0
//                     animations:^{
//                     //     myMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
//                     //    myMarker.position = cameraPosition.target;
//                     }
//                     completion:^(BOOL finished) {
//                         // Stop tracking view changes to allow CPU to idle.
//                       //  myMarker.tracksViewChanges = NO;
//                     }];

}

#pragma mark - Direction API

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict{
    [self.view endEditing:YES];
  
    CLLocationCoordinate2D myLocation = responseDict.coordinate;
    [self updateDestMarker:myLocation title:responseDict.formattedAddress eta:@""];
    [Parkinglot sharedModel].dropoffLocation = [[CLLocation alloc] initWithLatitude:myLocation.latitude longitude:myLocation.longitude];
    GMSCameraUpdate *newDest = [GMSCameraUpdate setTarget:myLocation];
    [self.mapView animateWithCameraUpdate:newDest];
    
    [self fetchNearbyResult:myLocation withCompletion:^{
        [self createMultipleMarkers];
    }];
}
-(void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField{
    
  }

-(void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField{
    
  }

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index
{
//    if(index%2==0){
//        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
//    }else{
//        cell.contentView.backgroundColor = [UIColor whiteColor];
//    }
}

#pragma mark - Detail view

- (IBAction)closeDetailView:(id)sender {
    [self hideDetailView];
}

- (void) hideDetailView
{
    [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.detailView setAlpha:0.0];
        self.detailviewBottomConstraint.constant = -90;
        btnNavigation.alpha = 0.0;
        btnRideRequest.alpha = 0.0;
        [self.navigationController setNavigationBarHidden:YES];
//        [self.detailView setHidden:YES];
    }completion:nil];
}

- (void) showDetailView
{
    [self.view endEditing:YES];
    
    if ([Parkinglot sharedModel].selectedLocationId < 0) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    self.detailviewBottomConstraint.constant = 90;

    [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.detailView setAlpha:1.0];
        self.detailviewBottomConstraint.constant = 0;
        btnNavigation.alpha = 1.0;
        btnRideRequest.alpha = 1.0;

    }completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
