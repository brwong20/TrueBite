
//
//  RestaurantTableViewCell.m
//  Foodwise
//
//  Created by Brian Wong on 8/20/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "RestaurantTableViewCell.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"
#import "UIFont+Extension.h"

@implementation RestaurantTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect cellFrame = self.frame;
        
        self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 7.0, cellFrame.size.width * 0.78, 25.0)];
        self.restaurantName.font = [UIFont semiboldFontWithSize:18.0];
        self.restaurantName.textColor = APPLICATION_FONT_COLOR;
        self.restaurantName.backgroundColor = [UIColor clearColor];
        self.restaurantName.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.restaurantName];
        
        self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - cellFrame.size.width * 0.17, 10.0, cellFrame.size.width * 0.15, 15.0)];
        self.distanceLabel.textAlignment = NSTextAlignmentRight;
        self.distanceLabel.textColor = [UIColor lightGrayColor];
        self.distanceLabel.font = [UIFont fontWithSize:13.0];
        self.distanceLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.distanceLabel];

        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - cellFrame.size.width * 0.22, 33.0, cellFrame.size.width * 0.22, 40.0)];
        self.priceLabel.textColor = UIColorFromRGB(0x7AD313);
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        self.priceLabel.font = [UIFont semiboldFontWithSize:20.0];
        [self.contentView addSubview:self.priceLabel];
        
        self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.0, CGRectGetMaxY(self.restaurantName.frame) + 1.0, APPLICATION_FRAME.size.width * 0.7, 20.0)];
        self.categoryLabel.textColor = [UIColor grayColor];
        self.categoryLabel.font = [UIFont semiboldFontWithSize:14.0];
        self.categoryLabel.textAlignment = NSTextAlignmentLeft;
        self.categoryLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.categoryLabel];
        
        self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.0, CGRectGetMaxY(self.categoryLabel.frame), APPLICATION_FRAME.size.width * 0.7, 20.0)];
        self.addressLabel.font = [UIFont fontWithSize:14.0];
        self.addressLabel.textColor = [UIColor grayColor];
        self.addressLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.addressLabel];
        
        self.starRatingView = [[StarRatingView alloc]initWithFrame:CGRectMake(10.0, CGRectGetMaxY(self.addressLabel.frame) + cellFrame.size.height * 0.07, APPLICATION_FRAME.size.width * 0.31, APPLICATION_FRAME.size.height * 0.03)];
        [self.contentView addSubview:self.starRatingView];
        
        //[LayoutBounds drawBoundsForAllLayers:self];
    }
    return self;
}

@end
