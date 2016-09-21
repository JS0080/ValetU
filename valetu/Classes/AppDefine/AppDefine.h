//
//  AppDefine.h
//  Pipol
//
//  Created by HiTechLtd on 3/6/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#ifndef Pipol_AppDefine_h
#define Pipol_AppDefine_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define		HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

#define URL_API                         @"https://valetu.com/uber/v1/"
#define URL_REMINDER_SANDBOX_API        @"https://sandbox-api.uber.com/v1/sandbox/reminders"
#define URL_REMINDER_API                @"https://api.uber.com/v1/reminders?server_token=VcR8_A-Xex3YhVGTUvjDWBQhDa3ygeBFHBXU73L7"
#define URL_UBER_ETA                    @"https://api.uber.com/v1/estimates/time?server_token=VcR8_A-Xex3YhVGTUvjDWBQhDa3ygeBFHBXU73L7"
#define URL_UBER_SANDBOX_REQUESTS       @"https://sandbox-api.uber.com/v1/sandbox/requests"
#define URL_UBER_REQUEST_CURRENT        @"https://sandbox-api.uber.com/v1/sandbox/requests/current"
//#define URL_UBER_REQUESTS               @"https://api.uber.com/v1/requests"

#define URL_UBER_REQUEST_DETAIL         @"https://sandbox-api.uber.com/v1/requests/"
#define URL_UBER_REQUEST_PUT            @"https://sandbox-api.uber.com/v1/sandbox/requests/"
#define WS_TIME_OUT                     120


#define ERROR_AUTH_NOT_PROVIDED         @"Authentication credentials were not provided."
#define WS_ERROR_DOMAIN                 @"PIPOL_ERROR_DOMAIN"

// Uber credential
#define CLIENT_ID                       @"AoB2Dn2P93FFYkd2Hcd15opIaC9lIn8ciIPNg44O"
#define CLIENT_SECRECT                              @"E5SVOzDAICZ2fUJBx8uWFfb7eUZumkZ9QrSoCsLRgvAAQVEdMQ98TWyZdF07rQLbpX0sbJETOxsXJgoy2pUbpYlEQFnvHguPkFEH92fwHiAR2p6Yhxf1hwdTGkCruBKF"
#define SERVER_TOKEN                    @"VcR8_A-Xex3YhVGTUvjDWBQhDa3ygeBFHBXU73L7"

#define UBER_TOKEN                      @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZXMiOlsicHJvZmlsZSIsInBsYWNlcyIsInJpZGVfd2lkZ2V0cyIsImhpc3RvcnlfbGl0ZSIsImhpc3RvcnkiXSwic3ViIjoiMTYwNmY0NjEtMTBiYi00Y2E1LWFkYTUtZWRmOWUwYjU2YjI0IiwiaXNzIjoidWJlci11czEiLCJqdGkiOiIwN2ZmMDExMi0yNDY3LTQ2Y2EtODgwOC1hMGY2NmE1ZmU0NmYiLCJleHAiOjE0NzY3Mjk2NjUsImlhdCI6MTQ3NDEzNzY2NSwidWFjdCI6InlRSEl4VFdMbmJoOVF5UVlldU91TTA0bWVSbWtyZCIsIm5iZiI6MTQ3NDEzNzU3NSwiYXVkIjoia2xPOVRCTmdIc05nVzZIc2t0TXB6cDBUVWV0M2VrZmsifQ.kQn8m8F4UWl-4Bis_rlUGJWpIJnaisXydx0TJfBkg_upSmiwckiBMgJ-GxuvxyyuNvvpAQkHrAvfsO91wlfm3qsa_NDzqkpMvPIAo5p-V6De6xfudcBOAcRm7gG8PAVfTTcoXv4nSgRNAioOCeaOHuXMHSvUWSKQ1Re3rTOmheXJsZbrUT31F6-FEUvSMvPypeC3vmgO9Epyvsg3CY-dHVrPpm8J8Pjfxmlu7_RVC1moOC0EERjJE4t8wgGxpVWLVl6E_8LIW-iyN2lp6TJPmcj_hsaoHgNE9L118XvxtajHWZwMswVDoIm6gmvkY4XCN0pZfk1jA2KoyJrbeW8bgg"

// Google map api
#define GOOGLE_MAP_API_KEY              @"AIzaSyDfmfNcSRpPazfUFN9LAVnBaOJQ6Oy5mEs"

#define GOOGLE_MAP_DIRECTION_API_KEY    @"AIzaSyB03Qz_Mrj4hfhjSXJ2p0Mh_LxlOWCrp_M"
#define GOOGLE_MAP_MATRIX_API_KEY       @"AIzaSyD3xrIVwZTjgy0LNT7fuY-lxhlC3YCIZHM"

#define DIRECTION_ROUTE_ENDPOINT          @"https://maps.googleapis.com/maps/api/directions/json?key=AIzaSyB03Qz_Mrj4hfhjSXJ2p0Mh_LxlOWCrp_M&traffic_model=best_guess&mode=transit"

#define DISTANCE_MATRIX_ENDPOINT        @"https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&key=AIzaSyB03Qz_Mrj4hfhjSXJ2p0Mh_LxlOWCrp_M"

// Google Map update timer interval
#define MAP_UPDATE_INTERVAL             4

#define CALCULATE_ETA_INTERVAL          30

#define KEY_USER_AVATAR                 @"UserAvatar"
#define KEY_USER_COVER_IMAGE            @"UserCoverImage"
#define KEY_USER_ID                     @"UserId"
#define KEY_ACCESS_TOKEN                @"FacebookToken"
#define KEY_FACEBOOK_ID                 @"FacebookId"
#define KEY_PROFILE_EXIST               @"PROFILE_EXIST"
#define KEY_PASSWORD_EXIST              @"KEY_PASSWORD_EXIST"

#define IS_SHOW_TUTORIAL_PIPOL          @"PIPOL_IS_SHOW_TUTORIAL"
#define IS_ACCEPT_TERMS_PIPOL           @"IS_ACCEPT_TERMS_PIPOL"

//Login
#define WS_LOGIN                        [URL_API stringByAppendingString:@"savetoken"]
#define WS_FETCH_NEARBY                 [URL_API stringByAppendingString:@"findnearby"]
#define WS_LOGIN_REGISTER               [URL_API stringByAppendingString:@"Login/Register/"]
#define WS_UPLOAD_COMMENT               [URL_API stringByAppendingString:@"savereview"]

#define ScreenScale                     [[UIScreen mainScreen] bounds].size.width/414.0

// Messages

#define CONFIRMING_LOGIN                @"Confirming..."
#define ERROR_LOGIN                     @"Opps..."
#define REQUEST_RIDE_MESSAGE            @"5 min left to the parking lot. please request a uber there"
#define REQUES_RETURN_RIDE              @"Ride Request"
#define NAVIGATION_START                @"Navigation started"
#define REQUEST_ACCEPTED                @"Uber Request Accepted"
#define REQUEST_COMPLETED               @"Uber trip completed"
#define UPLOADING                       @"Uploading..."

//ENUM
typedef NS_ENUM(NSInteger, LoginType) {
    LoginTypeNone,
    LoginTypeFacebook,
    LoginTypeEmail
};

typedef NS_ENUM(NSInteger, ParkinglotUserState) {
    kStateNone,
    kUserSelectParkinglot,
    kUserStartNavigation,
    kFiveMinutesLeft,
    kUserPrepareRequestRide,
    kRideRequestAccepted,
    kRideArriving,
    kRequestInProgress,
    kRequestRiderCancel,
    kRequestDriverCancel,
    kRequestCompleted,
    kReturnPrepareRequestRide,
    kReturnRideRequestAccepted,
    kReturnRideArriving,
    kReturnRequestInProgress,
    kReturnRiderCancel,
    kReturnDriverCancel,
    kReturnRequestCompleted,
    kParkinglotReview
};

#define m_string(str)                   (NSLocalizedString(str, nil))

//DEFAULT KEY
#define kUserDefaults                   [NSUserDefaults standardUserDefaults]
#define kMainQueue                      [NSOperationQueue mainQueue]
#define kWindow                         [[UIApplication sharedApplication] keyWindow]

// Local Notification
#define Ride_Uber_IDENTIFIRE         @"Ride Uber"
#define NOT_YET_IDENTIFIRE           @"Not Yet"
#define OK_IDENTIFIRE                @"Ok"
#define NOTIFICATION_CATEGORY        @"ValetU"
#define DEFAULT_CATEGORY             @"Default"


#endif /* AppDefine_h */
