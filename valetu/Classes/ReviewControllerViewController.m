//
//  ReviewControllerViewController.m
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ReviewControllerViewController.h"
#import "NewAddressCell.h"
#import "MapCell.h"
#import "UploadCell.h"
#import "InputCell.h"

typedef NS_ENUM(NSInteger, ReviewTableviewSection) {
    MapSection,
    AddressSection,
    InputSection,
    UploadSection,
};

static NSString *const mapCellIdentifier = @"MapCell";
static NSString *const newAddressCellIdentifier = @"NewAddressCell";
static NSString *const inputCellIdentifier = @"InputCell";
static NSString *const uploadCellIdentifier = @"UploadCell";

@interface ReviewControllerViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString* inputReview;
    UIImage* uploadedImage;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ReviewControllerViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Review";
    self.contentSizeInPopup = CGSizeMake(300, 400);
    self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:mapCellIdentifier bundle:nil] forCellReuseIdentifier:mapCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:newAddressCellIdentifier bundle:nil] forCellReuseIdentifier:newAddressCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:inputCellIdentifier bundle:nil] forCellReuseIdentifier:inputCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:uploadCellIdentifier bundle:nil] forCellReuseIdentifier:uploadCellIdentifier];
    
    [self initTapGesture];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveData)];
    
    uploadedImage = [UIImage imageNamed:@"warning.png"];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"No, Thank you" style:UIBarButtonItemStylePlain target:self action:@selector(noThankyou:)];
    self.navigationItem.leftBarButtonItem = newBackButton;

}

-(void) noThankyou: (id) sender
{
    [Parkinglot sharedModel].userState = kStateNone;
    [self.popupController dismiss];
}

- (void)saveBtnDidTap
{
    [Parkinglot sharedModel].userState = kStateNone;
    NSString *parkinglot_id = [[Parkinglot sharedModel].nearbyplaces[[Parkinglot sharedModel].selectedLocationId] objectForKey:@"id"];
    NSString *starValue = [NSString stringWithFormat:@"%ld", (long)[Parkinglot sharedModel].starValue];
    NSString *uuid = [Parkinglot sharedModel].UUID;
    
    NSDictionary* params = @{@"parkinglot_id": parkinglot_id, @"star": starValue, @"uuid": uuid, @"review": inputReview};
    
    SWPOSTRequest *postRequest = [[SWPOSTRequest alloc]init];
    [postRequest.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    postRequest.responseDataType = [SWResponseJSONDataType type];
    
    //need to crate files array to upload
    
    NSData *imageData = UIImagePNGRepresentation(uploadedImage);
    SWMedia *file1 = [[SWMedia alloc]initWithFileName:@"imagefile.png" key:@"image" data:imageData];
    
    //create an array with files
    
    NSArray *fileArray = @[file1];
    
    [postRequest startUploadTaskWithURL:WS_UPLOAD_COMMENT files:fileArray parameters:params parentView:nil
                             cachedData:^(NSCachedURLResponse *response, id responseObject) {
                                 NSLog(@"%@", responseObject);
                             } success:^(NSURLSessionUploadTask *uploadTask, id responseObject) {
                                 NSLog(@"%@", responseObject);
                             } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
                                 NSLog(@"%@", error);
                             }];
}

- (void) saveData
{
    [ProgressHUD show:UPLOADING Interaction:NO];
    
     NSData *imageData = UIImagePNGRepresentation(uploadedImage);
    [Parkinglot sharedModel].userState = kStateNone;
    NSString *parkinglot_id = @"1";//[[Parkinglot sharedModel].nearbyplaces[[Parkinglot sharedModel].selectedLocationId] objectForKey:@"id"];
    NSString *starValue = [NSString stringWithFormat:@"%ld", (long)[Parkinglot sharedModel].starValue];
    NSString *uuid = @"1606f461-10bb-4ca5-ada5-edf9e0b56b24";//[Parkinglot sharedModel].UUID;
    
    NSDictionary* params = @{@"parkinglot_id": parkinglot_id, @"star": starValue, @"uuid": uuid, @"review": inputReview};

    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:WS_UPLOAD_COMMENT parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"filename.jpg" mimeType:@"image/jpg"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                        //  [progressView setProgress:uploadProgress.fractionCompleted];
                          NSLog(@"progress %f", uploadProgress.fractionCompleted);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                      }
                      [ProgressHUD dismiss];
                      
                     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                  }];
    
    [uploadTask resume];

}

- (void) initTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
    
    [self.tableView addGestureRecognizer:tapRecognizer];
}

- (void) respondToTapGesture: (id) sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = 0;
    switch(section) {
        case MapSection:
            numbers = 1;
            break;
        case AddressSection:
            numbers = 1;
            break;
        case InputSection:
            numbers = 1;
            break;
        case UploadSection:
            numbers = 1;
            break;
        default:
            break;;
    }
    
    return numbers;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (indexPath.section) {
        case MapSection:
            height =  180.0;
            break;
        case AddressSection:
            height =  90.0;
            break;
        case InputSection:
            height =  140.0;
            break;
        case UploadSection:
            height =  150.0;
            break;
        default:
            height = UITableViewAutomaticDimension;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = @"";
    switch(section) {
        case MapSection:
            title = @"Map";
            break;
            
        case AddressSection:
            title = @"Address";
            break;
            
        case InputSection:
            title = @"Review";
            break;
        case UploadSection:
            title = @"Photo";
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case MapSection: {
            MapCell *cell = [tableView dequeueReusableCellWithIdentifier:mapCellIdentifier];
            if (!cell) {
                cell = [[MapCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mapCellIdentifier];
            }
            
            CLLocationCoordinate2D pickuplocation = CLLocationCoordinate2DMake(41.8194152, -72.65621569999996);//[Parkinglot sharedModel].dropoffLocation.coordinate;
            CLLocationCoordinate2D dropofflocation = CLLocationCoordinate2DMake(41.769359, -72.676986);//[Parkinglot sharedModel].pickupLocation.coordinate;
            
            cell.mapView.camera = [GMSCameraPosition cameraWithTarget: pickuplocation zoom:11 bearing:0 viewingAngle:0];
            [cell.mapView setMinZoom:3 maxZoom:20];
            
            GMSMarker*  pickupMarker = [GMSMarker markerWithPosition:pickuplocation];
            GMSMarker*  dropoffMarker = [GMSMarker markerWithPosition:dropofflocation];
            pickupMarker.map = cell.mapView;
            NSString* estimate = [[Parkinglot sharedModel].nearbyplaces[[Parkinglot sharedModel].selectedLocationId] objectForKey:@"estimate"];
            pickupMarker.iconView = [[UIImageView alloc] initWithImage:[self drawMarkerImage: estimate]];
            dropoffMarker.map = cell.mapView;
            
            [self showRoute:pickuplocation dropOff:dropofflocation withMap:cell.mapView];
            
            return cell;
        }
        case AddressSection: {
            NewAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:newAddressCellIdentifier];
            if (!cell) {
                cell = [[NewAddressCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:newAddressCellIdentifier];
            }
            
            cell.address.text = [[Parkinglot sharedModel].nearbyplaces[[Parkinglot sharedModel].selectedLocationId] objectForKey:@"address"];
            
            return cell;
        }
            
        case InputSection:
        {
            InputCell *cell = [tableView dequeueReusableCellWithIdentifier:inputCellIdentifier];
            if (!cell) {
                cell = [[InputCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:inputCellIdentifier];
            }
            
            cell.inputReview.delegate = self;
            
            return cell;
        }
        case UploadSection:
        {
            UploadCell *cell = [tableView dequeueReusableCellWithIdentifier:uploadCellIdentifier];
            if (!cell) {
                cell = [[UploadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:uploadCellIdentifier];
            }
            
            [cell.uploadButton addTarget:self action:@selector(uploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
            cell.imageView.image = uploadedImage;
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (void) uploadPhoto: (id) sender
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Take a photo"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  imagePickerController.delegate = self;
                                  imagePickerController.mediaTypes = (__bridge NSArray<NSString *> * _Nonnull)(kUTTypeImage);
                                  imagePickerController.allowsEditing = false;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose Existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Choose existing"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  imagePickerController.allowsEditing = false;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    inputReview = textField.text;
}

#pragma mark imagepickerdelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    uploadedImage = image;
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
