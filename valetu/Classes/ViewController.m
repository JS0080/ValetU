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

@property (nonatomic, readonly, nonnull) UBSDKRidesClient *ridesClient;
@property (weak, nonatomic) UBSDKLoginButtonView *loginButtonView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
_ridesClient = [[UBSDKRidesClient alloc] init];
   
    NSArray<UBSDKRidesScope *> *requestedScopes = @[ UBSDKRidesScope.RideWidgets, UBSDKRidesScope.Profile, UBSDKRidesScope.Places, UBSDKRidesScope.History ];
    
    UBSDKLoginButtonView *loginButtonView = [[UBSDKLoginButtonView alloc] initWithFrame:self.view.frame
                                                                                 scopes:requestedScopes
                                                                              loginType:UBSDKLoginTypeImplicit];
    loginButtonView.loginButton.delegate = self;
    loginButtonView.loginButton.presentingViewController = self;
    [self.view addSubview:loginButtonView];
    
    if ([UBSDKTokenManager fetchToken]) {
        self.loginButtonView.hidden = YES;
        [self gotoMapView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) gotoMapView {
    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
   
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:mapViewController]; //init FirstViewController with root
    
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
        
   //     [UBSDKTokenManager saveToken:accessToken];
  
        
        // Retrieves a user profile for the current logged in user
        [self.ridesClient fetchUserProfile:^(UBSDKUserProfile * _Nullable profile, UBSDKResponse *response) {
            if (response.statusCode == 401) {
                [self resetAccessToken];
                [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
            } else if (profile) {
                [self app].profile = profile;
                
                NSMutableDictionary *body = [NSMutableDictionary new];
                body[@"access_token"] = accessToken.tokenString;
                body[@"name"] = [profile.firstName stringByAppendingString:profile.lastName];
                body[@"email"] = profile.email;
                
                NSString *url = [NSString stringWithFormat:@"%@?name=%@&email=%@&access_token=%@", WS_LOGIN, body[@"name"], body[@"email"], body[@"access_token"] ];
                
                SWGETRequest *getRequest = [[SWGETRequest alloc]init];
                getRequest.responseDataType = [SWResponseJSONDataType type];
                [getRequest startDataTaskWithURL:url parameters:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
                    NSLog(@"%@", responseObject);
                    NSString* status = [responseObject objectForKey:@"status"];
//                    if ([status isEqualToString:@"Ok"]) {
//                       
//                        [ProgressHUD dismiss];
//                        [self gotoMapView];
//                    } else {
//                        [self resetAccessToken];
//                        [ProgressHUD showError:ERROR_LOGIN Interaction:NO];
//                    }
                    [self gotoMapView];
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
