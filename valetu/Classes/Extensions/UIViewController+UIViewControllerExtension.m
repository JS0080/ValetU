//
//  UIViewController+UIViewControllerExtension.m
//  Pipol
//
//  Created by HiTechLtd on 2/24/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#import "UIViewController+UIViewControllerExtension.h"

@implementation UIViewController (UIViewControllerExtension)

+(NSString*)identifier {
    return NSStringFromClass([self class]);
}
@end
