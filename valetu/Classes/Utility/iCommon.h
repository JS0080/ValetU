//
//  iCommon.h
//  valetu
//
//  Created by imobile on 2016-09-23.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface iCommon : NSObject

+ (void) getUberETAWithCompletion: (CLLocation*) pickupLocation completion:  (void (^)(NSDictionary* uberData, NSString* string, BOOL status))completionBlock;

+(void) loginWithFB:(UIViewController*) viewController;

@end

NS_ASSUME_NONNULL_END