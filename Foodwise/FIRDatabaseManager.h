//
//  FIRDatabaseManager.h
//  TrueBite
//
//  Created by Brian Wong on 9/8/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "FoursquareRestaurant.h"

#import <Foundation/Foundation.h>
#import <Firebase.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseAuth/FirebaseAuth.h>

@interface FIRDatabaseManager : NSObject

+ (FIRDatabaseManager *)sharedManager;

- (void)updateAverageForRestaurant:(FoursquareRestaurant *)restaurant
               withNewPrice:(NSNumber *)newPrice
              completionHandler:(void (^)(id newAverage)) completionHandler
                 failureHandler:(void (^)(id error))failureHandler;

- (void)uploadPhotoForRestaurant:(FoursquareRestaurant *)restaurant
                 photoData:(NSData *)data
         completionHandler:(void (^)(id metadata)) completionHandler
            failureHandler:(void (^)(id error))failureHandler;

- (void)uploadPricedPhotoForRestaurant:(FoursquareRestaurant *)restaurant
                       photoData:(NSData *)data
                        price:(NSNumber *)price
               completionHandler:(void (^)(id metadata)) completionHandler
                  failureHandler:(void (^)(id error))failureHandler;

//Just retrieve all the URLs for a restaurant! - Might even want to create a new dictionary of price photos in a restauraunt object for simple structure
- (void)retrievePhotosForRestaurant:(FoursquareRestaurant *)restaurant
                  completionHandler:(void (^)(id metadata)) completionHandler
                     failureHandler:(void (^)(id error))failureHandler;

@end
