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

#define URL_API                         @"https://valetu.com/uber/v1/"
#define URL_IMAGE                       @"http://pipol.estefanosalazar.com/Archivos/ImagenesPerfiles/"
#define URL_AUDIO                       @"http://pipol.estefanosalazar.com/Archivos/Audios/"
#define URL_IMAGE_JOB                   @"http://pipol.estefanosalazar.com/Archivos/Imagenes/"
#define WS_TIME_OUT                     120


#define ERROR_AUTH_NOT_PROVIDED         @"Authentication credentials were not provided."
#define WS_ERROR_DOMAIN                 @"PIPOL_ERROR_DOMAIN"

// Uber credential
#define CLIENT_ID                       @"AoB2Dn2P93FFYkd2Hcd15opIaC9lIn8ciIPNg44O"
#define CLIENT_SECRECT                              @"E5SVOzDAICZ2fUJBx8uWFfb7eUZumkZ9QrSoCsLRgvAAQVEdMQ98TWyZdF07rQLbpX0sbJETOxsXJgoy2pUbpYlEQFnvHguPkFEH92fwHiAR2p6Yhxf1hwdTGkCruBKF"
#define SERVER_TOKEN                    @"VcR8_A-Xex3YhVGTUvjDWBQhDa3ygeBFHBXU73L7"

// Google map api
#define GOOGLE_MAP_API_KEY              @"AIzaSyDfmfNcSRpPazfUFN9LAVnBaOJQ6Oy5mEs"

// Google Map update timer interval
#define MAP_UPDATE_INTERVAL             4

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
#define WS_LOGIN                        [URL_API stringByAppendingString:@"test"]
#define WS_FETCH_NEARBY                 [URL_API stringByAppendingString:@"findnearby"]
#define WS_LOGIN_REGISTER               [URL_API stringByAppendingString:@"Login/Register/"]

#define ScreenScale                     [[UIScreen mainScreen] bounds].size.width/414.0

// Messages

#define CONFIRMING_LOGIN                @"Confirming..."
#define ERROR_LOGIN                     @"Opps..."

//ENUM
typedef NS_ENUM(NSInteger, LoginType) {
    LoginTypeNone,
    LoginTypeFacebook,
    LoginTypeEmail
};

#define m_string(str)                           (NSLocalizedString(str, nil))

//DEFAULT KEY
#define kUserDefaults                   [NSUserDefaults standardUserDefaults]
#define kMainQueue                      [NSOperationQueue mainQueue]
#define kWindow                         [[UIApplication sharedApplication] keyWindow]

#endif /* AppDefine_h */
