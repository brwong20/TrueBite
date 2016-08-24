//
//  Restaurant.h
//  Foodwise
//
//  Created by Brian Wong on 8/21/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

//Metadata
@property (strong, nonatomic) NSString *restaurantId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *formattedAddress;
@property (strong, nonatomic) NSString *formattedPhoneNumber;
@property (strong, nonatomic) NSString *imageURL;

@property (strong, nonatomic) NSNumber *phoneNumber;//Used to hash this model object for set comparison.
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSNumber *priceRating;
@property (strong, nonatomic) NSNumber *distance; //Distance from current position (in miles)

@property (strong, nonatomic) NSMutableArray *keywords;
@property (strong, nonatomic) NSMutableArray *categories;

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

- (NSNumber*)individualAvgPrice;
- (NSNumber*)upperIndividualAvgPrice;

@end
