//
//  Restaurant.m
//  Foodwise
//
//  Created by Brian Wong on 8/21/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "FoursquareRestaurant.h"
#import "FoodwiseDefines.h"

@implementation FoursquareRestaurant

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSString *restId = dictionary[@"venue"][@"id"];
    NSString *name = dictionary[@"venue"][@"name"];
    NSString *shortAddress = dictionary[@"venue"][@"location"][@"address"];
    NSString *city = dictionary[@"venue"][@"location"][@"city"];
    NSString *formattedPhone = dictionary[@"venue"][@"contact"][@"formattedPhone"];
    NSArray *categories = dictionary[@"venue"][@"categories"];
    NSArray *addressArr = dictionary[@"venue"][@"location"][@"formattedAddress"];
    
    NSNumber *isOpen = dictionary[@"venue"][@"hours"][@"isOpen"];
    
    NSString *menuLink = dictionary[@"venue"][@"menu"][@"mobileUrl"];
    
    NSNumber *latitude = dictionary[@"venue"][@"location"][@"lat"];
    NSNumber *longitude = dictionary[@"venue"][@"location"][@"lng"];
    NSNumber *rating = dictionary[@"venue"][@"rating"];
    NSNumber *priceTier= dictionary[@"venue"][@"price"][@"tier"];
    NSNumber *distance = dictionary[@"venue"][@"location"][@"distance"];

    //Photo URLs are composed of 3 things: a prefix, suffix, and size (width x height)
    NSArray *featuredPhotos = dictionary[@"venue"][@"featuredPhotos"][@"items"];
    
    self.individualPrices = [[NSMutableArray alloc]init];
    self.groupPrices = [[NSMutableArray alloc]init];
    self.individualAvgPrice = [NSNumber numberWithDouble:0.0];
    self.hoursOfDay = @{};
    
    if (restId && [restId isKindOfClass:[NSString class]]) {
        self.restaurantId = restId;
    }
    else{
        self.restaurantId = @"";
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
        self.latitude = @(0.0);
    }
    
    if (longitude && [longitude isKindOfClass:[NSNumber class]]) {
        self.longitude = longitude;
    }
    else
    {
        self.longitude = @(0.0);
    }
    
    if (addressArr && [addressArr isKindOfClass:[NSArray class]]) {
        if (addressArr.count > 2) {
            self.formattedAddress = [NSString stringWithFormat:@"%@\n%@", [addressArr objectAtIndex:0], [addressArr objectAtIndex:1]];
        }else{
            self.formattedAddress = @"";
        }
    }
    else
    {
        self.formattedAddress = @"";
    }
    
    if (shortAddress && city && [shortAddress isKindOfClass:[NSString class]] && [city isKindOfClass:[NSString class]]) {
        self.shortAddress = [NSString stringWithFormat:@"%@, %@", shortAddress, city];
    }
    else
    {
        self.shortAddress = @"";
    }
    
    if (formattedPhone && [formattedPhone isKindOfClass:[NSString class]]) {
        self.formattedPhoneNumber = formattedPhone;
    }
    else
    {
       self.formattedPhoneNumber = @"";
    }
    
    if (categories && [categories isKindOfClass:[NSArray class]]) {
        NSDictionary *categoryDict = [categories firstObject];
        NSString *categoryName = categoryDict[@"name"];
        NSString *shortName = categoryDict[@"shortName"];
        
        if (categoryName && [categoryName isKindOfClass:[NSString class]]) {
            self.category = categoryName;
        }
        
        if (shortName && [shortName isKindOfClass:[NSString class]]) {
            self.shortCategory = shortName;
        }
    }
    else
    {
        self.category = @"";
        self.shortCategory = @"";
    }
    
    if (priceTier && [priceTier isKindOfClass:[NSNumber class]]) {
        self.priceTier = priceTier;
    }
    else
    {
        self.priceTier = @(1);
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
    
    if (menuLink && [menuLink isKindOfClass:[NSString class]]) {
        self.menuURL = menuLink;
    }else{
        self.menuURL = @"";
    }
    
    if (isOpen && [isOpen isKindOfClass:[NSNumber class]]) {
        self.openNow = isOpen.boolValue;
    }else{
        self.openNow = NO;
    }
    
    if (featuredPhotos && [featuredPhotos isKindOfClass:[NSArray class]] && featuredPhotos.count > 0)
    {
        NSDictionary *photoDict = [featuredPhotos firstObject];
        NSString *prefix = photoDict[@"prefix"];
        NSString *suffix = photoDict[@"suffix"];
            
        self.featuredImageURL = [NSString stringWithFormat:@"%@%@%@", prefix, SMALL_PHOTO_SIZE, suffix];
        
    }
    else
    {
        self.featuredImageURL = @"";
    }

    return self;
}

- (instancetype)initWithMiniDictionary:(NSDictionary *)dictionary
{
    NSString *restId = dictionary[@"id"];
    NSString *name = dictionary[@"name"];
    NSString *shortAddress = dictionary[@"location"][@"address"];
    NSString *city = dictionary[@"location"][@"city"];
    
    if (restId && [restId isKindOfClass:[NSString class]]) {
        self.restaurantId = restId;
    }
    else{
        self.restaurantId = @"";
    }
    
    if (name && [name isKindOfClass:[NSString class]]) {
        self.name = name;
    }
    else
    {
        self.name = @"";
    }
    
    if (shortAddress && city && [shortAddress isKindOfClass:[NSString class]] && [city isKindOfClass:[NSString class]]) {
        self.shortAddress = [NSString stringWithFormat:@"%@, %@", shortAddress, city];
    }
    else
    {
        self.shortAddress = @"";
    }
    return self;
}

- (instancetype)initWithDetailedDictionary:(NSDictionary*)dictionary andId:(NSString *)restaurantId
{
    NSString *name = dictionary[@"name"];
    NSString *shortAddress = dictionary[@"location"][@"address"];
    NSString *city = dictionary[@"location"][@"city"];
    NSArray *addressArr = dictionary[@"location"][@"formattedAddress"];
    NSNumber *latitude = dictionary[@"location"][@"lat"];
    NSNumber *longitude = dictionary[@"location"][@"lng"];
    NSString *formattedPhone = dictionary[@"contact"][@"formattedPhone"];
    NSString *ratingString = dictionary[@"rating"];
    NSNumber *priceTier = dictionary[@"details"][@"tier"];
    NSArray *categories = dictionary[@"categories"];
    NSString *menuLink = dictionary[@"menu"][@"mobileUrl"];
    
    self.restaurantId = restaurantId;
    
    self.individualAvgPrice = @(0.0);
    self.individualPrices = [[NSMutableArray alloc]init];
    
    if (name && [name isKindOfClass:[NSString class]]) {
        self.name = name;
    }
    else
    {
        self.name = @"";
    }
    
    if (latitude && [latitude isKindOfClass:[NSNumber class]]) {
        self.latitude = [NSNumber numberWithDouble:latitude.doubleValue];
    }
    else
    {
        self.latitude = @(0.0);
    }
    
    if (longitude && [longitude isKindOfClass:[NSNumber class]]) {
        self.longitude = [NSNumber numberWithDouble:latitude.doubleValue];
    }
    else
    {
        self.longitude = @(0.0);
    }
    
    if (addressArr && [addressArr isKindOfClass:[NSArray class]]) {
        if (addressArr.count > 2) {
            self.formattedAddress = [NSString stringWithFormat:@"%@\n%@", [addressArr objectAtIndex:0], [addressArr objectAtIndex:1]];
        }else{
            self.formattedAddress = @"";
        }
    }
    else
    {
        self.formattedAddress = @"";
    }
    
    if (shortAddress && city && [shortAddress isKindOfClass:[NSString class]] && [city isKindOfClass:[NSString class]]) {
        self.shortAddress = [NSString stringWithFormat:@"%@, %@", shortAddress, city];
    }
    else
    {
        self.shortAddress = @"";
    }
    
    if (formattedPhone && [formattedPhone isKindOfClass:[NSString class]]) {
        self.formattedPhoneNumber = formattedPhone;
    }
    else
    {
        self.formattedPhoneNumber = @"";
    }
    
    if (categories && [categories isKindOfClass:[NSArray class]]) {
        NSDictionary *categoryDict = [categories firstObject];
        NSString *categoryName = categoryDict[@"name"];
        NSString *shortName = categoryDict[@"shortName"];
        
        if (categoryName && [categoryName isKindOfClass:[NSString class]]) {
            self.category = categoryName;
        }
        
        if (shortName && [shortName isKindOfClass:[NSString class]]) {
            self.shortCategory = shortName;
        }
    }
    else
    {
        self.category = @"";
        self.shortCategory = @"";
    }
    
    if (priceTier && [priceTier isKindOfClass:[NSNumber class]]) {
        self.priceTier = priceTier;
    }
    else
    {
        self.priceTier = @(1);
    }
    
    if (ratingString && [ratingString isKindOfClass:[NSString class]]) {
        self.rating = [NSNumber numberWithDouble:ratingString.doubleValue];
    }
    else
    {
        self.rating = @(0.0);
    }

    if (menuLink && [menuLink isKindOfClass:[NSString class]]) {
        self.menuURL = menuLink;
    }else{
        self.menuURL = @"";
    }

    return self;
}

- (NSDictionary *)fireBaseDictionary
{
    NSDictionary *restaurantDict = @{@"name":self.name, @"address":self.shortAddress, @"formattedAddress":self.formattedAddress, @"longitude": self.longitude, @"latitude": self.latitude, @"formattedPhoneNumber":self.formattedPhoneNumber, @"rating":self.rating, @"priceRating":self.priceTier, @"category":self.category, @"shortCategory":self.shortCategory, @"menuUrl":self.menuURL, @"featuredPhoto": self.featuredImageURL} ;
    
    return restaurantDict;
}

- (void)retrievePriceDataFrom:(NSDictionary*)existingRestaurant
{
    NSNumber *avgIndvPrice = existingRestaurant[@"individualAvgPrice"];
    NSDictionary *indvPrices = existingRestaurant[@"individualPrices"];//Dictionary of key values since we link {userId:price} in order to only let them submit/update a single price.
    
    if (avgIndvPrice && [avgIndvPrice isKindOfClass:[NSNumber class]]) {
        self.individualAvgPrice = avgIndvPrice;
    }
    else
    {
        self.individualAvgPrice = @(0.0);
    }
    
    if (indvPrices && [indvPrices isKindOfClass:[NSDictionary class]]) {
        [self.individualPrices addObjectsFromArray:[indvPrices allValues]];
    }
}

- (void)calculateAveragePrice
{
    double total = 0.0;
    if (self.individualPrices.count > 0) {
        for (NSNumber *price in self.individualPrices) {
            total += price.doubleValue;
        }
        total /= self.individualPrices.count;
        self.individualAvgPrice = [NSNumber numberWithDouble:total];
    }
}

#pragma mark - Overridden comparison methods to be used with NSSet.

//Both of these need to be overriden for comparison to work in dictionaries, sets, etc.!
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[FoursquareRestaurant class]]) {
        FoursquareRestaurant *other = object;
        return ([self.restaurantId isEqualToString:other.restaurantId]);
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.restaurantId integerValue];
}

@end
