//
//  BaseViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewController.h"
#import "NewProfileTableViewController.h"
#import "ReviewControllerViewController.h"
#import "ReturnViewController.h"
#import "MapViewController.h"

@interface BaseViewController ()<CLLocationManagerDelegate, RNGridMenuDelegate, STPopupControllerTransitioning >{
    CLLocationManager *locationManager;
    NSTimer* valetuScheduleTimer;
    NSTimer* valetuReturnScheduleTimer;
}

@end

@implementation BaseViewController

@synthesize selectedRoute;
@synthesize overviewPolyline;
@synthesize totalDuration;
@synthesize totalDistance;
@synthesize ridesClient;
@synthesize builder;


//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ridesClient = [[UBSDKRidesClient alloc] init];
    
 //   [self registerPostNotification];
    
 //   [self initLocalNofification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];


}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void) checkUserState
{
    NSLog(@"state %ld", [Parkinglot sharedModel].userState);
    if ([Parkinglot sharedModel].userState == kParkinglotReview) {
        [self showReviewWindow];
    }
}

- (void) registerPostNotification
{
    // post notification from local notifiaction action
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideUber:) name:Ride_Uber_IDENTIFIRE object:nil];
    
    // post notification about entering background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) rideUber: (id) sender
{
    [self rideRequest];
}

- (void) initLocalNofification
{
    UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (notificationSettings.types == UIUserNotificationTypeNone) {
        UIUserNotificationType notificationType = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIMutableUserNotificationAction *rideUberAction = [[UIMutableUserNotificationAction alloc] init];
        rideUberAction.identifier = Ride_Uber_IDENTIFIRE;
        rideUberAction.title = Ride_Uber_IDENTIFIRE;
        rideUberAction.activationMode = UIUserNotificationActivationModeBackground;
        rideUberAction.destructive = NO;
        rideUberAction.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *notYetAction = [[UIMutableUserNotificationAction alloc] init];
        notYetAction.identifier = NOT_YET_IDENTIFIRE;
        notYetAction.title = NOT_YET_IDENTIFIRE;
        notYetAction.activationMode = UIUserNotificationActivationModeBackground;
        notYetAction.destructive = NO;
        notYetAction.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *okAction = [[UIMutableUserNotificationAction alloc] init];
        okAction.identifier = OK_IDENTIFIRE;
        okAction.title = OK_IDENTIFIRE;
        okAction.activationMode = UIUserNotificationActivationModeBackground;
        okAction.destructive = NO;
        okAction.authenticationRequired = NO;
        
        UIMutableUserNotificationCategory *rideCategory = [[UIMutableUserNotificationCategory alloc] init];
        UIMutableUserNotificationCategory *defaultCategory = [[UIMutableUserNotificationCategory alloc] init];
        
        rideCategory.identifier = NOTIFICATION_CATEGORY;
        defaultCategory.identifier = DEFAULT_CATEGORY;
        
        [rideCategory setActions:@[rideUberAction, notYetAction] forContext:UIUserNotificationActionContextDefault];
        [rideCategory setActions:@[rideUberAction, notYetAction] forContext:UIUserNotificationActionContextMinimal];
        
        [defaultCategory setActions:@[okAction] forContext:UIUserNotificationActionContextDefault];
        [defaultCategory setActions:@[okAction] forContext:UIUserNotificationActionContextMinimal];
        
        NSSet *categories = [NSSet setWithObjects:rideCategory, defaultCategory, nil];
        
        notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
}

- (void)initNavigation {
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
//    shadow.shadowOffset = CGSizeMake(0, 1);
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
//                                                           shadow, NSShadowAttributeName,
//                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0], NSFontAttributeName, nil]];

    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(selectMenu:)];
    
    
  //  self.navigationController.navigationBar.barTintColor = HEXCOLOR(0x8C2421);
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}


- (void) selectMenu: (id) sender {
    [self.view endEditing:YES];
    
    NSError *error;
    FAKFontAwesome *logoutIcon = [FAKFontAwesome  iconWithIdentifier:@"fa-sign-out" size:15 error:&error];
    UIImage *logoutImage = [logoutIcon imageWithSize:CGSizeMake(15, 15)];
    
    FAKFontAwesome *profileIcon = [FAKFontAwesome  iconWithIdentifier:@"fa-user" size:15 error:&error];
     UIImage *profileImage = [profileIcon imageWithSize:CGSizeMake(15, 15)];
    
    NSArray *menuItems = @[
                           [[RNGridMenuItem alloc] initWithImage:profileImage title:@"Profile"],
                           ];
    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
    gridMenu.delegate = self;
    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
}

//------ grid menu delgate -------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [gridMenu dismissAnimated:NO];
    if ([item.title isEqualToString:@"Profile"])    [self viewProfile];
}



-(void) calculateTotalDistanceAndDuration
{
    id legs = [selectedRoute[0] objectForKey:@"legs"];
    
     totalDistanceInMeters = 0;
     totalDurationInSeconds = 0;
    
    for (id leg in legs) {
        totalDistanceInMeters  += [[[[leg objectForKey:@"distance"] objectForKey:@"distance" ] objectForKey:@"value" ] intValue];
        totalDurationInSeconds += [[[[leg objectForKey:@"duration"] objectForKey:@"duration" ] objectForKey:@"value" ] intValue];
    }
    
    
    double distanceInKilometers = totalDistanceInMeters / 1000.0;
    totalDistance = [NSString stringWithFormat:@"Total Distance: %f Km", distanceInKilometers];
    
    
    NSUInteger mins = totalDurationInSeconds / 60;
    NSUInteger hours = mins / 60;
    NSUInteger days = hours / 24;
    NSUInteger remainingHours = hours % 24;
    NSUInteger remainingMins = mins % 60;
    NSUInteger remainingSecs = totalDurationInSeconds % 60;
    
    totalDuration = [NSString stringWithFormat:@"Duration: %lu d, %lu h, %lu mins, %lu secs", (unsigned long)days, (unsigned long)remainingHours, (unsigned long)remainingMins, (unsigned long)remainingSecs ];
}

- (void) getDirectionAtStart: (CLLocationCoordinate2D) startLocation toEnd: (CLLocationCoordinate2D) endLocation withCompletion:(void (^)(NSString* string, BOOL status))completionBlock
{
    CGFloat start_lat = startLocation.latitude;
    CGFloat start_lng = startLocation.longitude;
    CGFloat end_lat = endLocation.latitude;
    CGFloat end_lng = endLocation.longitude;
    
    NSString* urlForRoute = [NSString stringWithFormat:@"%@&origin=%f,%f&destination=%f,%f", DIRECTION_ROUTE_ENDPOINT, start_lat, start_lng, end_lat, end_lng];
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:urlForRoute parameters:nil  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSString* status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            selectedRoute = [responseObject objectForKey:@"routes"];
            overviewPolyline = [selectedRoute[0] objectForKey:@"overview_polyline"];
            
            [self calculateTotalDistanceAndDuration];
            
            completionBlock(@"Success", YES);
        }
      
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        completionBlock(error.localizedDescription, NO);
    }];
}

- (void) getETAWithCompletion: (void (^)(NSDictionary* duration, NSString* string, BOOL status))completionBlock
{
    NSString* etaEndpoint = [NSString stringWithFormat:@"%@&origins=%f,%f&destinations=%f,%f", DISTANCE_MATRIX_ENDPOINT, [Parkinglot sharedModel].currentLocation.coordinate.latitude, [Parkinglot sharedModel].currentLocation.coordinate.longitude, [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:etaEndpoint parameters:nil  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSString* status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            NSArray* rows = [responseObject objectForKey:@"rows"];
            NSArray* elements = [rows[0] objectForKey:@"elements"];
            NSDictionary* duration = [elements[0] objectForKey:@"duration"];
            
            if (duration == nil) {
                completionBlock(nil, @"Cannot calculate ETA", NO);
            } else {
                completionBlock(duration, @"Ok", YES);
            }
        } else{
           completionBlock(nil, @"Cannot calculate ETA", NO);
        }
        
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        completionBlock(nil, error.localizedDescription, NO);
    }];
}

- (void) fetchNearbyResult: (CLLocationCoordinate2D) location withCompletion: (void (^)(void))completionBlock
{
    NSString* lat = [NSString stringWithFormat:@"%lf", location.latitude ];
    NSString* lng = [NSString stringWithFormat:@"%lf", location.longitude ];
    NSDictionary *body = @{@"lat": lat, @"lng": lng};
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:WS_FETCH_NEARBY parameters:body  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        //        NSLog(@"%@", responseObject);
        NSString* status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"Ok"]) {
            [Parkinglot sharedModel].nearbyplaces = [responseObject objectForKey:@"data"];
            if (completionBlock != nil) {
                completionBlock();
            }
        }
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void) postUberRequest:(NSDictionary*) uberData WithCompletion: (void (^)(NSDictionary* requestResponse, NSString* string, BOOL status))completionBlock
{
    NSString* authHeader = [NSString stringWithFormat:@"Bearer %@", [UBSDKTokenManager fetchToken].tokenString];
    
    SWPOSTRequest *postRequest = [[SWPOSTRequest alloc]init];
    [postRequest.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [postRequest.request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    postRequest.responseDataType = [SWResponseJSONDataType type];
    
    NSString *start_latitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].pickupLocation.coordinate.latitude];
    NSString *start_longitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
    NSString *end_latitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].dropoffLocation.coordinate.latitude];
    NSString *end_longitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].dropoffLocation.coordinate.longitude];
    
    NSDictionary* params = @{@"start_latitude": start_latitude, @"start_longitude": start_longitude, @"end_latitude": end_latitude, @"end_longitude": end_longitude, @"product_id": [uberData objectForKey:@"product_id"]};
    
        [postRequest startDataTaskWithURL:URL_UBER_SANDBOX_REQUESTS parameters:params parentView:nil cachedData:^(NSCachedURLResponse *response, id responseObject) {
            NSLog(@"%@", responseObject);
        } success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
            NSLog(@"%@", responseObject);
            completionBlock(responseObject, @"Ok", YES);
        } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
            NSLog(@"%@", error);
            completionBlock(nil, error.localizedDescription, NO);
        }];
}

- (void) launchLocalNotificationWithoutAction: (NSString*) body
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = body;//@"24 hours passed since last visit :(";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = @{@"message": body};
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void) launchLocalNotification: (NSString*) body withAction: (NSString*) action withCategory: (NSString*) category
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = body;
    notification.userInfo = @{@"message": body};
    notification.alertAction = action;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.category = category; //  Same as category identifier
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)applicationEnterBackground{
    if ([Parkinglot sharedModel].userState < kUserSelectParkinglot){
        return;
    }
    
    [Parkinglot sharedModel].isBackgroundRunning = YES;
    
    //Use the BackgroundTaskManager to manage all the background Task
    [Parkinglot sharedModel].bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [[Parkinglot sharedModel].bgTask beginNewBackgroundTask];
    
    if ([Parkinglot sharedModel].userState < kReturnPrepareRequestRide) {
         [self initScheduleForETA];
    } else {
        [self initReturnScheduleForETA];
    }
}

- (void) initReturnScheduleForETA
{
    if (valetuReturnScheduleTimer == nil) {
        valetuReturnScheduleTimer =  [NSTimer scheduledTimerWithTimeInterval:CALCULATE_ETA_INTERVAL
                                                                target:self
                                                              selector:@selector(runReturnValetU)
                                                              userInfo:nil
                                                               repeats:YES];
    }
}


- (void) initScheduleForETA
{
    if (valetuScheduleTimer == nil) {
        valetuScheduleTimer =  [NSTimer scheduledTimerWithTimeInterval:CALCULATE_ETA_INTERVAL
                                                          target:self
                                                        selector:@selector(runValetU)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void) runReturnValetU
{
    NSLog(@"state %ld", (long)[Parkinglot sharedModel].userState);
    
    if ([Parkinglot sharedModel].isReturning && [Parkinglot sharedModel].userState <= kReturnPrepareRequestRide) {
        [self returnRideRequest];
    }
    else if ([Parkinglot sharedModel].userState >= kReturnRideRequestAccepted) {
        [self updateRequestForTest:^{
            [Parkinglot sharedModel].userState = kRequestCompleted;
            [self launchLocalNotification:REQUEST_COMPLETED withAction:@"" withCategory:DEFAULT_CATEGORY];
            [valetuReturnScheduleTimer invalidate];
            valetuReturnScheduleTimer = nil;
            [Parkinglot sharedModel].userState = kParkinglotReview;

            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.navigationController popViewControllerAnimated:YES];
//                ReviewControllerViewController* reviewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewControler"];
//                [self.navigationController pushViewController:reviewController animated:YES];
                [self showReviewWindow];
            });
        }];
    }
}

-(void) myMethod
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showReviewWindow];
    });
}

- (void) returnRideRequest
{
    [ridesClient fetchCheapestProductWithPickupLocation: [Parkinglot sharedModel].dropoffLocation completion:^(UBSDKUberProduct* _Nullable product, UBSDKResponse* _Nullable response) {
        if (product) {
            [Parkinglot sharedModel].product = product;
            NSLog(@"product ID %@ %@", product.productID, product.name);
            [Parkinglot sharedModel].userState = kReturnPrepareRequestRide;
            [self launchLocalNotification:REQUES_RETURN_RIDE withAction:Ride_Uber_IDENTIFIRE withCategory:NOTIFICATION_CATEGORY];
            
        }
    }];
}

- (void) runValetU
{
    NSLog(@"userstate %ld", [Parkinglot sharedModel].userState);
    
    if ([Parkinglot sharedModel].userState <= kUserPrepareRequestRide) {
        if ([Parkinglot sharedModel].userState < kFiveMinutesLeft) {
            [self calulateETA:^{
                //  if ([[duration objectForKey:@"value"] intValue] < 360) {
                //update user state
                [Parkinglot sharedModel].userState = kFiveMinutesLeft;
                [self fetchCheapestProduct:^{
                    if ([Parkinglot sharedModel].userState == kUserPrepareRequestRide) {
                        [self launchLocalNotification:REQUEST_RIDE_MESSAGE withAction:Ride_Uber_IDENTIFIRE withCategory:NOTIFICATION_CATEGORY];
                    }
                }];
                 // }
            }];
            
        } else {
            [self fetchCheapestProduct:^{
                if ([Parkinglot sharedModel].userState == kUserPrepareRequestRide) {
                    [self launchLocalNotification:REQUEST_RIDE_MESSAGE withAction:Ride_Uber_IDENTIFIRE withCategory:NOTIFICATION_CATEGORY];
                }
            }];
        }
    }
    else if ([Parkinglot sharedModel].userState >= kRideRequestAccepted) {
        [self updateRequestForTest:^{
            [Parkinglot sharedModel].userState = kRequestCompleted;
            [valetuScheduleTimer invalidate];
            valetuScheduleTimer = nil;
           [self launchLocalNotification:REQUEST_COMPLETED withAction:@"" withCategory:DEFAULT_CATEGORY];
            [self showReturnView];
        }];
        
    }
}

- (void) calulateETA: (void (^)(void)) completion
{
    [Parkinglot sharedModel].currentLocation = [[CLLocation alloc] initWithLatitude:41.8194152 longitude:-72.65621569999996];
    [self getETAWithCompletion:^(NSDictionary *duration, NSString *string, BOOL status) {
        if (status) {
            NSLog(@"duration %@, %@", [duration objectForKey:@"text"], [duration objectForKey:@"value"]);
            [Parkinglot sharedModel].duration = duration;
            completion();
        }
    }];
}

- (void) fetchCheapestProduct: (void (^)(void)) completion
{
    [ridesClient fetchCheapestProductWithPickupLocation: [Parkinglot sharedModel].pickupLocation completion:^(UBSDKUberProduct* _Nullable product, UBSDKResponse* _Nullable response) {
        if (product) {
            [Parkinglot sharedModel].product = product;
            NSLog(@"product ID %@ %@", product.productID, product.name);
            [Parkinglot sharedModel].userState = kUserPrepareRequestRide;
            completion();
        }
    }];
}

- (void) rideRequest
{
    NSLog(@"state %ld", [Parkinglot sharedModel].userState);
    
    builder = [[UBSDKRideParametersBuilder alloc] init];
    builder = [builder setProductID:  [Parkinglot sharedModel].product.productID];
    builder = [builder setPickupLocation: [Parkinglot sharedModel].pickupLocation];
    builder = [builder setDropoffLocation: [Parkinglot sharedModel].dropoffLocation];
    if ([Parkinglot sharedModel].userState >= kReturnPrepareRequestRide) {
        builder = [builder setPickupLocation: [Parkinglot sharedModel].dropoffLocation];
        builder = [builder setDropoffLocation: [Parkinglot sharedModel].pickupLocation];
    }
    [ridesClient requestRide:[builder build] completion:^(UBSDKRide * _Nullable ride, UBSDKResponse * _Nonnull response) {
        if (response.statusCode == 202) {
            NSLog(@"request Id %@", ride.requestID);
            
            if ([Parkinglot sharedModel].userState == kReturnPrepareRequestRide || [Parkinglot sharedModel].isReturning) {
                [Parkinglot sharedModel].userState = kReturnRideRequestAccepted;
            } else if (![Parkinglot sharedModel].isReturning){
                //update user state
                [Parkinglot sharedModel].userState = kRideRequestAccepted;
            }
            [Parkinglot sharedModel].requestID = ride.requestID;
            [self launchLocalNotification:REQUEST_ACCEPTED withAction:@"" withCategory:DEFAULT_CATEGORY];
        } else {
            NSLog(@"response %ld %@", response.statusCode, response.error.errors);
            [self launchLocalNotification:response.error.title withAction:@"" withCategory:DEFAULT_CATEGORY];
        }
    }];
}

- (void) fetchDetailRequest: (void (^)(void)) completion
{
    NSString* authHeader = [NSString stringWithFormat:@"Bearer %@", [UBSDKTokenManager fetchToken].tokenString];
   
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    [getRequest.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [getRequest.request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:URL_UBER_REQUEST_CURRENT parameters:nil  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSString* status = [responseObject objectForKey:@"status"];
        
        if ([status isEqualToString:@"completed"]) {
            [Parkinglot sharedModel].userState = kRequestCompleted;
            [self launchLocalNotification:REQUEST_COMPLETED withAction:@"" withCategory:DEFAULT_CATEGORY];
           
        } else
        {
            [self launchLocalNotification:status withAction:@"" withCategory:DEFAULT_CATEGORY];
        }
        
         completion();
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        
    }];
}

- (void) showReturnView
{
    if (valetuScheduleTimer != nil) {
        
        [valetuScheduleTimer invalidate];
        valetuScheduleTimer = nil;
    }
    ReturnViewController* returnView = [self.storyboard instantiateViewControllerWithIdentifier:@"ReturnView"];
    [self.navigationController pushViewController:returnView animated:YES];
}

- (void) showReviewWindow
{
    [Parkinglot sharedModel].userState = kParkinglotReview;
    
    ReviewControllerViewController* reviewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewControler"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:reviewController];
    popupController.transitionStyle = STPopupTransitionStyleCustom;
    popupController.transitioning = self;
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void) updateRequestForTest: (void (^)(void)) completion
{
    NSString* authHeader = [NSString stringWithFormat:@"Bearer %@", [UBSDKTokenManager fetchToken].tokenString];
    
    SWPUTRequest *putRequest = [[SWPUTRequest alloc]init];
    [putRequest.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [putRequest.request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    putRequest.responseDataType = [SWResponseXMLDataType type];
    
    NSString* updateUrl = [NSString stringWithFormat:@"%@/%@", URL_UBER_SANDBOX_REQUESTS, [Parkinglot sharedModel].requestID];
    
    [putRequest startDataTaskWithURL:updateUrl parameters:@{@"status": @"completed"}  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSLog(@"%@", responseObject);
        completion();
        
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (UIImage*) drawMarkerImage: (NSString*) estimate
{
    UIImage *image = [UIImage imageNamed:@"bgrParking.png"];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    NSString *txt = estimate;
    UIColor *txtColor = [UIColor whiteColor];
    UIFont *txtFont = [UIFont systemFontOfSize:11];
    NSDictionary *attributes = @{NSFontAttributeName:txtFont, NSForegroundColorAttributeName:txtColor};
    
    CGRect txtRect = [txt boundingRectWithSize:CGSizeZero
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes
                                       context:nil];
    
    [txt drawAtPoint:CGPointMake(image.size.width/2 - txtRect.size.width/2, image.size.height/2 - txtRect.size.height/2) withAttributes:attributes];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImg;
}

-(void) drawRoute: (GMSMapView*) mapView
{
    NSString* route =[self.overviewPolyline objectForKey:@"points"];
    
    GMSPath* path = [GMSPath pathFromEncodedPath:route];
    self.routePolyline = [GMSPolyline polylineWithPath:path];
    self.routePolyline.geodesic = YES;
    self.routePolyline.strokeWidth = 2.f;
    self.routePolyline.strokeColor = [UIColor redColor];
    self.routePolyline.map = mapView;
}

- (void) showRoute: (CLLocationCoordinate2D) pickup_location dropOff: (CLLocationCoordinate2D) dropoff_location withMap: (GMSMapView*) mapView
{
    [self getDirectionAtStart:pickup_location toEnd:dropoff_location withCompletion:^(NSString *string, BOOL status) {
        if (status) {
            [self drawRoute: mapView];
        }
    }];
}

- (void)resetAccessToken {
    [Parkinglot sharedModel].profile = nil;
    [UBSDKTokenManager deleteToken];
}


- (AppDelegate*) app
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}


- (void) viewProfile
{
//    NewProfileTableViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewProfileTable"];
//    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - STPopupControllerTransitioning

- (NSTimeInterval)popupControllerTransitionDuration:(STPopupControllerTransitioningContext *)context
{
    return context.action == STPopupControllerTransitioningActionPresent ? 0.5 : 0.35;
}

- (void)popupControllerAnimateTransition:(STPopupControllerTransitioningContext *)context completion:(void (^)())completion
{
    UIView *containerView = context.containerView;
    if (context.action == STPopupControllerTransitioningActionPresent) {
        containerView.transform = CGAffineTransformMakeTranslation(containerView.superview.bounds.size.width - containerView.frame.origin.x, 0);
        
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            context.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
    else {
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            containerView.transform = CGAffineTransformMakeTranslation(- 2 * (containerView.superview.bounds.size.width - containerView.frame.origin.x), 0);
        } completion:^(BOOL finished) {
            containerView.transform = CGAffineTransformIdentity;
            completion();
        }];
    }
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
