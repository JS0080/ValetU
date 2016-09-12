//
//  UIView+UIViewExtension.m
//  Pipol
//
//  Created by HiTechLtd on 2/24/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#import "UIView+UIViewExtension.h"

@implementation UIView (UIViewExtension)

+(NSString*)identifier {
    return NSStringFromClass([self class]);
}

@end
