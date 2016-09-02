//
//  ViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "MapViewController.h"
#import "RestaurantDataSource.h"
#import "RestaurantDetailViewController.h"
#import "LocationManager.h"
#import "FoodwiseDefines.h"
#import "RestaurantListViewController.h"
#import "LoginViewController.h"
#import "FoursquareRestaurant.h"
#import "PriceRestaurant.h"
#import "SearchViewController.h"
#import "LayoutBounds.h"
#import "UIFont+Extension.h"

@interface MapViewController () <LocationManagerDelegate, GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) RestaurantDataSource *foodDataSource;
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) FIRDatabaseReference *dbRef;

//Wherever GMSMapView is scrolled to/centered on
@property (nonatomic, assign) CLLocationCoordinate2D currentPosition;

@property (nonatomic, strong) UIImageView *updateButton;
@property (nonatomic, strong) UITapGestureRecognizer *updateGesture;
@property (nonatomic, strong) NSMutableSet *restaurantSet;

//Custom GMSMarker properties
@property (nonatomic, strong) UIView *infoContainerView;
@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"TrueBite"]];
    UIBarButtonItem *list = [[UIBarButtonItem alloc]initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(showListView)];
    self.navigationItem.leftBarButtonItem = list;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"refresh"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(refreshMap)];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    
    self.dbRef = [[FIRDatabase database]reference];
    
    self.foodDataSource = [[RestaurantDataSource alloc]init];
    self.restaurantSet = [[NSMutableSet alloc]initWithArray:self.restaurantLocations];
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.locationManager.currentLocation.coordinate zoom:14.0];
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) camera:cameraPosition];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    //self.mapView.settings.myLocationButton = YES;
    [self.view addSubview:self.mapView];
    
    self.updateButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_button"]];
    self.updateButton.center = CGPointMake(self.view.frame.size.width - self.view.frame.size.width * 0.15, self.view.frame.size.height - self.view.frame.size.width * 0.35);
    self.updateButton.backgroundColor = [UIColor clearColor];
    self.updateButton.userInteractionEnabled = YES;
    [self.view addSubview:self.updateButton];
    
    self.updateGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseRestaurant)];
    self.updateGesture.numberOfTapsRequired = 1;
    [self.updateButton addGestureRecognizer:self.updateGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateNearbyRestaurants:self.restaurantLocations];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.dbRef removeAllObservers];
}

#pragma mark GMSMapViewDelegate Methods
- (UIView*)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker
{
    
    self.infoContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.12)];
    self.infoContainerView.backgroundColor = [UIColor clearColor];

    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.infoContainerView.frame.size.width, self.infoContainerView.frame.size.height * 0.28)];
    self.restaurantName.numberOfLines = 0;
    self.restaurantName.text = marker.title;
    self.restaurantName.font = [UIFont semiboldFontWithSize:18.0];
    self.restaurantName.backgroundColor = [UIColor clearColor];
    self.restaurantName.textColor = APPLICATION_FONT_COLOR;

    [self.infoContainerView addSubview:self.restaurantName];
    
    self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.restaurantName.frame), self.infoContainerView.frame.size.width, self.infoContainerView.frame.size.height * 0.68)];
    self.addressLabel.numberOfLines = 0;
    self.addressLabel.text = marker.snippet;
    self.addressLabel.textColor = [UIColor lightGrayColor];
    self.addressLabel.font = [UIFont fontWithSize:18.0];
    self.addressLabel.backgroundColor = [UIColor clearColor];
    [self.infoContainerView addSubview:self.addressLabel];
    
    //[LayoutBounds drawBoundsForAllLayers:self.infoContainerView];
    
    return self.infoContainerView;
}


//- (UIView*)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
//{
//    UIView *priceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.1, self.view.frame.size.width * 0.2)];
//    //priceView.layer.cornerRadius = priceView.frame.size.height/2;
//    priceView.backgroundColor = [UIColor whiteColor];
//    priceView.layer.borderWidth = 1.5;
//    priceView.layer.borderColor = [UIColor blackColor].CGColor;
//    
//    return priceView;
//}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    //Find marker's restaurant
    NSString *restaurantTitle = marker.title;
    
    int i = 0;
    for (FoursquareRestaurant *restaurant in self.restaurantLocations) {
        if (restaurant.name == restaurantTitle) {
            break;
        }else{
            i++;
        }
    }
    
    RestaurantDetailViewController *detailView = [[RestaurantDetailViewController alloc]init];
    detailView.selectedRestaurant = self.restaurantLocations[i];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    self.currentPosition = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude);
}

- (void)refreshMap
{
    NSString *scrolledLat = [[NSNumber numberWithDouble:self.currentPosition.latitude]stringValue];
    NSString *scrolledLon = [[NSNumber numberWithDouble:self.currentPosition.longitude]stringValue];
    
    [self.foodDataSource retrieveNearbyRestaurantsWithLatitude:scrolledLat longitude:scrolledLon completionHandler:^(id JSON) {
        NSArray *groups = JSON[@"response"][@"groups"];
        NSDictionary *groupsData = [groups objectAtIndex:0];
        NSArray *restArray = [groupsData valueForKey:@"items"];

        [self.mapView clear];
        [self.restaurantSet removeAllObjects];
        
        for (NSDictionary *restInfo in restArray) {
            FoursquareRestaurant *restaurant = [[FoursquareRestaurant alloc]initWithDictionary:restInfo];
            [self.restaurantSet addObject:restaurant];
        }
        
        [self.restaurantLocations removeAllObjects];
        [self.restaurantLocations addObjectsFromArray:[self.restaurantSet allObjects]];
        
        [self performSelectorOnMainThread:@selector(populateNearbyRestaurants:) withObject:self.restaurantLocations waitUntilDone:YES];
    } failureHandler:^(id error) {
        //
    }];
}

- (void)populateNearbyRestaurants:(NSMutableArray *)restaurants
{
    for (FoursquareRestaurant *restaurant in restaurants) {
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([restaurant.latitude doubleValue], [restaurant.longitude doubleValue])];
        marker.icon = [self priceMarkerForRestaurant:restaurant];
        marker.title = restaurant.name;
        marker.snippet = restaurant.shortAddress;
        //marker.userData = restaurant;
        marker.map = self.mapView;
    }
}

//Because the Google API for iOS doesn't let us show all our info windows at the same time, we will render every pin with an info window on it
- (UIImage *)priceMarkerForRestaurant:(FoursquareRestaurant *)restaurant
{
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.22, 52.0)];
    containerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *pinView = [[UIImageView alloc]initWithFrame:CGRectMake(0, containerView.frame.size.height/2 - 20.0, containerView.frame.size.width * 0.3, containerView.frame.size.height)];
    pinView.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    pinView.layer.shouldRasterize = YES;
    pinView.contentMode = UIViewContentModeScaleAspectFit;
    pinView.backgroundColor = [UIColor clearColor];
    [pinView setImage:[UIImage imageNamed:@"location_pin"]];
    [containerView addSubview:pinView];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(containerView.frame.size.width/3.2, CGRectGetMinY(pinView.frame) + containerView.frame.size.height * 0.15, containerView.frame.size.width * 0.67, containerView.frame.size.height * 0.45)];
    priceLabel.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    priceLabel.layer.shouldRasterize = YES;
    priceLabel.layer.cornerRadius = 9.0;
    priceLabel.layer.borderWidth = 1.5;
    priceLabel.clipsToBounds = YES;
    priceLabel.font = [UIFont systemFontOfSize:15.0];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.backgroundColor = [UIColor whiteColor];
    priceLabel.layer.borderColor = [UIColor blackColor].CGColor;
    priceLabel.text = [NSString stringWithFormat:@"$%.2f", restaurant.individualAvgPrice.doubleValue];
    [containerView addSubview:priceLabel];

    //Convert the view into an image
    UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, NO, 0.0);
    [containerView.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *customPin = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return customPin;
}

#pragma Navigation

- (void)chooseRestaurant
{
    SearchViewController *searchView = [[SearchViewController alloc]init];
    searchView.currentLocation = self.locationManager.currentLocation.coordinate;//Stores a copy of the value at that location in time instead of pointing this value which might change!

    //Get 5 restaurants nearby to prepopulate for user
    NSMutableArray *nearby = [[NSMutableArray alloc]init];
    if (self.restaurantLocations.count >= 1) {
        for (int i = 0; i < 5; ++i) {
            [nearby addObject:[self.restaurantLocations objectAtIndex:i]];
            
        }
    }
    searchView.nearbyRestaurants = nearby;
    [self.navigationController pushViewController:searchView animated:YES];
}

- (void)showListView
{
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }completion:nil];
}

@end
