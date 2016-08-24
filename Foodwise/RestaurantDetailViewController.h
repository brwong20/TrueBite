//
//  RestaurantDetailViewController.h
//  Foodwise
//
//  Created by Brian Wong on 8/23/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Restaurant.h"

@interface RestaurantDetailViewController : UIViewController

@property (nonatomic, strong)Restaurant *selectedRestaurant;

@end
