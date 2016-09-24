//
//  MapViewController.h
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYBlurIntroductionView.h"

@interface MapViewController : BaseViewController<MYIntroductionDelegate>

@property (nonatomic) BOOL didFindMyLocation;
@end
