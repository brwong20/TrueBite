//
//  RestaurantTableViewCell.h
//  Foodwise
//
//  Created by Brian Wong on 8/20/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarRatingView.h"

@interface RestaurantTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *categoryLabel;

@property (nonatomic, strong) UIImageView *displayImage;
@property (nonatomic, strong) UIView *priceContainerView;

@property (nonatomic, strong) StarRatingView *starRatingView;

@end
