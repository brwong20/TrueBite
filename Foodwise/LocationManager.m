//
//  LocationManager.m
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

+ (LocationManager *)sharedLocationInstance
{
    
    static LocationManager *locationInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationInstance = [[self alloc]init];
    });
    
    return locationInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1000.0;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        self.locationManager.delegate = self;
        [self checkLocationAuthorization];
    }
    
    return self;
}

- (void)checkLocationAuthorization
{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined: {
            [self.locationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            NSLog(@"Please go to settings and authorize location!!!");
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            [self startUpdatingLocation];
            break;
        }
        
    }

}

//Delegate method called when user authorizes location
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
}

- (void)startUpdatingLocation
{
    NSLog(@"///Location updates started///");
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    NSLog(@"///Location updates stopped///");
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location service failed with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    self.currentLocation = location;
    
    if ([self.locationDelegate respondsToSelector:@selector(userDidUpdateLocation:)]) {
        [self.locationDelegate userDidUpdateLocation:self.currentLocation];
    }
}


-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
}


@end
