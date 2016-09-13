//
//  MealCameraController.h
//  TrueBite
//
//  Created by Brian Wong on 9/5/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoursquareRestaurant.h"

@interface MealCameraController : UIViewController

@property (nonatomic, strong) FoursquareRestaurant *selectedRestaurant;

@end
