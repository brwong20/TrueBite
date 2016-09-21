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
#import "SearchViewController.h"
#import "LayoutBounds.h"
#import "UIFont+Extension.h"
#import "StarRatingView.h"

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
@property (nonatomic, strong) UILabel *cuisineLabel;
@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) StarRatingView *starView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"TrueBite"]];
    UIBarButtonItem *list = [[UIBarButtonItem alloc]initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(showListView)];
    self.navigationItem.leftBarButtonItem = list;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"refresh"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(refreshMap)];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.currentPosition = CLLocationCoordinate2DMake(self.locationManager.currentLocation.coordinate.latitude, self.locationManager.currentLocation.coordinate.longitude);
    
    self.dbRef = [[FIRDatabase database]reference];
    
    self.foodDataSource = [[RestaurantDataSource alloc]init];
    self.restaurantSet = [NSMutableSet set];
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.locationManager.currentLocation.coordinate zoom:15.0];
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- 64.0) camera:cameraPosition];
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
    [self refreshMap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.dbRef removeAllObservers];
}

#pragma mark GMSMapViewDelegate Methods
- (UIView*)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker
{
    self.infoContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.11)];
    self.infoContainerView.backgroundColor = [UIColor clearColor];

    FoursquareRestaurant *restaurantInfo = (FoursquareRestaurant*)marker.userData;
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.infoContainerView.frame.size.width, self.infoContainerView.frame.size.height * 0.3)];
    self.restaurantName.numberOfLines = 0;
    self.restaurantName.text = restaurantInfo.name;
    self.restaurantName.font = [UIFont semiboldFontWithSize:self.infoContainerView.frame.size.height * 0.28];
    self.restaurantName.backgroundColor = [UIColor clearColor];
    self.restaurantName.textColor = APPLICATION_FONT_COLOR;
    [self.infoContainerView addSubview:self.restaurantName];
    
    self.cuisineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.restaurantName.frame) + self.restaurantName.frame.size.height * 0.1, self.infoContainerView.frame.size.width * 0.4, self.infoContainerView.frame.size.height * 0.2)];
    self.cuisineLabel.numberOfLines = 0;
    self.cuisineLabel.text = restaurantInfo.shortCategory;
    self.cuisineLabel.textColor = [UIColor lightGrayColor];
    self.cuisineLabel.font = [UIFont fontWithSize:15.0];
    self.cuisineLabel.backgroundColor = [UIColor clearColor];
    [self.infoContainerView addSubview:self.cuisineLabel];
    
    self.starView = [[StarRatingView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cuisineLabel.frame) + self.infoContainerView.frame.size.height * 0.1, self.infoContainerView.frame.size.width * 0.6, self.infoContainerView.frame.size.height * 0.3)];
    [self.starView convertNumberToStars:restaurantInfo.rating];
    [self.infoContainerView addSubview:self.starView];
    
    self.arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.infoContainerView.frame.size.width - self.infoContainerView.frame.size.width * 0.1, self.infoContainerView.frame.size.height/2 - self.infoContainerView.frame.size.width * 0.05, self.infoContainerView.frame.size.width * 0.1, self.infoContainerView.frame.size.width * 0.1)];
    self.arrowImage.backgroundColor = [UIColor clearColor];
    self.arrowImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.arrowImage setImage:[UIImage imageNamed:@"back_info.png"]];
    [self.infoContainerView addSubview:self.arrowImage];
    
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
    RestaurantDetailViewController *detailView = [[RestaurantDetailViewController alloc]init];
    detailView.selectedRestaurant = (FoursquareRestaurant*)marker.userData;
    [self.navigationController pushViewController:detailView animated:YES];
}

//Every time a user shifts the map, update their current location to retrieve nearby restaurants based on the map
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    self.currentPosition = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude);
}

- (void)refreshMap
{
    NSString *scrolledLat = [[NSNumber numberWithDouble:self.currentPosition.latitude]stringValue];
    NSString *scrolledLon = [[NSNumber numberWithDouble:self.currentPosition.longitude]stringValue];
    
    [self.foodDataSource retrieveNearbyRestaurantsWithLatitude:scrolledLat
                                                     longitude:scrolledLon
                                                    withRadius:[@(MILE_RADIUS) stringValue]
                                             completionHandler:^(id JSON) {
        NSArray *groups = JSON[@"response"][@"groups"];
        NSDictionary *groupsData = [groups objectAtIndex:0];
        NSArray *restArray = [groupsData valueForKey:@"items"];

        [self.mapView clear];
        [self.restaurantSet removeAllObjects];
        
         for (NSDictionary *restInfo in restArray) {
             FoursquareRestaurant *restaurant = [[FoursquareRestaurant alloc]initWithDictionary:restInfo];
             [self.restaurantSet addObject:restaurant];
         }
                                                 
         [[self.dbRef child:@"restaurants"]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
             NSDictionary *allRestaurants = snapshot.value;
             
             if (allRestaurants.count > 0) {
                 for (FoursquareRestaurant *restaurant in self.restaurantSet) {
                     NSDictionary *foundRestaurant = [allRestaurants objectForKey:restaurant.restaurantId];
                     //If the restaurant isn't in our database, add it as a new node. otherwise it's a restaurant we already have saved so retrieve the relevant price data on it!
                     if (foundRestaurant) {
                         [restaurant retrievePriceDataFrom:foundRestaurant];
                     }else{
                         [[[self.dbRef child:@"restaurants"]child:restaurant.restaurantId]updateChildValues:[restaurant fireBaseDictionary]];
                     }
                 }
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self populateNearbyRestaurants:self.restaurantSet];
             });
         }];

    } failureHandler:^(id error) {
        //
    }];
}

- (void)populateNearbyRestaurants:(NSMutableSet *)restaurants
{
    for (FoursquareRestaurant *restaurant in restaurants) {
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([restaurant.latitude doubleValue], [restaurant.longitude doubleValue])];
        marker.icon = [self priceMarkerForRestaurant:restaurant];
        //marker.title = restaurant.name;
        //marker.snippet = restaurant.shortAddress;
        marker.userData = restaurant;
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
    NSMutableArray *nearby = [NSMutableArray array];
    NSArray *restaurants = self.restaurantSet.allObjects;
    if (self.restaurantSet.count > 0) {
        for (int i = 0; i < 5; ++i) {
            [nearby addObject:restaurants[i]];
            
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
