//
//  Restaurant.h
//  Foodwise
//
//  Created by Brian Wong on 8/21/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoursquareRestaurant : NSObject

//Metadata
@property (strong, nonatomic) NSString *restaurantId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *shortAddress;
@property (strong, nonatomic) NSString *formattedAddress;
@property (strong, nonatomic) NSString *formattedPhoneNumber;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *shortCategory;
@property (strong, nonatomic) NSString *menuURL;

@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSNumber *priceTier;//$, $$, etc.
@property (strong, nonatomic) NSNumber *distance; //Distance from current position (in miles)

@property (nonatomic, strong) NSDictionary *hoursOfDay;

@property (assign, nonatomic) BOOL openNow;

//Price data
@property (strong, nonatomic) NSMutableArray *individualPrices;
@property (strong, nonatomic) NSMutableArray *groupPrices;
@property (strong, nonatomic) NSNumber *individualAvgPrice;
@property (strong, nonatomic) NSNumber *upperIndividualAvgPrice;
@property (strong, nonatomic) NSNumber *groupAvgPrice;
@property (strong, nonatomic) NSNumber *upperGroupAvgPrice;

//Restaurant details
@property (strong, nonatomic) NSDictionary *addOns;
@property (strong, nonatomic) NSMutableArray *keyWords;


- (BOOL)isEqual:(id)object;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
//For our search functionality since Foursquare returns "minivenues" which has much less of the same data
- (instancetype)initWithMiniDictionary:(NSDictionary*)dictionary;
//For searching a new restaurant and adding it to db
- (instancetype)initWithDetailedDictionary:(NSDictionary*)dictionary andId:(NSString*)restaurantId;
//Updates current object with data from Firebase
- (void)retrievePriceDataFrom:(NSDictionary*)existingRestaurant;

- (void)calculateAveragePrice;

- (NSDictionary*)fireBaseDictionary;
- (NSNumber*)individualAvgPrice;
- (NSNumber*)upperIndividualAvgPrice;

@end
