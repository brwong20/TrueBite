//
//  FIRDatabaseManager.m
//  TrueBite
//
//  Created by Brian Wong on 9/8/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "FIRDatabaseManager.h"

@interface FIRDatabaseManager()

@property (nonatomic, strong) FIRDatabaseReference *restaurantsRef;
@property (nonatomic, strong) FIRStorageReference *storageRef;
@property (nonatomic, strong) FIRUser *currentUser;

@end

@implementation FIRDatabaseManager

+ (FIRDatabaseManager *)sharedManager
{
    
    static FIRDatabaseManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager= [[self alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.restaurantsRef = [[[FIRDatabase database]reference]child:@"restaurants"];
        self.storageRef = [[FIRStorage storage]reference];
        self.currentUser = [[FIRAuth auth]currentUser];
    }
    
    return self;
}

- (void)updateAverageForRestaurant:(FoursquareRestaurant *)restaurant
                      withNewPrice:(NSNumber *)newPrice
                 completionHandler:(void (^)(id newAverage))completionHandler
                    failureHandler:(void (^)(id))failureHandler
{
    //With this, only ONE price can be submitted/updated by a user
    NSDictionary *priceToSubmit = @{self.currentUser.uid:newPrice};
    [[[self.restaurantsRef child:restaurant.restaurantId]child:@"individualPrices"]updateChildValues:priceToSubmit];
    
    //Get new prices/update average locally and remotely.
    [[[self.restaurantsRef child:restaurant.restaurantId]child:@"individualPrices"]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *newPrices = snapshot.value;
        //Refresh prices and recalculate average to keep data as realtime as possible!
        [restaurant.individualPrices removeAllObjects];
        [restaurant.individualPrices addObjectsFromArray:[newPrices allValues]];
        [restaurant calculateAveragePrice];
        
        NSDictionary *newAvgPrice = @{@"individualAvgPrice":restaurant.individualAvgPrice};
        [[self.restaurantsRef child:restaurant.restaurantId]updateChildValues:newAvgPrice];
        
        completionHandler(newAvgPrice);
        return;
    }];

    //failureHandler(newPrice);
}
                       

- (void)uploadPhotoForRestaurant:(FoursquareRestaurant *)restaurant
                 photoData:(NSData *)data
         completionHandler:(void (^)(id metadata))completionHandler
            failureHandler:(void (^)(id error))failureHandler
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [formatter stringFromDate:today];
    
    //Unique file identifier for now...
    [formatter setDateFormat:@"mmddyyyyHHmmss"];
    NSString *fileDateStr = [formatter stringFromDate:today];
    
    FIRStorageMetadata *metaData = [[FIRStorageMetadata alloc]init];
    metaData.customMetadata = @{@"userId":self.currentUser.uid, @"restaurantName":restaurant.name, @"restaurantId":restaurant.restaurantId, @"priceTier":restaurant.priceTier, @"date":dateString};
    
    [[[self.storageRef child:restaurant.restaurantId]child:fileDateStr] putData:data metadata:metaData completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error) {
            failureHandler(error);
            return;
        }
        [[self.restaurantsRef child:restaurant.restaurantId]updateChildValues:@{@"photos":metadata.downloadURL.absoluteString, @"pricePhoto":@0}];
        completionHandler(metadata);
    }];
}

- (void)uploadPricedPhotoForRestaurant:(FoursquareRestaurant *)restaurant
                             photoData:(NSData *)data
                                 price:(NSNumber *)price
                     completionHandler:(void (^)(id))completionHandler
                        failureHandler:(void (^)(id))failureHandler
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [formatter stringFromDate:today];
    
    //Unique file identifier for now...
    [formatter setDateFormat:@"mmddyyyyHHmmss"];
    NSString *fileDateStr = [formatter stringFromDate:today];
    
    FIRStorageMetadata *metaData = [[FIRStorageMetadata alloc]init];
    
    //Remember to check for photo filter!!!
    metaData.customMetadata = @{@"userId":self.currentUser.uid, @"restaurantName":restaurant.name, @"restaurantId":restaurant.restaurantId, @"priceTier":restaurant.priceTier, @"date":dateString, @"price":price};

    [[[self.storageRef child:restaurant.restaurantId]child:fileDateStr]putData:data metadata:metaData completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error) {
            failureHandler(error);
            return;
        }
        
        //Since we store all these files in folders, store their urls into our restaurant objects for easy retrieval.
        //ALSO, we HAVE to store these two key pieces of info in order to retrieve the photo and its metadata (metadata needs full path, but it's just restaurantId/fileDateStr, but we omit restaurantId since it's redundant.
        [[[self.restaurantsRef child:restaurant.restaurantId]child:@"photos"]updateChildValues:@{fileDateStr:metadata.downloadURL.absoluteString}];
        
        [self updateAverageForRestaurant:restaurant withNewPrice:price completionHandler:^(id newAverage) {
            NSLog(@"UPDATED");
             completionHandler(metadata);
        } failureHandler:^(id error) {
            
        }];
    }];
}

- (void)retrievePhotosForRestaurant:(FoursquareRestaurant *)restaurant
                  completionHandler:(void (^)(id))completionHandler
                     failureHandler:(void (^)(id))failureHandler
{
    [[[self.restaurantsRef child:restaurant.restaurantId]child:@"photos"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //completionHandler(snapshot.value);
        
        NSDictionary *allPhotos = snapshot.value;

        //This is how we get the metadata for all photos
        NSArray *fileExtensions = [allPhotos allKeys];
        for (NSString *extension in fileExtensions) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", restaurant.restaurantId, extension];
            [[self.storageRef child:filePath]metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                NSLog(@"%@", metadata);
            }];
        }
        
    }];
}

@end
