//
//  Parkinglot.h
//  valetu
//
//  Created by imobile on 2016-09-14.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"

@interface Parkinglot : NSObject

@property (nonatomic)   NSString* UUID;
@property (nonatomic)   CLLocation* currentLocation;
@property (nonatomic)   CLLocation* dropoffLocation;
@property (nonatomic)   CLLocation* pickupLocation;
@property (nonatomic)   NSInteger selectedLocationId;
@property (nonatomic)   NSArray *nearbyplaces;
@property (nonatomic)   NSString* currentAddress;
@property (nonatomic)   NSDictionary *duration;
@property (nonatomic)   UBSDKUberProduct* product;
@property (nonatomic)   UBSDKResponse* requestDetailResponse;
@property (nonatomic)   NSString* requestID;
@property (nonatomic)   NSTimer *timer;
@property (nonatomic)   BOOL    isBackgroundRunning;
@property (nonatomic)   BOOL    isReturning;
@property (nonatomic)   BackgroundTaskManager * bgTask;
@property (nonatomic)   __block NSInteger userState;
@property (nonatomic)  NSInteger starValue;
@property (nonatomic) NSString* comment;
@property ( nonatomic) NSMutableDictionary<NSString *, UBSDKPlace *> *places;
@property ( nonatomic) NSArray<UBSDKUserActivity *> *history;
@property (nonatomic) FBSDKProfile *profile;
@property (nonatomic) NSString*  email;
@property (nonatomic) FBSDKAccessToken *token;


+(Parkinglot*)sharedModel;

+(NSDictionary*)getParkinglot: (NSInteger) index;

@end
