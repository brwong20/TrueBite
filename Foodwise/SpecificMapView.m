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

@property (nonatomic, strong) UIButton *navigationButton;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, assign) CGRect originalFrame;

@property (assign, nonatomic) BOOL isExpanded;

@end

@implementation SpecificMapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.isExpanded = NO;
        
        self.originalFrame = frame;
        
        self.navigationButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44.0)];
        self.navigationButton.backgroundColor = APPLICATION_BLUE_COLOR;
        self.navigationButton.titleLabel.font = [UIFont semiboldFontWithSize:16.0];
        [self.navigationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.navigationButton setTitle:@"Take me here" forState:UIControlStateNormal];
        [self.navigationButton addTarget:self action:@selector(promptNavigation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.navigationButton];
        
        self.mapView = [[GMSMapView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationButton.frame), frame.size.width, frame.size.height - 44.0)];
        self.mapView.myLocationEnabled = YES;
        self.mapView.delegate = self;
        [self addSubview:self.mapView];

    }
    
    return self;
}
                        
- (void)animateToLocation:(NSNumber *)latitude longitude:(NSNumber *)longitude
{
    self.locationCoordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
    GMSMarker *locationMarker = [GMSMarker markerWithPosition:self.locationCoordinate];
    
    //Include address as info window
    
    locationMarker.icon = [UIImage imageNamed:@"location_pin"];
    locationMarker.map = self.mapView;
    
    GMSCameraPosition *locationPosition = [GMSCameraPosition cameraWithTarget:self.locationCoordinate zoom:14.0];
    [self.mapView setCamera:locationPosition];
}

#pragma GMSMapViewDelegate methods 

//Acts as a tap gesture for the mapView! Only for expand, make the close it's own button so the user can tap and use the map!
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (!self.isExpanded) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.frame;
            CGRect mapFrame = self.mapView.frame;
            //CGRect navButton = self.navigationButton.frame;
            
#warning 64.0 is status + nav bar height - fix this later for nav bar always on top
            frame = CGRectMake(0, 0, APPLICATION_FRAME.size.width, APPLICATION_FRAME.size.height);
            
            mapFrame.size.height = frame.size.height ;
            
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
        [self.delegate presentNavigationAlertWithCoordinate:self.locationCoordinate];
    }
}


@end
