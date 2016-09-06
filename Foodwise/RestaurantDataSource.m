//
//  RestaurantDataSource.m
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <AFNetworking.h>
#import <AFHTTPSessionManager.h>

#import "RestaurantDataSource.h"
#import "FoodwiseDefines.h"

@implementation RestaurantDataSource

- (void)retrieveNearbyRestaurantsWithLatitude:(NSString *)latitude
                                    longitude:(NSString*)longitude
                                   withRadius:(NSString *)radius
                           completionHandler:(void (^)(id JSON))completionHandler
                              failureHandler:(void (^)(id error))failureHandler;
{
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@&client_secret=%@&v=%@&ll=%@,%@&radius=%@&price=%@&section=%@&venuePhotos=1&limit=50", FOURSQUARE_EXPLORE_BASE_URL, FOURSQUARE_API_KEY, FOURSQUARE_API_SECRET, @"20160820",latitude, longitude, radius, @"1", @"food"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.session.configuration.URLCache = [NSURLCache sharedURLCache];
    //[manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];

}

- (void)getRestaurantDetailsFor:(NSString*)restauarantId
            completionHandler:(void (^)(id JSON))completionHandler
               failureHandler:(void (^)(id error))failureHandler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?client_id=%@&client_secret=%@&v=%@", FOURSQUARE_VENUE_DETAILS_BASE_URL, restauarantId, FOURSQUARE_API_KEY, FOURSQUARE_API_SECRET, @"20160820"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];

}

//- (void)getHoursForRestaurant:(NSString *)restauarantId
//            completionHandler:(void (^)(id))completionHandler
//               failureHandler:(void (^)(id))failureHandler
//{
//    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/hours?client_id=%@&client_secret=%@&v=%@", restauarantId, FOURSQUARE_API_KEY, FOURSQUARE_API_SECRET, @"20160820"];
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        completionHandler(responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failureHandler(error);
//    }];
//}

- (void)autoCompleteWithQuery:(NSString*)query withLatitude:(NSString*)latitude andLogitude:(NSString*)longitude
            completionHandler:(void (^)(id JSON))completionHandler
               failureHandler:(void (^)(id error))failureHandler;
{
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@&client_secret=%@&v=%@&ll=%@,%@&query=%@&radius=%@", FOURSQUARE_AUTOCOMPLETE_API, FOURSQUARE_API_KEY, FOURSQUARE_API_SECRET, @"20160820", latitude, longitude, query, @"30000"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];
    
    
}

@end
