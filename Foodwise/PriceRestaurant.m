//
//  PriceRestaurant.m
//  Foodwise
//
//  Created by Brian Wong on 8/25/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "PriceRestaurant.h"

@implementation PriceRestaurant

- (instancetype)initWithId:(NSString*)restaurantId andFoursquareDictionary:(NSDictionary *)dictionary
{
    NSString *name = dictionary[@"name"];
    NSString *address = dictionary[@"address"];
    NSString *formattedAddress = dictionary[@"formattedAddress"];
    NSString *formattedPhone = dictionary[@"formattedPhoneNumber"];
    NSString *category = dictionary[@"category"];
    NSString *shortCategory = dictionary[@"shortCategory"];
    
    
    NSNumber *latitude = dictionary[@"latitude"];
    NSNumber *longitude = dictionary[@"longitude"];
    NSNumber *rating = dictionary[@"rating"];
    NSNumber *priceRating = dictionary[@"priceRating"];
    //NSNumber *phoneNumber = dictionary[@"venue"][@"contact"][@"phone"];
    NSNumber *distance = dictionary[@"distance"];
    //NSString *imageURL = dictionary[@"venue"]
    
    NSNumber *avgIndvPrice = dictionary[@"individualAvgPrice"];
    NSDictionary *indvPrices = dictionary[@"individualPrices"];//Dictionary of key values since we link {userId:price} in order to only let them submit/update a single price.
    
    if (restaurantId && [restaurantId isKindOfClass:[NSString class]]) {
        self.restaurantId = restaurantId;
    }
    else{
        
    }
    
    if (name && [name isKindOfClass:[NSString class]]) {
        self.name = name;
    }
    else
    {
        self.name = @"";
    }
    
    if (latitude && [latitude isKindOfClass:[NSNumber class]]) {
        self.latitude = latitude;
    }
    else
    {
        
    }
    
    if (longitude && [longitude isKindOfClass:[NSNumber class]]) {
        self.longitude = longitude;
    }
    else
    {
        
    }
    
    if (address && [address isKindOfClass:[NSString class]]) {
        self.address = address;
    }
    else
    {
        self.address = @"";
    }
    
    if (formattedAddress && [formattedAddress isKindOfClass:[NSString class]]) {
        self.formattedAddress = formattedAddress;
    }
    else
    {
        
    }
    
    if (category && [category isKindOfClass:[NSString class]]) {
        self.category = category;
    }
    else
    {
        self.category = @"";
    }
    
    if (shortCategory && [shortCategory isKindOfClass:[NSString class]]) {
        self.shortCategory = shortCategory;
    }
    else
    {
        self.shortCategory = @"";
    }
    
    if (formattedPhone && [formattedPhone isKindOfClass:[NSString class]]) {
        self.formattedPhoneNumber = formattedPhone;
    }
    else
    {
        self.formattedPhoneNumber = @"";
    }
    
    if (priceRating && [priceRating isKindOfClass:[NSNumber class]]) {
        self.priceRating = priceRating;
    }
    else
    {
        
    }
    
//    if (phoneNumber && [phoneNumber isKindOfClass:[NSNumber class]]) {
//        self.phoneNumber = phoneNumber;
//    }
    
    if (rating && [rating isKindOfClass:[NSNumber class]]) {
        self.rating = rating;
    }
    else
    {
        self.rating = @(0.0);
    }
    
    if (distance && [distance isKindOfClass:[NSNumber class]]) {
        self.distance = distance;
    }
    
    if (avgIndvPrice && [avgIndvPrice isKindOfClass:[NSNumber class]]) {
        self.individualAvgPrice = avgIndvPrice;
    }
    else
    {
        self.individualAvgPrice = @(0.0);
    }
    
    if (indvPrices && [indvPrices isKindOfClass:[NSDictionary class]]) {
        self.individualPrices = indvPrices;
    }
    else{
        self.individualPrices = @{};
    }
    
    return self;
}


@end
