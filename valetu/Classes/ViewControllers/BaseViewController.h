//
//  BaseViewController.h
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    NSUInteger  totalDistanceInMeters;
    NSUInteger totalDurationInSeconds;
}

@property(strong, nonatomic) GMSPolyline* routePolyline;

@property(strong, nonatomic) NSArray* selectedRoute;
@property(strong, nonatomic) NSMutableDictionary* overviewPolyline;
@property(strong, nonatomic) NSString* totalDuration;
@property(strong, nonatomic) NSString *totalDistance;
@property(strong, nonatomic) UBSDKRidesClient *ridesClient;
@property(strong, nonatomic) __block UBSDKRideParametersBuilder *builder;
@property(strong, nonatomic) GMSMarker* myMarker;


- (void) initNavigation;

- (void)resetAccessToken;

- (AppDelegate*) app;

- (void) fetchNearbyResult: (CLLocationCoordinate2D) location withCompletion: (void (^)(void))completionBlock;

- (void) getDirectionAtStart: (CLLocationCoordinate2D) startLocation toEnd: (CLLocationCoordinate2D) endLocation withCompletion:(void (^)(NSString* string, BOOL status))completionBlock;

- (void) getUberETAWithCompletion: (CLLocation*) pickupLocation completion: (void (^)(NSDictionary* uberData, NSString* string, BOOL status))completionBloc;

- (void) updateRequestForTest: (void (^)(void)) completion;

- (void) fetchDetailRequest: (void (^)(void)) completion;

- (void) launchLocalNotification: (NSString*) body  withAction: (NSString*) action withCategory: (NSString*) category;

- (void) launchLocalNotificationWithoutAction: (NSString*) body;

- (void) initScheduleForETA;

- (void) initReturnScheduleForETA;

- (void) rideRequest;

- (void) showReturnView;

- (void) showReviewWindow;

- (void) runReturnValetU;

- (UIImage*) drawMarkerImage: (NSString*) estimate;

- (void) drawRoute: (GMSMapView*) mapView;

- (void) showRoute: (CLLocationCoordinate2D) pickup_location dropOff: (CLLocationCoordinate2D) dropoff_location withMap: (GMSMapView*) mapView;

- (void) logout;

- (void) viewProfile;

- (void) checkUserState;

- (void) selectMenu: (id) sender;

@end
