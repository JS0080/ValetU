//
//  DetailViewController.m
//  valetu
//
//  Created by imobile on 2016-09-22.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "DetailViewController.h"
#import "ReviewCell.h"

static NSString *const detailCellReuseIdentifier = @"DetailCell";

@interface DetailViewController ()<GSKTwitterStretchyHeaderViewDelegate, UBSDKModalViewControllerDelegate, STPopupControllerTransitioning, RNGridMenuDelegate>
{
    __block  UBSDKRideRequestButton  *btnRideRequest;
    UBSDKRideParametersBuilder *builder;
    UILabel *pickupTime;
}
@property (weak, nonatomic) IBOutlet CircleImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedDate;
@property (weak, nonatomic) IBOutlet UITextView *reviewText;

@end

@implementation DetailViewController
@synthesize stretchyHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    stretchyHeaderView = [[GSKTwitterStretchyHeaderView alloc] initWithFrame:self.tableView.bounds];
    stretchyHeaderView.delegate = self;

    [self.tableView addSubview:stretchyHeaderView];
    
    [self updateRideRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController gsk_setNavigationBarTransparent:YES animated:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void) updateRideRequest
{
    [iCommon getUberETAWithCompletion:[Parkinglot sharedModel].pickupLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
            NSInteger m = (estimate / 60) % 60;
            pickupTime.text = [NSString stringWithFormat:@"PICK UP TIME IS APPROXIMATELY %lu MINS", m];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 13;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellReuseIdentifier];
    }
    
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    // height of the footer
    // this needs to be set, otherwise the height is zero and no footer will show
    return 68;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSInteger width = self.tableView.frame.size.width;
    
    // creates a custom view inside the footer
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 64)];
    
    
    builder = [[UBSDKRideParametersBuilder alloc] init];
    [builder setPickupLocation:[Parkinglot sharedModel].pickupLocation];
    [builder setDropoffLocation:[Parkinglot sharedModel].dropoffLocation];
    //  [builder setPickupLocation:location];
    UBSDKRideParameters *parameters = [builder build];
    
    // Assign the delegate when you initialize your UBSDKRideRequestViewRequestingBehavior
    UBSDKRideRequestViewRequestingBehavior *requestBehavior = [[UBSDKRideRequestViewRequestingBehavior alloc] initWithPresentingViewController:self];
    // Subscribe as the delegete
    requestBehavior.modalRideRequestViewController.delegate = self;
    
    btnRideRequest = [[UBSDKRideRequestButton alloc] initWithRideParameters: parameters requestingBehavior: requestBehavior];
    btnRideRequest.frame = CGRectMake(16, 0, width-32, 44);
    
    [footerView addSubview:btnRideRequest];
    
    pickupTime = [[UILabel alloc] initWithFrame:CGRectMake(16, 50, width-32, 14)];
    pickupTime.font = [UIFont systemFontOfSize:12];
    pickupTime.textColor = [UIColor grayColor];
    pickupTime.textAlignment = NSTextAlignmentCenter;
    pickupTime.backgroundColor = [UIColor whiteColor];
    pickupTime.text = @"pick up";
    
    [footerView addSubview: pickupTime];
  
    return footerView;
}

- (void)footerTapped {
    
    NSLog(@"You've tapped the footer!");
}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView didTapBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
      didAddReview:(id)sender
{
    if ([FBSDKAccessToken currentAccessToken]) {
         [self showReviewWindow];
    }
    else {
        [iCommon loginWithFB: self];
    }
}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
   didTapDirection:(id)sender
{
    if ([Parkinglot sharedModel].currentLocation.coordinate.latitude != [Parkinglot sharedModel].pickupLocation.coordinate.latitude || [Parkinglot sharedModel].currentLocation.coordinate.longitude != [Parkinglot sharedModel].pickupLocation.coordinate.longitude)
    {
        //update user state
        [Parkinglot sharedModel].userState = kUserStartNavigation;
        
        //   [self initScheduleForETA];
        
        if ([[UIApplication sharedApplication]
             canOpenURL:[NSURL URLWithString:@"waze://"]]) {
            
            // Waze is installed. Launch Waze and start navigation
            NSString *urlStr =
            [NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes",
             [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            
        } else {
            // Waze is not installed. Launch AppStore to install Waze app
            [[UIApplication sharedApplication] openURL:[NSURL
                                                        URLWithString:@"https://itunes.apple.com/us/app/id323229106"]];
        }
    }

}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
    didReturntoCar:(id)sender
{
    [Parkinglot sharedModel].userState = kParkinglotReview;
    
    ReturnViewController* returnViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReturnView"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:returnViewController];
    popupController.transitionStyle = STPopupTransitionStyleCustom;
    popupController.transitioning = self;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.navigationBarHidden = YES;
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    [popupController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];
    [popupController presentInViewController:self];
}

- (void) backgroundViewDidTap
{
    [self.popupController dismiss];
}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
    didMenuPressed:(id)sender
{
    [self.view endEditing:YES];
    
    NSError *error;
    FAKFontAwesome *logoutIcon = [FAKFontAwesome  iconWithIdentifier:@"fa-sign-out" size:15 error:&error];
    UIImage *logoutImage = [logoutIcon imageWithSize:CGSizeMake(15, 15)];
    
    FAKFontAwesome *profileIcon = [FAKFontAwesome  iconWithIdentifier:@"fa-user" size:15 error:&error];
    UIImage *profileImage = [profileIcon imageWithSize:CGSizeMake(15, 15)];
    
    NSArray *menuItems = @[
                           [[RNGridMenuItem alloc] initWithImage:profileImage title:@"Profile"],
                           ];
    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
    gridMenu.delegate = self;
    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
}

- (void) showReviewWindow
{
    [Parkinglot sharedModel].userState = kParkinglotReview;
    
    ReviewControllerViewController* reviewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewControler"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:reviewController];
    popupController.transitionStyle = STPopupTransitionStyleCustom;
        popupController.transitioning = self;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.navigationBarHidden = YES;
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    [popupController presentInViewController:self];
}

#pragma mark - STPopupControllerTransitioning

- (NSTimeInterval)popupControllerTransitionDuration:(STPopupControllerTransitioningContext *)context
{
    return context.action == STPopupControllerTransitioningActionPresent ? 0.5 : 0.35;
}

- (void)popupControllerAnimateTransition:(STPopupControllerTransitioningContext *)context completion:(void (^)())completion
{
    UIView *containerView = context.containerView;
    if (context.action == STPopupControllerTransitioningActionPresent) {
        containerView.transform = CGAffineTransformMakeTranslation(containerView.superview.bounds.size.width - containerView.frame.origin.x, 0);
        
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            context.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
    else {
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            containerView.transform = CGAffineTransformMakeTranslation(- 2 * (containerView.superview.bounds.size.width - containerView.frame.origin.x), 0);
        } completion:^(BOOL finished) {
            containerView.transform = CGAffineTransformIdentity;
            completion();
        }];
    }
}


- (void) doAfterLogin
{
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
}

#pragma mark - <UBSDKModalViewControllerDelegate>

- (void)modalViewControllerDidDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"did dismiss");
}

- (void)modalViewControllerWillDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"will dismiss");
}

//------ grid menu delgate -------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [gridMenu dismissAnimated:NO];
    if ([item.title isEqualToString:@"Profile"])    [self viewProfile];
}


- (void) viewProfile{}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
