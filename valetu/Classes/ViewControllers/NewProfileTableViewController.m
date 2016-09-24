//
//  NewProfileTableViewController.m
//  valetu
//
//  Created by imobile on 2016-09-21.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "NewProfileTableViewController.h"


static NSString *const profileCellReuseIdentifier = @"ProfileCell";

@interface NewProfileTableViewController ()
{
    UBSDKRidesClient *ridesClient;
}

@end

@implementation NewProfileTableViewController
@synthesize stretchyHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSArray<UIView *> *nibViews = [[NSBundle mainBundle] loadNibNamed:@"GSKNibStretchyHeaderView"
                                                                owner:self
                                                              options:nil];
    stretchyHeaderView = (GSKNibStretchyHeaderView*) nibViews.firstObject;

    stretchyHeaderView.reviewLabel.text = @"0";
    
    
    ridesClient = [[UBSDKRidesClient alloc] init];
    [ridesClient fetchUserProfile:^(UBSDKUserProfile * _Nullable profile, UBSDKResponse *response) {
        if (response.statusCode == 401) {
            
        } else if (profile) {
            [Parkinglot sharedModel].profile = profile;
            stretchyHeaderView.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [Parkinglot sharedModel].profile.firstName, [Parkinglot sharedModel].profile.lastName];
            
            NSURL *url = [NSURL URLWithString: [Parkinglot sharedModel].profile.picturePath];
            if (url) {
                [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        stretchyHeaderView.userImage.image = [UIImage imageWithData:data];
                    });
                }] resume];
            }
        }
    }];

    
    [self.tableView addSubview:self.stretchyHeaderView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    [self.navigationController gsk_setNavigationBarTransparent:YES animated:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:profileCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:profileCellReuseIdentifier];
    }

    
    // Configure the cell...
    
    return cell;
}



// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}



// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
