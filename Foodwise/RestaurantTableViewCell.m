
//
//  RestaurantTableViewCell.m
//  Foodwise
//
//  Created by Brian Wong on 8/20/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "RestaurantTableViewCell.h"
#import "LayoutBounds.h"

@implementation RestaurantTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect cellFrame = self.frame;
        
        self.priceContainerView = [[UIView alloc]initWithFrame:CGRectMake(3.0, 3.0, cellFrame.size.width * 0.23, 63.0)];
        self.priceContainerView.layer.cornerRadius = 9.0;
        self.priceContainerView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.priceContainerView];
        
        self.ratingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.priceContainerView.frame.size.width/2 - self.priceContainerView.frame.size.width * 0.475, self.priceContainerView.frame.size.height/2 - 29.0, self.priceContainerView.frame.size.width * 0.95, 58.0)];
        self.ratingLabel.textAlignment = NSTextAlignmentCenter;
        self.ratingLabel.font = [UIFont systemFontOfSize:18.0];
        [self.priceContainerView addSubview:self.ratingLabel];
        
        self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(cellFrame.size.width, 3.0, 50.0, 30.0)];
        self.distanceLabel.textAlignment = NSTextAlignmentCenter;
        self.distanceLabel.font = [UIFont systemFontOfSize:13.0];
        self.distanceLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.distanceLabel];

//        self.displayImage = [[UIImageView alloc]initWithFrame:CGRectMake(3.0, 3.0, cellFrame.size.width * 0.23, 63.0)];
//        self.displayImage.layer.cornerRadius = 8.0;
//        self.displayImage.backgroundColor = [UIColor whiteColor];
//        self.displayImage.contentMode = UIViewContentModeScaleAspectFit;
//        [self.contentView addSubview:self.displayImage];
        
        self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceContainerView.frame) + 5.0, 10.0, cellFrame.size.width * 0.5, cellFrame.size.height * 0.4)];
        self.restaurantName.font = [UIFont systemFontOfSize:18.0];
        self.restaurantName.backgroundColor = [UIColor clearColor];
        self.restaurantName.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.restaurantName];
        
        self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceContainerView.frame) + 5.0, cellFrame.size.height - 5.0, cellFrame.size.width * 0.5, cellFrame.size.height * 0.4)];
        self.addressLabel.font = [UIFont systemFontOfSize:18.0];
        self.addressLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.addressLabel];
        
    }
    return self;
}

@end
