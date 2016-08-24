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
#import "LocationManager.h"
#import "FoodwiseDefines.h"
#import "RestaurantListViewController.h"
#import "LoginViewController.h"
#import "Restaurant.h"

@interface MapViewController () <LocationManagerDelegate, GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) RestaurantDataSource *foodDataSource;
@property (nonatomic, strong) GMSPlacesClient *placesClient;
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) FIRDatabaseReference *dbRef;

@property (nonatomic, strong) UIButton *mapCenterButton;
@property (nonatomic, strong) NSMutableSet *restaurantSet;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Foodwise";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(logoutCurrentUser)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showListView)];
    
    self.locationManager = [LocationManager sharedLocationInstance];
    self.locationManager.locationDelegate = self;
    
    self.dbRef = [[FIRDatabase database]reference];
    
    self.placesClient = [GMSPlacesClient sharedClient];
    self.foodDataSource = [[RestaurantDataSource alloc]init];
    self.restaurantSet = [[NSMutableSet alloc]init];
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.locationManager.currentLocation.coordinate zoom:15.0];
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:cameraPosition];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.view addSubview:self.mapView];
    
//    self.mapCenterButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - self.view.frame.size.width * 0.15, self.view.frame.size.height - self.view.frame.size.width * 0.15, self.view.frame.size.width * 0.1, self.view.frame.size.width*0.1)];
//    self.mapCenterButton.layer.cornerRadius = self.mapCenterButton.frame.size.height/2;
//    self.mapCenterButton.backgroundColor = [UIColor whiteColor];
//    self.mapCenterButton.titleLabel.text = @"Center";
//    [self.mapCenterButton addTarget:self action:@selector(centerMapAtCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.mapCenterButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //Checks if a user is logged in through Firebase (applies to Google and FB logins)
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                    FIRUser *_Nullable user) {
        if (user != nil) {
            NSLog(@"User is signed in!");
            BOOL anonymous = user.anonymous;
            NSString *userName = user.displayName;
            //            NSString *email = user.email;
            //            NSURL *photoURL = user.photoURL;
            //            NSString *uid = user.uid;
            if (!anonymous) {
                [[[self.dbRef child:@"users"]child:user.uid]
                 setValue:@{@"username":userName, @"email": user.email, @"photoURL": user.photoURL.absoluteString, @"anonymous":@(user.anonymous), @"providerId": user.providerID}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = [NSString stringWithFormat:@"Foodwise - %@", userName];
                });
             }else{
                 [[[self.dbRef child:@"users"]child:user.uid]
                  setValue:@{@"anonymous":@(user.anonymous)}];
             }
            
        } else {
            //No user is signed in.
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginView = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginView"];
                [loginView setModalPresentationStyle:UIModalPresentationFullScreen];
                [self presentViewController:loginView animated:YES completion:nil];
            });
        }
    }];

}

- (void)logoutCurrentUser
{
    NSError *error;
    NSString *providerName;
    
    FIRUser *user = [[FIRAuth auth]currentUser];
    if (!user.anonymous) {
        NSArray *providerData = user.providerData;
        providerName = [[providerData objectAtIndex:0]providerID];
    }
    [[FIRAuth auth]signOut:&error];
    
    if (!error) {
        NSLog(@"Sign out successful");
        //Log user out of our app as well as if they used a provider (FB/Google) to log in
        if ([providerName isEqualToString:@"facebook.com"]) {
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc]init];
            [loginManager logOut];
        }
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginView = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginView"];
        [loginView setModalPresentationStyle:UIModalPresentationCurrentContext];
        UIViewController *top = self.view.window.rootViewController;
        [top presentViewController:loginView animated:YES completion:nil];
    }
}

- (void)userDidUpdateLocation:(CLLocation *)currentLocation
{
    //Since we're always updating the location, run this code to take user to their current location only once (start of the app/if and when they authorize).
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self.mapView animateToLocation:currentLocation.coordinate];
    });
    
    NSString *currentLat = [[NSNumber numberWithDouble:currentLocation.coordinate.latitude] stringValue];
    NSString *currentLon = [[NSNumber numberWithDouble:currentLocation.coordinate.longitude] stringValue];
    
    [self.foodDataSource retrieveNearbyRestaurantsWithLatitude:currentLat longitude:currentLon completionHandler:^(id JSON) {
        //NSLog(@"%@", JSON[@"response"]);
        NSArray *groups = JSON[@"response"][@"groups"];
        NSDictionary *groupsData = [groups objectAtIndex:0];
        NSArray *restArray = [groupsData valueForKey:@"items"];
        
        for (NSDictionary *restInfo in restArray) {
            Restaurant *restaurant = [[Restaurant alloc]initWithDictionary:restInfo];
            [self.restaurantSet addObject:restaurant];
        }
        
        [self performSelectorOnMainThread:@selector(populateNearbyRestaurants:) withObject:self.restaurantSet waitUntilDone:YES];
    } failureHandler:^(id error) {
        NSLog(@"Error retrieving restaurants: %@", error);
    }];
}

#pragma mark GMSMapViewDelegate Methods

- (UIView*)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    return mapView;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    NSString *scrolledLat = [[NSNumber numberWithDouble:position.target.latitude]stringValue];
    NSString *scrolledLon = [[NSNumber numberWithDouble:position.target.longitude]stringValue];
    
    [self.foodDataSource retrieveNearbyRestaurantsWithLatitude:scrolledLat longitude:scrolledLon completionHandler:^(id JSON) {
        NSArray *groups = JSON[@"response"][@"groups"];
        NSDictionary *groupsData = [groups objectAtIndex:0];
        NSArray *restArray = [groupsData valueForKey:@"items"];
        
        NSLog(@"%@", restArray);
        
        for (NSDictionary *restInfo in restArray) {
            Restaurant *restaurant = [[Restaurant alloc]initWithDictionary:restInfo];
            [self.restaurantSet addObject:restaurant];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelectorOnMainThread:@selector(populateNearbyRestaurants:) withObject:self.restaurantSet waitUntilDone:YES];
        });
    } failureHandler:^(id error) {
        //
    }];
}

- (void)populateNearbyRestaurants:(NSMutableSet*)restaurants
{
    for (Restaurant *restaurant in restaurants) {
        
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([restaurant.latitude doubleValue], [restaurant.longitude doubleValue])];
        marker.title = restaurant.name;
        marker.snippet = restaurant.address;
        marker.map = self.mapView;
        
        //Save restaurants to Firebase by id
        [[[self.dbRef child:@"restaurants"]child:restaurant.restaurantId]setValue:@{@"name":restaurant.name, @"address":restaurant.address, @"longitude": restaurant.longitude, @"latitude": restaurant.latitude, @"formattedPhoneNumber":restaurant.formattedPhoneNumber, @"rating":restaurant.rating, @"priceRating":restaurant.priceRating, @"distance":restaurant.distance, @"individualPrices":[restaurant.individualPrices copy], @"individualAvgPrice":restaurant.individualAvgPrice}];
        
    }
}

- (void)showListView
{
    RestaurantListViewController *listView = [[RestaurantListViewController alloc]init];
    listView.restaurantSet = self.restaurantSet;
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
        [self.navigationController pushViewController:listView animated:NO];
    }completion:nil];
    
}

@end
