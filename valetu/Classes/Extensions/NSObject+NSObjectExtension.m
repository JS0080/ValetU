//
//  NSObject+NSObjectExtension.m
//  Pipol
//
//  Created by HiTechLtd on 2/24/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#import "NSObject+NSObjectExtension.h"

@implementation NSObject (NSObjectExtension)

+(NSString*)identifier {
    return NSStringFromClass([self class]);
}
@end