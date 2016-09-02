//
//  LocationManager.m
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()

@property (nonatomic, assign) BOOL locationRetrieved;

@end

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
        self.locationManager.distanceFilter = 500.0;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        self.locationManager.delegate = self;
    }
    
    return self;
}

- (void)requestLocationAuthorization
{
    [self.locationManager requestWhenInUseAuthorization];
}

//Delegate method called when the location manager is initialized AND/OR user authorizes location
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.authorizedStatus = status;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"Please go to settings and authorize location!!!");
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

- (void)startUpdatingLocation
{
    NSLog(@"///Location updates started///");
    self.locationRetrieved = NO;
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

#warning CALL ONLY WHEREVER NEEDED - REFRESH REST, MAP VIEWS, etc...
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //We only want to tell our app to update location once or we'll doing multiple get requests...
    if (!self.locationRetrieved) {
        self.locationRetrieved = YES;
        
        CLLocation *location = [locations lastObject];
        self.currentLocation = location;
        
        //Get location once since restaurant retrieval is dependent upon this method
        if ([self.locationDelegate respondsToSelector:@selector(userDidUpdateLocation:)]) {
            [self.locationDelegate userDidUpdateLocation:self.currentLocation];
        }
        
        [self stopUpdatingLocation];//Always stop after one update
    }
}

@end
