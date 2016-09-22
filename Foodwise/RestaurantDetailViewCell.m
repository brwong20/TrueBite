//
//  RestaurantDetailViewCell.m
//  Foodwise
//
//  Created by Brian Wong on 8/27/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "RestaurantDetailViewCell.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"

@interface RestaurantDetailViewCell()

@end

@implementation RestaurantDetailViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self) {
        
        self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 5.0, self.frame.size.width * 0.6, 22.0)];
        self.restaurantName.numberOfLines = 0;
        self.restaurantName.font = [UIFont semiboldFontWithSize:21.0];
        self.restaurantName.textColor = APPLICATION_FONT_COLOR;
        self.restaurantName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.restaurantName];
        
        self.category = [[UILabel alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.restaurantName.frame), self.frame.size.width * 0.6, 14.0)];
        self.category.font = [UIFont mediumFontWithSize:13.0];
        self.category.textColor = [UIColor lightGrayColor];
        self.category.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.category];
        
        self.starRatingView = [[StarRatingView alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.category.frame) + 2.0 + self.frame.size.height * 0.07, APPLICATION_FRAME.size.width * 0.31, APPLICATION_FRAME.size.height * 0.03)];
        [self.contentView addSubview:self.starRatingView];
        
        self.ratingsCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.starRatingView.frame), APPLICATION_FRAME.size.width * 0.22, 14.0)];
        self.ratingsCountLabel.textColor = [UIColor lightGrayColor];
        self.ratingsCountLabel.font = [UIFont fontWithSize:13.0];
        self.ratingsCountLabel.text = NSTextAlignmentLeft;
        self.ratingsCountLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.ratingsCountLabel];
        
        self.distance = [[UILabel alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.ratingsCountLabel.frame) + 4.0, APPLICATION_FRAME.size.width * 0.22, 14.0)];
        self.distance.font = [UIFont fontWithSize:13.0];
        self.distance.textColor = [UIColor lightGrayColor];
        self.distance.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.distance];
        
        self.priceContainer = [[UIView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - self.frame.size.width * 0.37, CGRectGetMaxY(self.restaurantName.frame), self.frame.size.width * 0.35, 45.0)];
        self.priceContainer.layer.borderColor = [UIColor clearColor].CGColor;
        //self.priceContainer.layer.borderWidth = 1.5;
        [self.contentView addSubview:self.priceContainer];
        
        self.averagePrice = [[UILabel alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - self.priceContainer.frame.size.width * 0.475, 0, self.priceContainer.frame.size.width * 0.95, 16.0)];
        self.averagePrice.font = [UIFont fontWithSize:14.0];
        self.averagePrice.textColor = UIColorFromRGB(0x7A95A7);
        self.averagePrice.text = @"Average meal";
        self.averagePrice.textAlignment = NSTextAlignmentCenter;
        [self.priceContainer addSubview:self.averagePrice];
        
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - self.priceContainer.frame.size.width * 0.4, self.priceContainer.frame.size.height/1.5 - self.priceContainer.frame.size.height * 0.275, self.priceContainer.frame.size.width * 0.8, self.priceContainer.frame.size.height * 0.45)];
        self.priceLabel.font = [UIFont semiboldFontWithSize:22.0];
        self.priceLabel.textColor = UIColorFromRGB(0x7AD313);
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        [self.priceContainer addSubview:self.priceLabel];
        
        self.submitPriceButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.priceContainer.frame) - self.priceContainer.frame.size.width * 0.475, CGRectGetMaxY(self.priceContainer.frame) + 1.0, self.priceContainer.frame.size.width * 0.95, 32.0)];
        self.submitPriceButton.layer.cornerRadius = 9.0;
        self.submitPriceButton.titleLabel.font = [UIFont semiboldFontWithSize:16.0];
        [self.submitPriceButton setBackgroundColor:UIColorFromRGB(0x17A1FF)];
        [self.submitPriceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.submitPriceButton setTitle:@"Update Price" forState:UIControlStateNormal];
        [self.submitPriceButton addTarget:self action:@selector(clickedPriceButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.submitPriceButton];
        
        //[LayoutBounds drawBoundsForAllLayers:self];
    }
    
    return self;
}

//Restaurant object is passed to populate appropritate cell
- (void)populateCellTypeWithData:(FoursquareRestaurant*)selectedRestaurant
{
    //If the title is long, we have to push the other views under it down...
    self.restaurantName.text = selectedRestaurant.name;
    [self.restaurantName sizeToFit];

    CGRect categoryFrame = self.category.frame;
    categoryFrame.origin.y = CGRectGetMaxY(self.restaurantName.frame);
    self.category.frame = categoryFrame;
    
    CGRect starFrame = self.starRatingView.frame;
    starFrame.origin.y = CGRectGetMaxY(self.category.frame) + 2.0;
    self.starRatingView.frame = starFrame;
    
    CGRect ratingsFrame = self.ratingsCountLabel.frame;
    ratingsFrame.origin.y = CGRectGetMaxY(self.starRatingView.frame) + 2.0;
    self.ratingsCountLabel.frame = ratingsFrame;
    
    CGRect distanceFrame = self.distance.frame;
    distanceFrame.origin.y = CGRectGetMaxY(self.ratingsCountLabel.frame);
    self.distance.frame = distanceFrame;
}

- (void)clickedPriceButton
{
    if ([self.delegate respondsToSelector:@selector(priceButtonClicked)]) {
        [self.delegate priceButtonClicked];
    }
}

@end
