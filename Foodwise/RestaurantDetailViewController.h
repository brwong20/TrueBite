//
//  RestaurantDetailViewController.h
//  Foodwise
//
//  Created by Brian Wong on 8/23/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoursquareRestaurant.h"
#import "PriceRestaurant.h"

@interface RestaurantDetailViewController : UIViewController

@property (nonatomic, strong)FoursquareRestaurant *selectedRestaurant;

@end
