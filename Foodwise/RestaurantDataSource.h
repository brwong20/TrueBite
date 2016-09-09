//
//  RestaurantDataSource.h
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantDataSource : NSObject

-(void)retrieveNearbyRestaurantsWithLatitude:(NSString *)latitude
                                   longitude:(NSString*)longitude
                                  withRadius:(NSString*)radius
                           completionHandler:(void (^)(id JSON)) completionHandler
                              failureHandler:(void (^)(id error))failureHandler;

- (void)getRestaurantDetailsFor:(NSString*)restaurantId
              completionHandler:(void (^)(id JSON))completionHandler
                 failureHandler:(void (^)(id error))failureHandler;

- (void)getPhotosForRestaurant:(NSString*)restaurantId
             completionHandler:(void (^)(id JSON))completionHandler
                failureHandler:(void (^)(id error))failureHandler;

- (void)autoCompleteWithQuery:(NSString*)query withLatitude:(NSString*)latitude andLogitude:(NSString*)longitude
            completionHandler:(void (^)(id JSON))completionHandler
               failureHandler:(void (^)(id error))failureHandler;

@end
