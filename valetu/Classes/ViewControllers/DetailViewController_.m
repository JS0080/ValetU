//
//  DetailViewController.m
//  valetu
//
//  Created by imobile on 2016-09-14.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "DetailViewController.h"
#import "AddressCell.h"
#import "PhotoCell.h"
#import "ReviewCell.h"

typedef NS_ENUM(NSInteger, DetailTableViewSection) {
    AddressSection,
    PhotoSection,
    ReviewSection
};

static NSString *const addressCellIdentifier = @"AddressCell";
static NSString *const photoCellIdentifier = @"PhotoCell";
static NSString *const reviewCellIdentifier = @"ReviewCell";

@interface DetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *data;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DetailViewController
@synthesize index;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    data = [Parkinglot sharedModel].nearbyplaces;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:addressCellIdentifier bundle:nil] forCellReuseIdentifier:addressCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:photoCellIdentifier bundle:nil] forCellReuseIdentifier:photoCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:reviewCellIdentifier bundle:nil] forCellReuseIdentifier:reviewCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = 0;
    switch(section) {
        case AddressSection:
            numbers = 1;
            break;
        case PhotoSection:
        case ReviewSection:
            numbers = [[data[index] objectForKey:@"comments"] count];
            if (numbers < 1) {
                numbers = 1;
            }
            break;
        default:
            break;;
    }
    
    return numbers;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (indexPath.section) {
        case AddressSection:
            height =  90.0;
            break;
        default:
            height = UITableViewAutomaticDimension;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = @"";
    switch(section) {
        case AddressSection:
            title = @"Address";
            break;
            
        case PhotoSection:
            title = @"Photo";
            break;
        case ReviewSection:
            title = @"Reviews";
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case AddressSection: {
            AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:addressCellIdentifier];
            if (!cell) {
                cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:addressCellIdentifier];
            }
            
            cell.address.text = [data[index] objectForKey:@"address"];
            cell.starView.value = [[data[index] objectForKey:@"star"] doubleValue];
            cell.starView.accurateHalfStars = YES;
            cell.starValue.text = [data[index] objectForKey:@"star"];
   
            return cell;
        }
            
        case PhotoSection:
        {
            PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
            if (!cell) {
                cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:photoCellIdentifier];
            }
            
            return cell;
        }
        case ReviewSection:
        {
            ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:reviewCellIdentifier];
            if (!cell) {
                cell = [[ReviewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reviewCellIdentifier];
            }
            
            NSArray* reviews  = [data[index] objectForKey:@"review"];
            if ([reviews count] > 0) {
                cell.review.text = [reviews[indexPath.row] objectForKey:@"review"];
            }
            
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
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
