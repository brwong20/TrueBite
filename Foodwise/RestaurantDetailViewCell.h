//
//  RestaurantDetailViewCell.h
//  Foodwise
//
//  Created by Brian Wong on 8/27/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoursquareRestaurant.h"
#import "StarRatingView.h"

@protocol RestaurantDetailCellDelegate <NSObject>

- (void)priceButtonClicked;

@end

@interface RestaurantDetailViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *category;
@property (nonatomic, strong) UILabel *distance;
@property (nonatomic, strong) UILabel *ratingsCountLabel;

@property (nonatomic, strong) UIView *priceContainer;
@property (nonatomic, strong) UILabel *averagePrice;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIButton *submitPriceButton;

@property (nonatomic, strong) StarRatingView *starRatingView;

@property (nonatomic, weak)id<RestaurantDetailCellDelegate>delegate;

- (void)populateCellTypeWithData:(FoursquareRestaurant*)selectedRestaurant;

@end
