//
//  iCommon.m
//  valetu
//
//  Created by imobile on 2016-09-23.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "iCommon.h"

@implementation iCommon



+ (void) getUberETAWithCompletion: (CLLocation*) pickupLocation completion:  (void (^)(NSDictionary* uberData, NSString* string, BOOL status))completionBlock
{
    NSString *start_latitude = [NSString stringWithFormat:@"%f", pickupLocation.coordinate.latitude];
    NSString *start_longitude = [NSString stringWithFormat:@"%f", pickupLocation.coordinate.longitude];
    
    NSDictionary *params = @{@"start_latitude": start_latitude, @"start_longitude": start_longitude};
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:URL_UBER_ETA parameters:params  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSArray* times = [responseObject objectForKey:@"times"];
        if (times != nil) {
            BOOL isAvaialbleUberX = NO;
            for (NSDictionary* uberData in times) {
                if ([[uberData objectForKey:@"display_name"] isEqualToString:@"uberX"]) {
                    completionBlock(uberData, @"Ok", YES);
                    isAvaialbleUberX = YES;
                    break;
                }
            }
            if (!isAvaialbleUberX) {
                completionBlock(nil, @"There is no available UberX", YES);
            }
        } else{
            completionBlock(nil, @"There is no available UberX", NO);
        }
        
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        completionBlock(nil, error.localizedDescription, NO);
    }];
}

+(void) loginWithFB:(UIViewController*) viewController
{
    FBSDKAccessToken *token = [Parkinglot sharedModel].token;
    if (token) {
        [FBSDKAccessToken setCurrentAccessToken:token];
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
        [request setGraphErrorRecoveryDisabled:YES];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
       login.loginBehavior = FBSDKLoginBehaviorWeb;
        [ProgressHUD show:UPLOADING Interaction:NO];
        [login logInWithReadPermissions:nil
                     fromViewController:viewController
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                    if (error || result.isCancelled) {
                                        [ProgressHUD dismiss];
                                    }
                                }];
    }
}

@end
