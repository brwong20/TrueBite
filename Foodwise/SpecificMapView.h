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

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) UIButton *navigationButton;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (weak, nonatomic)id<SpecificMapViewDelegate>delegate;

- (void)pinLocation:(CLLocationCoordinate2D)locationCoordinate;
- (void)animateToLocation:(CLLocationCoordinate2D)locationCoordinate;

@end
