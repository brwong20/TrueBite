//
//  SpecificMapView.m
//  Foodwise
//
//  Created by Brian Wong on 8/28/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "SpecificMapView.h"
#import "FoodwiseDefines.h"
#import "UIFont+Extension.h"

@interface SpecificMapView() <GMSMapViewDelegate>

@property (assign, nonatomic) BOOL isExpanded;

@end

@implementation SpecificMapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.isExpanded = NO;
        
        self.navigationButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44.0)];
        self.navigationButton.backgroundColor = APPLICATION_BLUE_COLOR;
        self.navigationButton.titleLabel.font = [UIFont semiboldFontWithSize:16.0];
        [self.navigationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.navigationButton setTitle:@"Take me here" forState:UIControlStateNormal];
        [self.navigationButton addTarget:self action:@selector(promptNavigation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.navigationButton];
        
        self.mapView = [[GMSMapView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationButton.frame), frame.size.width, frame.size.height - self.navigationButton.frame.size.height)];
        self.mapView.myLocationEnabled = YES;
        self.mapView.delegate = self;
        [self addSubview:self.mapView];
    }
    
    return self;
}

- (void)pinLocation:(CLLocationCoordinate2D)locationCoordinate
{
    GMSMarker *locationMarker = [GMSMarker markerWithPosition:locationCoordinate];
    //Include address as info window?
    locationMarker.icon = [UIImage imageNamed:@"location_pin"];
    locationMarker.map = self.mapView;
}

- (void)animateToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [self.mapView animateToZoom:15.0];
    [self.mapView animateToLocation:locationCoordinate];
}

#pragma GMSMapViewDelegate methods 

//Acts as a tap gesture for the mapView! Only for expand, make the close it's own button so the user can tap and use the map!
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (!self.isExpanded) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.frame;
            CGRect mapFrame = self.mapView.frame;

            frame = CGRectMake(0, 0, APPLICATION_FRAME.size.width, APPLICATION_FRAME.size.height);
            mapFrame = CGRectMake(0, CGRectGetMaxY(self.navigationButton.frame), frame.size.width, frame.size.height - (self.navigationButton.frame.size.height + 64.0));//64.0 is the nav + status bar
            
            self.frame = frame;
            self.mapView.frame  = mapFrame;
            
            self.isExpanded = YES;
        }];
    }else{
        
        if ([self.delegate respondsToSelector:@selector(mapViewDidClose)]) {
            [self.delegate mapViewDidClose];
            self.isExpanded = NO;
        }
    }
}

- (void)promptNavigation
{
    if ([self.delegate respondsToSelector:@selector(presentNavigationAlertWithCoordinate:)]) {
        [self.delegate presentNavigationAlertWithCoordinate:self.coordinate];
    }
}


@end
