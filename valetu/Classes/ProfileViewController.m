//
//  ProfileViewController.m
//  valetu
//
//  Created by imobile on 2016-09-10.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ProfileViewController.h"

typedef NS_ENUM(NSInteger, ImplicitGrantTableViewSection) {
    ImplicitGrantTableViewSectionProfile,
    ImplicitGrantTableViewSectionPlaces,
    ImplicitGrantTableViewSectionHistory
};

static NSString *const profileCellReuseIdentifier = @"ProfileCell";
static NSString *const placesCellReuseIdentifer = @"PlacesCell";
static NSString *const historyCellReuseIdentifier = @"HistoryCell";


@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    [self loadUserData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserData {
    // Examples of various data that can be retrieved
    
    [self.ridesClient fetchUserProfile:^(UBSDKUserProfile * _Nullable profile, UBSDKResponse *response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
            [ProgressHUD show:CONFIRMING_LOGIN Interaction:NO];
        } else if (profile) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self app].profile = profile;
                [self.tableview reloadData];
            });
        }
    }];
    
    // Gets the address assigned as the "home" address for current user
    [self.ridesClient fetchPlace:UBSDKPlace.Home completion:^(UBSDKPlace * _Nullable place, UBSDKResponse *response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self app].places setObject:place forKey:UBSDKPlace.Home];
                [self.tableview reloadData];
            });
        }
    }];
    
    // Gets the address assigned as the "work" address for current user
    [self.ridesClient fetchPlace:UBSDKPlace.Work completion:^(UBSDKPlace * _Nullable place, UBSDKResponse *response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self app].places setObject:place forKey:UBSDKPlace.Work];
                [self.tableview  reloadData];
            });
        }
    }];
    
    // Gets the last 25 trips that the current user has taken
    [self.ridesClient fetchTripHistoryWithOffset:0 limit:25 completion:^(UBSDKTripHistory * _Nullable tripHistory, UBSDKResponse * _Nonnull response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
        } else if(!tripHistory || !tripHistory.history) {
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self app].history = tripHistory.history;
                [self.tableview  reloadData];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self app].profile) {
        return 0;
    }
    
    switch(section) {
        case ImplicitGrantTableViewSectionProfile:
            return 1;
        case ImplicitGrantTableViewSectionPlaces:
            return [self app].places.allKeys.count;
        case ImplicitGrantTableViewSectionHistory:
            return [self app].history.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case ImplicitGrantTableViewSectionProfile: {
            if (![self app].profile) {
                break;
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:profileCellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:profileCellReuseIdentifier];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [self app].profile.firstName, [self app].profile.lastName];
            cell.detailTextLabel.text = [self app].profile.email;
            
            NSURL *url = [NSURL URLWithString: [self app].profile.picturePath];
            if (url) {
                [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = [UIImage imageWithData:data];
                    });
                }] resume];
            }
            
            return cell;
        }
        case ImplicitGrantTableViewSectionPlaces: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:placesCellReuseIdentifer];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:placesCellReuseIdentifer];
            }
            NSString *placeText;
            UBSDKPlace *place;
            switch (indexPath.row) {
                case 0:
                    if ([[self app].places objectForKey:UBSDKPlace.Home]) {
                        place = [[self app].places objectForKey:UBSDKPlace.Home];
                        placeText = UBSDKPlace.Home.capitalizedString;
                        break;
                    }
                case 1:
                    place = [[self app].places objectForKey:UBSDKPlace.Work];
                    placeText = UBSDKPlace.Work.capitalizedString;
                    break;
            }
            
            NSString *addressText = @"None";
            if (place && place.address) {
                addressText = place.address;
            }
            cell.textLabel.text = placeText;
            cell.detailTextLabel.text = addressText;
            return cell;
        }
        case ImplicitGrantTableViewSectionHistory: {
            UBSDKUserActivity *trip = [[self app].history objectAtIndex:indexPath.row];
            
            if (!trip) {
                break;
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyCellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:historyCellReuseIdentifier];
            }
            
            cell.textLabel.text = trip.startCity.name;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ to %@", [dateFormatter stringFromDate:trip.startTime], [dateFormatter stringFromDate:trip.endTime]];
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 75.0;
            
        default:
            return UITableViewAutomaticDimension;
    }
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
