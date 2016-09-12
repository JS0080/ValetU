//
//  NSString+Help.h
//  Pipol
//
//  Created by HiTechLtd on 3/2/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Help)

- (BOOL)isEmpty;
- (NSString *)urlEncode;
- (NSString *)md5;
- (BOOL)isValidEmail;
- (BOOL)isCheckWhitleSpace;
@end
