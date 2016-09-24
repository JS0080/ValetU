	//
//  MapViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "MapViewController.h"
#import "SearchViewController.h"
#import "DetailViewController.h"

@interface MapViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, PlaceSearchTextFieldDelegate>
{
    CLLocationManager *locationManager;
    GMSMarker* myMarker;
    NSMutableSet *lotMarkerSet;

    BOOL isNavigationStart;
    __block  UBSDKRideRequestButton  *btnRideRequest;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet MVPlaceSearchTextField *inputDest;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailEST;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailviewBottomConstraint;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starValue;
@property (weak, nonatomic) IBOutlet UILabel *detailDistance;
@property (weak, nonatomic) IBOutlet UILabel *detailETA;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigation;
@property (weak, nonatomic) IBOutlet UILabel *pickuptime;

@end

@implementation MapViewController
@synthesize ridesClient;
@synthesize builder;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.didFindMyLocation = NO;
    
    ridesClient = [[UBSDKRidesClient alloc] init];
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [self initNavigation];
    
    [self initInputDest];
    
 //   [self initRideRequestButton];
    
//    [self initNavigationButton];
    
//    [self initTapGesture];
}

- (void) initTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
     tapRecognizer.numberOfTapsRequired = 1;
    [self.detailView addGestureRecognizer:tapRecognizer];
    
//    self.detailviewBottomConstraint.constant = -144;
}

- (void) initDetailView
{
    
}

- (void) respondToTapGesture: (id) sender
{
//    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
//    detailViewController.index = [Parkinglot sharedModel].selectedLocationId;
//    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initInputDestAfterViewAppear];
    

    [self startStandardUpdates];
    
 //   [self checkUserState];
    [self applyBlurToDetailView];
    
}

- (void) applyBlurToDetailView
{
    // create blur effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // create vibrancy effect
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
    
    // add blur to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add vibrancy to yet another effect view
    UIVisualEffectView *vibrantView = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
    vibrantView.frame = self.view.frame;
    
    // add both effect views to the image view
    [self.detailView addSubview:effectView];
    [self.detailView addSubview:vibrantView];

    self.detailView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
}

#pragma mark - Build MYBlurIntroductionView

-(void)buildIntro{
    
    
    //Create Panel From Nib
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"FirstIntro"];
    
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"SecondIntro"];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"ThirdIntro"];
    
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"ForthIntro"];
    
    
    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3, panel4];
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %ld", (long)panelIndex);
    
    //You can edit introduction view properties right from the delegate method!
    //If it is the first panel, change the color to green!
    if (panelIndex == 0) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    }
    //If it is the second panel, change the color to blue!
    else if (panelIndex == 1){
        [introductionView setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:0.65]];
    }
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"Introduction did finish");
    NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
    [defaultUser setBool:YES forKey:@"First"];
    [defaultUser synchronize];
}


- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.mapView.padding = UIEdgeInsetsMake(60, 0, 160, 0);
}

- (void) initNavigationButton
{
    self.btnNavigation.layer.cornerRadius = 5;
}

- (void) initRideRequestButton
{
    
    self.detailImage.layer.cornerRadius = 5;
 //   btnRideRequest.layer.cornerRadius = 5;
}



#pragma mark - <UBSDKModalViewControllerDelegate>

- (void)modalViewControllerDidDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"did dismiss");
}

- (void)modalViewControllerWillDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"will dismiss");
}


- (void) updateRideRequestButton
{
    [builder setPickupLocation:[Parkinglot sharedModel].pickupLocation];
    [builder setDropoffLocation:[Parkinglot sharedModel].dropoffLocation];
    
    UBSDKRideParameters *parameters = [builder build];
    
    [btnRideRequest setRideParameters:parameters];
    
    [iCommon getUberETAWithCompletion:[Parkinglot sharedModel].pickupLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
        NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
        NSUInteger m = (estimate / 60) % 60;
        //       NSUInteger s = estimate % 60;
        
        NSString* title = [NSString stringWithFormat:@"PICK UP TIME IS APPROXIMATELY %lu MINS", m];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pickuptime.text = title;
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
    self.inputDest.leftViewMode = UITextFieldViewModeAlways;
    self.inputDest.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icPlaceSmallRed.png"]];
    
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
   
    NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
    BOOL isFirstLaunch = [defaultUser boolForKey:@"First"];
    if (!isFirstLaunch) {
        [self buildIntro];
    }
}

- (IBAction)showMenu:(id) sender
{
    [self selectMenu: sender];
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
        
        [self addCurrentMarker];
//        [self updateDestMarker:myLocation.coordinate];
        [self loadViewIfNeeded];
    }
}

- (void) addCurrentMarker
{
    myMarker = [GMSMarker markerWithPosition:[Parkinglot sharedModel].currentLocation.coordinate];
    myMarker.flat = YES;
    myMarker.tracksViewChanges = YES;
    myMarker.appearAnimation = kGMSMarkerAnimationPop;
    myMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icPlace.png"]];
    myMarker.map = self.mapView;

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
     marker.userData = @{@"id": locationId, @"lat":[NSString stringWithFormat:@"%lf", position.latitude], @"lng": [NSString stringWithFormat:@"%lf", position.longitude], @"type": @"nearby", @"title": title};
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.iconView = [[UIImageView alloc] initWithImage:resultImg];
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.flat = YES;
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

- (void) updateDestMarker: (CLLocationCoordinate2D) position
{
    myMarker.position = position;

 //   myMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnParkHere.png"]];
    myMarker.map = self.mapView;
}

#pragma mark - GMSMapViewDelegate

- (void) mapView:		(GMSMapView *) 	mapView
didTapAtCoordinate:		(CLLocationCoordinate2D) 	coordinate
{
    [self showDetailView];
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
        
        [self updateDetailView:[marker.userData objectForKey:@"title"]];
    }
    
    return NO;
}

- (void) updateDetailView: (NSString*) title
{
    self.mapView.selectedMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnParkHere.png"]];
    self.detailTitle.text = title;
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    self.detailEST.text = [parkinglot objectForKey:@"estimate"];
    double star = [[parkinglot objectForKey:@"star"] doubleValue];
  
    self.starView.value = star;//;
    self.starValue.text = [NSString stringWithFormat:@"%.1f", star];
    self.detailETA.text = [NSString stringWithFormat:@"%d min", [[parkinglot objectForKey:@"duration"] intValue] / 60];
    self.detailDistance.text = [NSString stringWithFormat:@"%@ km", [parkinglot objectForKey:@"distance"]];
    NSArray* comments = [parkinglot objectForKey:@"comments"];
    if([comments count] > 0)
    {
        [self.detailImage sd_setImageWithURL:[NSURL URLWithString:[comments[0] objectForKey:@"photourl"]]
                            placeholderImage:[UIImage imageNamed:@"warning.png"]];
    } else
    {
        NSString *phtoUrl = [NSString stringWithFormat:GOOGLE_STREET_VIEW_API_SMALL, [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:phtoUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.detailImage.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
    
    [self loadViewIfNeeded];
}

- (IBAction) showNavigation: (id) sender
{
    if ([Parkinglot sharedModel].currentLocation.coordinate.latitude != [Parkinglot sharedModel].pickupLocation.coordinate.latitude || [Parkinglot sharedModel].currentLocation.coordinate.longitude != [Parkinglot sharedModel].pickupLocation.coordinate.longitude)
    {
        //update user state
        [Parkinglot sharedModel].userState = kUserStartNavigation;
        
     //   [self initScheduleForETA];
        
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
}

#pragma mark - Direction API

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict{
    [self.view endEditing:YES];
  
    CLLocationCoordinate2D myLocation = responseDict.coordinate;
    [self updateDestMarker:myLocation];
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
}

#pragma mark - Detail view

- (void) hideDetailView
{
    [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.detailviewBottomConstraint.constant = -173;
        self.detailView.alpha = 0;
    }completion:nil];
}

- (void) showDetailView
{
    [self.view endEditing:YES];
    
    if ([Parkinglot sharedModel].selectedLocationId < 0) {
        return;
    }

    [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.detailviewBottomConstraint.constant = 0;
        self.detailView.alpha = 1;
    }completion:nil];
}

- (IBAction)gotoDetailViewController:(id)sender
{
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [self.navigationController pushViewController:detailViewController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
