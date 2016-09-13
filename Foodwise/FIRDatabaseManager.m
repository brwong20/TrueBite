//
//  FIRDatabaseManager.m
//  TrueBite
//
//  Created by Brian Wong on 9/8/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "FIRDatabaseManager.h"

#import "UIImage+ResizeHelper.h"

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
                 photo:(UIImage *)photo
         completionHandler:(void (^)(id metadata))completionHandler
            failureHandler:(void (^)(id error))failureHandler
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [formatter stringFromDate:today];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateKey = [formatter stringFromDate:today];
    
    NSUUID *uuid = [[NSUUID alloc]init];
    NSString *folderID = uuid.UUIDString;
    NSString *thumbId = [NSString stringWithFormat:@"%@-thumb", uuid.UUIDString];
    NSString *originalId = [NSString stringWithFormat:@"%@-original", uuid.UUIDString];
    
    FIRStorageMetadata *metaData = [[FIRStorageMetadata alloc]init];

    metaData.customMetadata = @{@"userId":self.currentUser.uid, @"restaurantName":restaurant.name, @"restaurantId":restaurant.restaurantId, @"priceTier":restaurant.priceTier, @"date":dateString};
    
    UIImage *thumbImage = [UIImage imageWithImage:photo scaledToFillSize:CGSizeMake(150, 150)];
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.7);
    
    [[[[self.storageRef child:restaurant.restaurantId]child:folderID]child:thumbId]putData:thumbData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        
        [[[self.restaurantsRef child:restaurant.restaurantId]child:@"thumbnails"]updateChildValues:@{dateKey:metadata.downloadURL.absoluteString}];
        
    }];
    
    NSData *imgData = UIImageJPEGRepresentation(photo, 1.0);
    
    [[[[self.storageRef child:restaurant.restaurantId]child:folderID]child:originalId ] putData:imgData metadata:metaData completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error) {
            failureHandler(error);
            return;
        }
        
        //Since we store all these files in folders, store their urls into our restaurant objects for easy retrieval.
        //ALSO, we HAVE to store these two key pieces of info in order to retrieve the photo and its metadata (metadata needs full path, but it's just restaurantId/fileDateStr, but we omit restaurantId since it's redundant.
        [[[self.restaurantsRef child:restaurant.restaurantId]child:@"userPhotos"]updateChildValues:@{dateKey:metadata.downloadURL.absoluteString}];
        completionHandler(metaData);
    }];
}

- (void)uploadPricedPhotoForRestaurant:(FoursquareRestaurant *)restaurant
                             photo:(UIImage *)photo
                                 price:(NSNumber *)price
                     completionHandler:(void (^)(id))completionHandler
                        failureHandler:(void (^)(id))failureHandler
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [formatter stringFromDate:today];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateKey = [formatter stringFromDate:today];
    
    NSUUID *uuid = [[NSUUID alloc]init];
    NSString *folderID = uuid.UUIDString;
    NSString *thumbId = [NSString stringWithFormat:@"%@-thumb", uuid.UUIDString];
    NSString *originalId = [NSString stringWithFormat:@"%@-original", uuid.UUIDString];
    
    FIRStorageMetadata *metaData = [[FIRStorageMetadata alloc]init];
    FIRStorageMetadata *thumbnailMetadata = [[FIRStorageMetadata alloc]init];
    thumbnailMetadata.customMetadata = @{@"price":price};
    metaData.customMetadata = @{@"userId":self.currentUser.uid, @"restaurantName":restaurant.name, @"restaurantId":restaurant.restaurantId, @"priceTier":restaurant.priceTier, @"date":dateString, @"price":price};

    UIImage *thumbImage = [UIImage imageWithImage:photo scaledToFillSize:CGSizeMake(150, 150)];
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.7);
    
    [[[[self.storageRef child:restaurant.restaurantId]child:folderID]child:thumbId]putData:thumbData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        
         [[[self.restaurantsRef child:restaurant.restaurantId]child:@"thumbnails"]updateChildValues:@{dateKey:metadata.downloadURL.absoluteString}];
        
    }];
    
    NSData *imgData = UIImageJPEGRepresentation(photo, 1.0);
    
    [[[[self.storageRef child:restaurant.restaurantId]child:folderID]child:originalId ] putData:imgData metadata:metaData completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error) {
            failureHandler(error);
            return;
        }
        
        //Since we store all these files in folders, store their urls into our restaurant objects for easy retrieval.
        //ALSO, we HAVE to store these two key pieces of info in order to retrieve the photo and its metadata (metadata needs full path, but it's just restaurantId/fileDateStr, but we omit restaurantId since it's redundant.
        [[[self.restaurantsRef child:restaurant.restaurantId]child:@"userPhotos"]updateChildValues:@{dateKey:metadata.downloadURL.absoluteString}];
        
        [self updateAverageForRestaurant:restaurant withNewPrice:price completionHandler:^(id newAverage) {
            NSLog(@"UPDATED");
            completionHandler(metadata);
        } failureHandler:^(id error) {
            
        }];
    }];
}

- (void)retrieveThumbnailsForRestaurant:(FoursquareRestaurant *)restaurant
                      completionHandler:(void (^)(id photos))completionHandler
                         failureHandler:(void (^)(id error))failureHandler
{
    [[[[self.restaurantsRef child:restaurant.restaurantId]child:@"thumbnails"]queryOrderedByKey]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        completionHandler(snapshot.value);
        
        //        NSDictionary *allPhotos = snapshot.value;
        //
        //        NSLog(@"%@", allPhotos);
        //
        //        //This is how we get the metadata for all photos
        //        if ([allPhotos isKindOfClass:[NSDictionary class]]) {
        //            NSArray *fileExtensions = [allPhotos allKeys];
        //            NSMutableArray *photoInfo = [NSMutableArray array];
        //            for (NSString *extension in fileExtensions) {
        //                NSString *filePath = [NSString stringWithFormat:@"%@/%@", restaurant.restaurantId, extension];
        //                [[self.storageRef child:filePath]metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        //                    if (metadata) {
        //                        [photoInfo addObject:metadata];
        //                    }
        //                }];
        //            }
        //            completionHandler(photoInfo);
        //        }
    }];
 
}


- (void)retrieveUserPhotosForRestaurant:(FoursquareRestaurant *)restaurant
                  completionHandler:(void (^)(id photos))completionHandler
                     failureHandler:(void (^)(id error))failureHandler
{
    [[[self.restaurantsRef child:restaurant.restaurantId]child:@"userPhotos"]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        completionHandler(snapshot.value);
        
//        NSDictionary *allPhotos = snapshot.value;
//        
//        NSLog(@"%@", allPhotos);
//        
//        //This is how we get the metadata for all photos
//        if ([allPhotos isKindOfClass:[NSDictionary class]]) {
//            NSArray *fileExtensions = [allPhotos allKeys];
//            NSMutableArray *photoInfo = [NSMutableArray array];
//            for (NSString *extension in fileExtensions) {
//                NSString *filePath = [NSString stringWithFormat:@"%@/%@", restaurant.restaurantId, extension];
//                [[self.storageRef child:filePath]metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
//                    if (metadata) {
//                        [photoInfo addObject:metadata];
//                    }
//                }];
//            }
//            completionHandler(photoInfo);
//        }
    }];
}

@end
