//
//  AppDelegate.m
//  valetu
//
//  Created by imobile on 2016-09-05.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "AppDelegate.h"
#import <UberRides/UberRides-Swift.h>
@import GoogleMaps;

@interface AppDelegate (){
    
}

@end

@implementation AppDelegate
@synthesize currentLocation;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_API_KEY];
    // China based apps should specify the region
  //  [UBSDKConfiguration setRegion:RegionChina];
    // If true, all requests will hit the sandbox, useful for testing
    [UBSDKConfiguration setSandboxEnabled:YES];
    // If true, Native login will try and fallback to using Authorization Code Grant login (for privileged scopes). Otherwise will redirect to App store
    [UBSDKConfiguration setFallbackEnabled:NO];
    
    return YES;
}

- (void) initGlobalVar
{
    _places = [NSMutableDictionary dictionary];
    
}

// iOS 9+
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    BOOL handledURL = [[UBSDKRidesAppDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    if (!handledURL) {
        // Other URL logic
    }
    
    return true;
}

// iOS 8
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL handledURL = [[UBSDKRidesAppDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    if (!handledURL) {
        // Other URL logic
    }
    
    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}




- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
