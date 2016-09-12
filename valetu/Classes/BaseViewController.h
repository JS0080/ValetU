//
//  BaseViewController.h
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void) initNavigation;

- (void)resetAccessToken;

- (AppDelegate*) app;

- (void) fetchNearbyResult: (CLLocationCoordinate2D) location withCompletion: (void (^)(void))completionBlock;

- (void) logout;

- (void) viewProfile;

@end
