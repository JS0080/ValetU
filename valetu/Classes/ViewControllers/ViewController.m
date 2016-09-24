//
//  ViewController.m
//  valetu
//
//  Created by imobile on 2016-09-05.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ViewController.h"

#import "MapViewController.h"
#import "AppDelegate.h"

@interface ViewController ()<UBSDKLoginButtonDelegate>
{
    UBSDKLoginManager *loginManager;
}

@property (weak, nonatomic) UBSDKLoginButtonView *loginButtonView;

@end

@implementation ViewController
@dynamic ridesClient;

- (void)viewDidLoad {
    [super viewDidLoad];
    
   loginManager = [[UBSDKLoginManager alloc] initWithLoginType:UBSDKLoginTypeNative];
    
    if ([UBSDKTokenManager fetchToken]) {
        self.loginButtonView.hidden = YES;
        [self gotoMapView];
    }
}

- (IBAction)loginWithUber:(id)sender {
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        NSArray<UBSDKRidesScope *> *requestedScopes = @[ UBSDKRidesScope.Request, UBSDKRidesScope.Profile, UBSDKRidesScope.Places ];
        
        [loginManager loginWithRequestedScopes:requestedScopes presentingViewController:self completion:^(UBSDKAccessToken * _Nullable accessToken, NSError * _Nullable error) {
            if (accessToken) {
                [ProgressHUD show:CONFIRMING_LOGIN Interaction:NO];
                
                // Retrieves a user profile for the current logged in user
                [self.ridesClient fetchUserProfile:^(UBSDKUserProfile * _Nullable profile, UBSDKResponse *response) {
                    if (response.statusCode == 401) {
                        [self resetAccessToken];
                        [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
                    } else if (profile) {
                        [Parkinglot sharedModel].profile = profile;
                        [Parkinglot sharedModel].UUID = profile.UUID;
                        
                        NSMutableDictionary *body = [NSMutableDictionary new];
                        body[@"token"] = profile.UUID;
                        body[@"name"] = [profile.firstName stringByAppendingString:profile.lastName];
                        body[@"email"] = profile.email;
                        
                        SWPOSTRequest *postRequest = [[SWPOSTRequest alloc]init];
                        postRequest.responseDataType = [SWResponseJSONDataType type];
                        [postRequest startDataTaskWithURL:WS_LOGIN parameters:body parentView:nil cachedData:^(NSCachedURLResponse *response, id responseObject) {
                            NSLog(@"%@", responseObject);
                        } success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
                            NSLog(@"%@", responseObject);
                            NSString* status = [responseObject objectForKey:@"status"];
                            if ([status isEqualToString:@"Ok"]) {
                                [ProgressHUD dismiss];
                                [self gotoMapView];
                            } else {
                                [self resetAccessToken];
                                [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
                            }
                        } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
                            NSLog(@"%@", error);
                           [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
                        }];
                    }
                }];
            } else {
                [ProgressHUD showError:error.localizedDescription Interaction:NO];
            }
        }];
        
    } else {
        // Waze is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"https://itunes.apple.com/en/app/uber/id368677368?mt=8"]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


- (void) gotoMapView {
    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
   
//    UITabBarController *tabbarController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tabbar"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    [self app].window.rootViewController = navigationController;
}

#pragma mark - UBSDKLoginButtonDelegate

- (void)loginButton:(UBSDKLoginButton *)button didLogoutWithSuccess:(BOOL)success {
    if (success) {
//        __weak ViewController *weakSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UBSDKUtility showMessage:UBSDKLOC(@"Logout") presentingViewController:weakSelf completion:^{
//                weakSelf.loginButtonView.hidden = NO;
//            }];
//        });
       
    }
}

- (void)loginButton:(UBSDKLoginButton *)button didCompleteLoginWithToken:(UBSDKAccessToken *)accessToken error:(NSError *)error {
    if (accessToken) {	
        [ProgressHUD show:CONFIRMING_LOGIN Interaction:NO];
     
        // Retrieves a user profile for the current logged in user
        [self.ridesClient fetchUserProfile:^(UBSDKUserProfile * _Nullable profile, UBSDKResponse *response) {
            if (response.statusCode == 401) {
                [self resetAccessToken];
                [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
            } else if (profile) {
                [Parkinglot sharedModel].profile = profile;
                
                NSMutableDictionary *body = [NSMutableDictionary new];
                body[@"token"] = profile.UUID;
                body[@"name"] = [profile.firstName stringByAppendingString:profile.lastName];
                body[@"email"] = profile.email;
                
                SWGETRequest *getRequest = [[SWGETRequest alloc]init];
                getRequest.responseDataType = [SWResponseJSONDataType type];
                [getRequest startDataTaskWithURL:WS_LOGIN parameters:body success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
                    NSLog(@"%@", responseObject);
                    NSString* status = [responseObject objectForKey:@"status"];
                    if ([status isEqualToString:@"Ok"]) {
                       
                        [ProgressHUD dismiss];
                        [self gotoMapView];
                    } else {
                        [self resetAccessToken];
                        [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
                    }
                } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
                    NSLog(@"%@", error);
                    [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
                }];
            }
        }];
        
        
    } else {
        [UBSDKUtility showMessage:error.localizedDescription presentingViewController:self completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
