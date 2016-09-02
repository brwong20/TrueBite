//
//  PriceUpdateController.h
//  Foodwise
//
//  Created by Brian Wong on 8/25/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoursquareRestaurant.h"

@interface PriceUpdateController : UIViewController

@property (nonatomic, strong) FoursquareRestaurant *selectedRestaurant;
@property (nonatomic, assign) BOOL searchFlow;

@end
