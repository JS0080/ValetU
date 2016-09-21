//
//  Parkinglot.m
//  valetu
//
//  Created by imobile on 2016-09-14.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "Parkinglot.h"

@implementation Parkinglot

//Class method to make sure the share model is synch across the app
+ (Parkinglot*)sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

+(NSMutableDictionary*)getParkinglot: (NSInteger) index
{
    NSMutableDictionary* parkinglot = [[NSMutableDictionary alloc] init];
    for (id lot in [self sharedModel].nearbyplaces) {
        if ([[lot objectForKey:@"id"] integerValue] == index) {
            parkinglot = lot;
            break;
        }
    }
    
    return parkinglot;
}

@end
