//
//  MapCell.h
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapCell : UITableViewCell
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end
