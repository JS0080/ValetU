//
//  AppDelegate.h
//  valetu
//
//  Created by imobile on 2016-09-05.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic)  CLLocation* currentLocation;
@property (strong, nonatomic)  NSArray *nearbyplaces;
@property (strong, nonatomic)  NSString* currentAddress;

@property (strong, nonatomic) UBSDKUserProfile *profile;
@property (strong, nonatomic) NSMutableDictionary<NSString *, UBSDKPlace *> *places;
@property (strong, nonatomic) NSArray<UBSDKUserActivity *> *history;

@end

