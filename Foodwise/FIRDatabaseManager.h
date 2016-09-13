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

//Uploads original photo as well as a thumbnail
- (void)uploadPhotoForRestaurant:(FoursquareRestaurant *)restaurant
                 photo:(UIImage *)photo
         completionHandler:(void (^)(id metadata)) completionHandler
            failureHandler:(void (^)(id error))failureHandler;

//Uploads original photo as well as a thumbnail including a price
- (void)uploadPricedPhotoForRestaurant:(FoursquareRestaurant *)restaurant
                       photo:(UIImage *)photo
                        price:(NSNumber *)price
               completionHandler:(void (^)(id metadata)) completionHandler
                  failureHandler:(void (^)(id error))failureHandler;

- (void)retrieveThumbnailsForRestaurant:(FoursquareRestaurant *)restaurant
                      completionHandler:(void (^)(id photos))completionHandler
                         failureHandler:(void (^)(id error))failureHandler;

//Just retrieve all the URLs for a restaurant! - Might even want to create a new dictionary of price photos in a restauraunt object for simple structure
- (void)retrieveUserPhotosForRestaurant:(FoursquareRestaurant *)restaurant
                  completionHandler:(void (^)(id photos)) completionHandler
                     failureHandler:(void (^)(id error))failureHandler;

@end
