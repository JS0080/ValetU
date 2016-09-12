//
//  NSDictionary+NotNull.h
//  Pipol
//
//  Created by HiTechLtd on 3/7/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NotNull)

- (id)valueForKeyNotNull:(NSString *)key;
- (id)objectForKeyNotNull:(NSString *)key;
@end
