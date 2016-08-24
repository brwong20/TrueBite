//
//  Restaurant.m
//  Foodwise
//
//  Created by Brian Wong on 8/21/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSString *restId = dictionary[@"venue"][@"id"];
    NSString *name = dictionary[@"venue"][@"name"];
    NSString *address = dictionary[@"venue"][@"location"][@"address"];
    NSString *formattedAddress = dictionary[@"venue"][@"location"][@"formattedAddress"];
    NSString *formattedPhone = dictionary[@"venue"][@"contact"][@"formattedPhone"];
    
    NSNumber *latitude = dictionary[@"venue"][@"location"][@"lat"];
    NSNumber *longitude = dictionary[@"venue"][@"location"][@"lng"];
    NSNumber *rating = dictionary[@"venue"][@"rating"];
    NSNumber *priceRating = dictionary[@"venue"][@"price"][@"tier"];
    NSNumber *phoneNumber = dictionary[@"venue"][@"contact"][@"phone"];
    NSNumber *distance = dictionary[@"venue"][@"location"][@"distance"];
    //NSString *imageURL = dictionary[@"venue"]
    
    self.individualPrices = [[NSMutableArray alloc]init];
    self.individualAvgPrice = [NSNumber numberWithDouble:0.00];
    self.groupPrices = [[NSMutableArray alloc]init];
    
    if (restId && [restId isKindOfClass:[NSString class]]) {
        self.restaurantId = restId;
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
    
    if (phoneNumber && [phoneNumber isKindOfClass:[NSNumber class]]) {
        self.phoneNumber = phoneNumber;
    }
    
    if (rating && [rating isKindOfClass:[NSNumber class]]) {
        self.rating = rating;
    }
    else
    {
        self.rating = @(0.0);
    }
    
    if (distance && [distance isKindOfClass:[NSNumber class]]) {
        double miles = distance.doubleValue * 0.000621371192;
        self.distance = [NSNumber numberWithDouble:miles];//Meters converted to miles
    }
    
    return self;
}

#pragma mark - Overridden comparison methods to be used with NSSet.

//Both of these need to be overriden for comparison to work in dictionaries, sets, etc.!
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[Restaurant class]]) {
        Restaurant *other = object;
        return ([self.restaurantId isEqualToString:other.restaurantId]);
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.phoneNumber integerValue];
}

//-(NSNumber *)individualAvgPrice
//{
//    
//}

@end
