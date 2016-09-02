//
//  PriceRestaurant.h
//  Foodwise
//
//  Created by Brian Wong on 8/25/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

//This model object utilizes Foursquare's restaurant data as well as our own crowdsourced prices. The data in these are saved to Firebase.
@interface PriceRestaurant : NSObject

//Restaurant info
@property (strong, nonatomic) NSString *restaurantId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *formattedAddress;
@property (strong, nonatomic) NSString *formattedPhoneNumber;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *shortCategory;

@property (strong, nonatomic) NSNumber *phoneNumber;//Used to hash this model object for set comparison.
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSNumber *priceRating;
@property (strong, nonatomic) NSNumber *distance; //Distance from current position (in miles)

@property (strong, nonatomic) NSMutableArray *keywords;
@property (strong, nonatomic) NSMutableArray *categories;

//Price data
@property (strong, nonatomic) NSDictionary *individualPrices;
@property (strong, nonatomic) NSDictionary *groupPrices;
@property (strong, nonatomic) NSNumber *individualAvgPrice;
@property (strong, nonatomic) NSNumber *upperIndividualAvgPrice;
@property (strong, nonatomic) NSNumber *groupAvgPrice;
@property (strong, nonatomic) NSNumber *upperGroupAvgPrice;

//Restaurant details
@property (strong, nonatomic) NSDictionary *addOns;
@property (strong, nonatomic) NSMutableArray *keyWords;

- (instancetype)initWithId:(NSString*)restaurantId andFoursquareDictionary:(NSDictionary*)dictionary;

#pragma Do local updates for anything the user can change/input
//For local update to get data back right away. Send to firebase after updating UI
- (NSNumber*)updateCurrentAverage:(NSNumber*)newPrice;

@end
