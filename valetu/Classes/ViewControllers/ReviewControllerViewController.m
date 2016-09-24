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

@interface ReviewControllerViewController ()< UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RNGridMenuDelegate>
{
    NSString* inputReview;
    UIImage* uploadedImage;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *estimatelabel;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starRatingView;

@end

@implementation ReviewControllerViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Review";
    self.contentSizeInPopup = CGSizeMake(324, 550);
    self.landscapeContentSizeInPopup = CGSizeMake(550, 324);
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTapGesture];
    
    CLLocationCoordinate2D pickuplocation = [Parkinglot sharedModel].pickupLocation.coordinate;
    
    self.mapView.camera = [GMSCameraPosition cameraWithTarget: pickuplocation zoom:11 bearing:0 viewingAngle:0];
    [self.mapView setMinZoom:3 maxZoom:20];
    
    GMSMarker*  pickupMarker = [GMSMarker markerWithPosition:pickuplocation];
    pickupMarker.map = self.mapView;

    pickupMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeActive.png"]];
    
    [self.uploadButton addTarget:self action:@selector(uploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    self.titlelabel.text = [parkinglot objectForKey:@"address"];
    self.placeLabel.text = [parkinglot objectForKey:@"address"];
    self.estimatelabel.text = [parkinglot objectForKey:@"estimate"];
    
    NSArray* comments = [parkinglot objectForKey:@"comments"];
    if([comments count] > 0)
    {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[comments[0] objectForKey:@"photourl"]]
                            placeholderImage:[UIImage imageNamed:@"streetview.jpeg"]];
    } else
    {
        NSString *phtoUrl = [NSString stringWithFormat:GOOGLE_STREET_VIEW_API_SMALL, [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:phtoUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
    
    uploadedImage = nil;
}

- (IBAction)didRteParking:(id)sender {
    if ([self isEverythingRight]) {
        [self saveData];
    } else {
        [ProgressHUD showError:ERROR_LOGIN];
    }
}

- (BOOL) isEverythingRight
{
    BOOL result = NO;
    
    if (uploadedImage != nil && self.starRatingView.value > 0) {
        result = YES;
    }
    return result;
}

- (void)saveBtnDidTap
{
    [Parkinglot sharedModel].userState = kStateNone;
    
    [Parkinglot sharedModel].userState = kStateNone;
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    NSString *parkinglot_id = [parkinglot objectForKey:@"id"];
    NSString *starValue = [NSString stringWithFormat:@"%ld", (long)self.starRatingView.value];
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
     [Parkinglot sharedModel].userState = kStateNone;
    
    [ProgressHUD show:UPLOADING Interaction:NO];
    
     NSData *imageData = UIImagePNGRepresentation(uploadedImage);
    [Parkinglot sharedModel].userState = kStateNone;
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    NSString *parkinglot_id = [parkinglot objectForKey:@"id"];
    NSString *starValue = [NSString stringWithFormat:@"%ld", (long)self.starRatingView.value];
    NSString *uuid = @"uuid";//[Parkinglot sharedModel].UUID;
    NSString *name = [NSString stringWithFormat:@"%@ %@",  [Parkinglot sharedModel].profile.firstName,  [Parkinglot sharedModel].profile.lastName];
    
    if (inputReview == nil)
    {
        inputReview = @"";
    }
    
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
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.popupController dismiss];
                        });
                  }];
    
    [uploadTask resume];

}

- (void) initTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
    
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void) respondToTapGesture: (id) sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark 

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    inputReview = textField.text;
}

#pragma mark imagepickerdelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    uploadedImage = image;
    self.imageView.image = uploadedImage;
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
