//
//  SearchViewController.h
//  Foodwise
//
//  Created by Brian Wong on 8/26/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *nearbyRestaurants;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@end
