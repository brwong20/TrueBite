//
//  RestaurantDataSource.h
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantDataSource : NSObject

-(void)retrieveNearbyRestaurantsWithLatitude:(NSString *)latitude longitude:(NSString*)longitude
                           completionHandler:(void (^)(id JSON)) completionHandler
                              failureHandler:(void (^)(id error))failureHandler;

- (void)getRestaurantDetailsFor:(NSString*)restauarantId
              completionHandler:(void (^)(id JSON))completionHandler
                 failureHandler:(void (^)(id error))failureHandler;

- (void)getHoursForRestaurant:(NSString*)restauarantId
              completionHandler:(void (^)(id JSON))completionHandler
               failureHandler:(void (^)(id error))failureHandler;

- (void)autoCompleteWithQuery:(NSString*)query withLatitude:(NSString*)latitude andLogitude:(NSString*)longitude
            completionHandler:(void (^)(id JSON))completionHandler
               failureHandler:(void (^)(id error))failureHandler;

@end
