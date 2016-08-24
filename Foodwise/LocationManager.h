//
//  LocationManager.h
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

- (void)userDidUpdateLocation:(CLLocation*)currentLocation;

@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (assign, nonatomic) id<LocationManagerDelegate>locationDelegate;

+ (LocationManager*) sharedLocationInstance;

- (void)checkLocationAuthorization;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
