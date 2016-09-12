//
//  BaseViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewController.h"
#import "ProfileViewController.h"

@interface BaseViewController ()<CLLocationManagerDelegate, RNGridMenuDelegate>{
    CLLocationManager *locationManager;
}

@end

@implementation BaseViewController

//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)initNavigation {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0], NSFontAttributeName, nil]];

    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(selectMenu:)];
    
   
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}


- (void) selectMenu: (id) sender {
    [self.view endEditing:YES];
    
    NSError *error;
    FAKFontAwesome *logoutIcon = [FAKFontAwesome  iconWithIdentifier:@"fa-sign-out" size:15 error:&error];
    UIImage *logoutImage = [logoutIcon imageWithSize:CGSizeMake(15, 15)];
    
    FAKFontAwesome *profileIcon = [FAKFontAwesome  iconWithIdentifier:@"fa-user" size:15 error:&error];
     UIImage *profileImage = [profileIcon imageWithSize:CGSizeMake(15, 15)];
    
    NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:logoutImage title:@"Logout"],
                           [[RNGridMenuItem alloc] initWithImage:profileImage title:@"Profile"],
                           ];
    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
    gridMenu.delegate = self;
    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
}

//------ grid menu delgate -------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [gridMenu dismissAnimated:NO];
    if ([item.title isEqualToString:@"Logout"])		[self logout];
    if ([item.title isEqualToString:@"Profile"])    [self viewProfile];
}

- (void) fetchNearbyResult: (CLLocationCoordinate2D) location withCompletion: (void (^)(void))completionBlock
{
    NSString* lat = [NSString stringWithFormat:@"%lf", location.latitude ];
    NSString* lng = [NSString stringWithFormat:@"%lf", location.longitude ];
    NSDictionary *body = @{@"lat": lat, @"lng": lng};
    
    NSLog(@"location %@, %@", lat, lng);
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:WS_FETCH_NEARBY parameters:body  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSLog(@"%@", responseObject);
        NSString* status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"Ok"]) {
            [self app].nearbyplaces = [responseObject objectForKey:@"places"];
            completionBlock();
        }
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)resetAccessToken {
    [self app].profile = nil;
    [UBSDKTokenManager deleteToken];
}


- (AppDelegate*) app
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void) logout
{
    [UBSDKTokenManager deleteToken];
    
    ViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    
    [self app].window.rootViewController = loginViewController;
}

- (void) viewProfile
{
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
    [self.navigationController pushViewController:profileViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
