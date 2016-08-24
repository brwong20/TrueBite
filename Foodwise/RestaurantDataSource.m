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

-(void)retrieveNearbyRestaurantsWithLatitude:(NSString *)latitude longitude:(NSString*)longitude
                           completionHandler:(void (^)(id JSON))completionHandler
                              failureHandler:(void (^)(id error))failureHandler;
{
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@&client_secret=%@&v=%@&ll=%@,%@&radius=%@&price=%@&section=%@", FOURSQUARE_EXPLORE_BASE_URL, FOURSQUARE_API_KEY, FOURSQUARE_API_SECRET, @"20160820",latitude, longitude, @"1000", @"1", @"food"];

    //If we can reach a network, try to get cached data first. If not, load from server
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.session.configuration.URLCache = [NSURLCache sharedURLCache];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureHandler(error);
    }];

}

@end
