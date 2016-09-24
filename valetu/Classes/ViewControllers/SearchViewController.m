//
//  SearchViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
{
    NSArray* data;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController

@synthesize refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    [self initTableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self updateUI];
}

- (void) updateUI
{
    data = [Parkinglot sharedModel].nearbyplaces;
    
    if([data count] == 0) {
        [self fetchNearbyResult:[Parkinglot sharedModel].dropoffLocation.coordinate withCompletion:^{
            [self.tableView reloadData];
        }];
    }
    else {
        [self.tableView reloadData];
    }
   
}

- (void) initTableView {
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    
    refreshControl = [[UIRefreshControl alloc]
                                        init];
//    refreshControl.tintColor = [UIColor clearColor];
//    refreshControl.backgroundColor = [UIColor clearColor];
    
    [refreshControl addTarget:self action:@selector(refreshTriggered) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
}

- (void)initNavigation {
    [super initNavigation];
    
//    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(mapView:)];
    
//    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.title = @"Nearby parking lots";
}

- (void)mapView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
   
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchCell"];
    }
    
    NSUInteger index = indexPath.row;
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    UILabel *title = (UILabel*)[cell viewWithTag:11];
    HCSStarRatingView  *starRatingView = (HCSStarRatingView *) [cell viewWithTag:12];
    UILabel* starValueLabel = (UILabel*)[cell viewWithTag:13];
    UILabel* subTitleLabel = (UILabel*)[cell viewWithTag:14];
    
    NSArray* comments = [data[[Parkinglot sharedModel].selectedLocationId] objectForKey:@"comments"];
    if([comments count] > 0)
    {
        [imageView sd_setImageWithURL:[NSURL URLWithString:[comments[0] objectForKey:@"photourl"]]
                     placeholderImage:[UIImage imageNamed:@"warning.png"]];
    } else
    {
        imageView.image = [UIImage imageNamed:@"warning.png"];
    }
    
    title.text = [data[index] objectForKey:@"address"];
    NSString* starValue = [data[index] objectForKey:@"star"];
    starRatingView.value = [starValue doubleValue];
    starValueLabel.text = starValue;
    NSString* estimate = [data[index] objectForKey:@"estimate"];
    subTitleLabel.text = estimate;
    
//    NSString* distance = [NSString stringWithFormat:@"%.2lfKm", [[data[index] objectForKey:@"distance"] floatValue] * 1.609344];
//    
//    int duration = [[[self app].nearbyplaces[index] objectForKey:@"duration"] intValue];
//    NSUInteger m = (duration / 60) % 60;
//    NSUInteger s = duration % 60;
//    
//    NSString *away = [NSString stringWithFormat:@"%02lu:%02lu", m, s];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshTriggered
{
    [self performSelector:@selector(updateTable) withObject:nil
               afterDelay:1];
}

- (void)updateTable
{
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - DZNEmptyDatasource

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_placeholder"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"There is no available parking lots around you";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"We will update the database for you soon";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
    
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
    
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -self.tableView.tableHeaderView.frame.size.height/2.0f;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 20.0f;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL) emptyDataSetShouldAllowImageViewAnimate:(UIScrollView *)scrollView
{
    return YES;
}



@end
