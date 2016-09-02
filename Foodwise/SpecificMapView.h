//
//  SpecificMapView.h
//  Foodwise
//
//  Created by Brian Wong on 8/28/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@protocol SpecificMapViewDelegate <NSObject>

- (void)presentNavigationAlertWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)mapViewDidClose;

@end

@interface SpecificMapView : UIView

@property (weak, nonatomic)id<SpecificMapViewDelegate>delegate;

- (void)animateToLocation:(NSNumber*)latitude longitude:(NSNumber*)longitude;

@end
