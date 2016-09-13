//
//  AssetSendViewController.h
//  TrueBite
//
//  Created by Brian Wong on 9/5/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoursquareRestaurant.h"

@interface AssetSendViewController : UIViewController

@property (nonatomic, strong) FoursquareRestaurant *selectedRestaurant;
@property (nonatomic, strong) UIImage *selectedImage;

@end
