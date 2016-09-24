//
//  AppDelegate.m
//  valetu
//
//  Created by imobile on 2016-09-05.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_API_KEY];
    // China based apps should specify the region
  //  [UBSDKConfiguration setRegion:RegionChina];
    // If true, all requests will hit the sandbox, useful for testing
    [UBSDKConfiguration setSandboxEnabled:NO];
    // If true, Native login will try and fallback to using Authorization Code Grant login (for privileged scopes). Otherwise will redirect to App store
    [UBSDKConfiguration setFallbackEnabled:YES];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [Fabric with:@[[Crashlytics class]]];
    
    [Mixpanel sharedInstanceWithToken:MIX_PANEL_TOKEN];
    
    [self initVariables];

    return YES;
}

- (void) initVariables
{
    [Parkinglot sharedModel].selectedLocationId = -1;
    
    [[Mixpanel sharedInstance] track:@"Valetu"
         properties:@{ @"Event": @"Start" }];
}

// iOS 9+
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
//    BOOL handledURL = [[UBSDKRidesAppDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//    
//    if (!handledURL) {
//        // Other URL logic
//    }
//    
//    return true;
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

// iOS 8
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL handledURL = [[UBSDKRidesAppDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                   annotation:annotation];
    
//    if (!handledURL) {
//        // Other URL logic
//    }
//    
//    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [Parkinglot sharedModel].isBackgroundRunning = NO;
     [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    if (![Parkinglot sharedModel].isBackgroundRunning) {
//        UIAlertController * alert=   [UIAlertController
//                                      alertControllerWithTitle:NOTIFICATION_CATEGORY
//                                      message:[notification.userInfo objectForKey:@"message"]
//                                      preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* Ok = [UIAlertAction
//                             actionWithTitle:OK_IDENTIFIRE
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                             }];
//        UIAlertAction* notYet = [UIAlertAction
//                                 actionWithTitle:NOT_YET_IDENTIFIRE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                 }];
//        
//        UIAlertAction* rideRequest = [UIAlertAction actionWithTitle:Ride_Uber_IDENTIFIRE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:Ride_Uber_IDENTIFIRE object: nil];
//        }];
//        
//        if ([notification.alertAction isEqualToString:Ride_Uber_IDENTIFIRE]) {
//            [alert addAction:notYet];
//            [alert addAction:rideRequest];
//        } else {
//            [alert addAction:Ok];
//        }
//        
//        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
//    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:Ride_Uber_IDENTIFIRE]) {
     //   [[NSNotificationCenter defaultCenter] postNotificationName:Ride_Uber_IDENTIFIRE object: nil];
    }
    completionHandler();
}

@end
