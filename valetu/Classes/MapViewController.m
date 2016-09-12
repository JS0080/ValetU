//
//  MapViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "MapViewController.h"
#import "SearchViewController.h"

@interface MapViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, PlaceSearchTextFieldDelegate, UITextFieldDelegate>
{
    CLLocationManager *locationManager;
    CLLocation* currentLocation;
    GMSMarker* myMarker;
    NSMutableSet *lotMarkerSet;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet MVPlaceSearchTextField *inputDest;

@end

@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didFindMyLocation = NO;
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
  
    [self initNavigation];
    
    [self initInputDest];
    
    self.mapView.delegate = self;

//    [NSTimer scheduledTimerWithTimeInterval:MAP_UPDATE_INTERVAL
//                                     target:self
//                                   selector:@selector(updateMap)
//                                   userInfo:nil
//                                    repeats:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initInputDestAfterViewAppear];
}

//- (void) updateMap
//{
//    self.didFindMyLocation = false;
//}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake([self.topLayoutGuide length] + 5, 0, [self.bottomLayoutGuide length] + 5, 0);
}

- (void) initInputDest
{
    self.inputDest.placeSearchDelegate                 = self;
    self.inputDest.strApiKey                           = @"AIzaSyCDi2dklT-95tEHqYoE7Tklwzn3eJP-MtM";
    self.inputDest.superViewOfList                     = self.view;  // View, on which Autocompletion list should be appeared.
    self.inputDest.autoCompleteShouldHideOnSelection   = NO;
    self.inputDest.maximumNumberOfAutoCompleteRows     = 5;
    self.inputDest.
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
}

- (void) addCurrentMarker
{
    myMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(41.8194152,-72.6562)];
    myMarker.flat = YES;
    myMarker.tracksViewChanges = YES;
//    myMarker.title = @"";
    myMarker.snippet = @"";
    myMarker.map = nil;
}

- (void) addMarker: (UIColor*) markerColor withTitle: (NSString*) title atDistance: (NSString*) distance atLocation: (CLLocationCoordinate2D) position
{
    GMSMarker* marker = [GMSMarker markerWithPosition:position];
    marker.icon = [GMSMarker markerImageWithColor:markerColor];
    marker.tracksViewChanges = YES;
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.flat = YES;
    marker.title = title;
    marker.snippet = distance;
    marker.infoWindowAnchor = CGPointMake(0.5, 0.5);
    marker.tracksInfoWindowChanges = YES;
    
    [lotMarkerSet addObject:marker];
}

- (UIView *_Nullable) mapView:		(GMSMapView *) 	mapView
           markerInfoContents:		(GMSMarker *) 	marker
{
    // infoWindow
    UIView* infoWindow = [[UIView alloc] init];
    UILabel *uberxRate = [[UILabel alloc] initWithFrame:CGRectMake(14, 42, 175, 16)];
    
    
    NSString* userData = marker.userData;
    if ([userData isEqualToString:@"myMarker"]) {
        NSLog(@"my Marker");
    } else {
        uberxRate.text = marker.title;
    }
   
   
    return infoWindow;
}

- (void) createMultipleMarkers
{
 //   [self.mapView clear];
    NSUInteger cnt = [[self app].nearbyplaces count];
    lotMarkerSet = [NSMutableSet setWithCapacity:cnt];
    for (int i = 0; i < cnt; i++) {
        NSString* title = [[self app].nearbyplaces[i] objectForKey:@"address"];
        NSString* distance = [NSString stringWithFormat:@"%.2lfKm", [[[self app].nearbyplaces[i] objectForKey:@"distance"] floatValue]];
        NSString* lat = [[self app].nearbyplaces[i] objectForKey:@"latitude"];
        NSString* lng = [[self app].nearbyplaces[i] objectForKey:@"longitude"];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
        [self addMarker:[UIColor blueColor] withTitle:title atDistance:distance atLocation:position];
    }
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    // Set a movement threshold for new events.
    locationManager.distanceFilter = kCLLocationAccuracyBest; // meters
    [locationManager requestWhenInUseAuthorization];
}


#pragma mark - location manager

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.myLocationEnabled = true;
      //  [locationManager startUpdatingLocation];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
        if (!self.didFindMyLocation) {
            
            CLLocation* myLocation  = change[NSKeyValueChangeNewKey];
//            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(41.8194152,-72.6562); // test
//            self.mapView.camera = [GMSCameraPosition cameraWithTarget:position zoom:14 bearing:0 viewingAngle:0];
            [self app].currentLocation = myLocation;
            self.mapView.camera = [GMSCameraPosition cameraWithTarget:myLocation.coordinate zoom:14 bearing:0 viewingAngle:0];
            
            self.mapView.settings.myLocationButton = true;
            self.mapView.settings.compassButton = YES;
            
            [self.mapView setMinZoom:8 maxZoom:20];
            
            self.didFindMyLocation = true;
          
            [self updateMarkerAndAddress: myLocation.coordinate];
        }
}

- (void) updateDestMarker: (CLLocationCoordinate2D) location title: (NSString*) title
{
    myMarker.position = location;
    myMarker.userData = @"myMarker";
    myMarker.title = title;
    myMarker.tracksViewChanges = YES;
    myMarker.appearAnimation = kGMSMarkerAnimationPop;
    myMarker.map = self.mapView;
}

- (void) mapView:		(GMSMapView *) 	mapView
didTapAtCoordinate:		(CLLocationCoordinate2D) 	coordinate
{
    [self.view endEditing:YES];
}

- (void) updateMarkerAndAddress: (CLLocationCoordinate2D) location
{
    id handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error == nil) {
            GMSReverseGeocodeResult *result = response.firstResult;
            [self updateDestMarker: location title:result.lines[1]];
            [self loadViewIfNeeded];
        }
    };

    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location completionHandler:handler];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
  //  [mapView clear];
}

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    
    self.mapView = mapView;
   
    [UIView animateWithDuration:5.0
                     animations:^{
                     //     myMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                     //    myMarker.position = cameraPosition.target;
                     }
                     completion:^(BOOL finished) {
                         // Stop tracking view changes to allow CPU to idle.
                         myMarker.tracksViewChanges = NO;
                     }];

}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
 //   [textField resignFirstResponder];
    return YES;
}

#pragma mark - Place search Textfield Delegates

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict{
    [self.view endEditing:YES];
    NSLog(@"SELECTED ADDRESS :%@",responseDict);
    
    CLLocationCoordinate2D myLocation = responseDict.coordinate;
    [self fetchNearbyResult:myLocation withCompletion:^{
        [self createMultipleMarkers];
        GMSCameraUpdate *vancouverCam = [GMSCameraUpdate setTarget:myLocation];
        [self.mapView animateWithCameraUpdate:vancouverCam];
        [self updateDestMarker: myLocation title:responseDict.formattedAddress];
    }];
}
-(void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField{
    
}
-(void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField{
    
}
-(void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index
{
    if(index%2==0){
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
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
