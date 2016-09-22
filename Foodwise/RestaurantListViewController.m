//
//  RestaurantListViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/20/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "RestaurantListViewController.h"
#import "FoursquareRestaurant.h"
#import "RestaurantTableViewCell.h"
#import "RestaurantDetailViewController.h"
#import "LocationManager.h"
#import "RestaurantDataSource.h"
#import "LoginViewController.h"
#import "MapViewController.h"
#import "LocationPromptView.h"
#import "FoodwiseDefines.h"
#import "LoadingView.h"
#import "TitlePageView.h"
#import "AppDescriptionView.h"
#import "StarRatingView.h"
#import "LayoutBounds.h"
#import "SearchViewController.h"
#import "UIFont+Extension.h"

#import <UIImageView+AFNetworking.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface RestaurantListViewController()<LocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RestaurantDataSource *foodDataSource;
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) FIRDatabaseReference *dbRef;
@property (nonatomic, strong) FIRDatabaseReference *avgPriceRef;
@property (nonatomic, assign) FIRDatabaseHandle restaurantHandle;
@property (nonatomic, strong) LoadingView *loadingView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImageView *searchButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *visibleRestaurants;
@property (nonatomic, strong) NSString *averagePrice;
@property (nonatomic, assign) NSInteger restaurantRadius;

@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UIButton *loadMoreButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;


@end

@implementation RestaurantListViewController

int i = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"TrueBite"]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMapView)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(selectFilter)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = APPLICATION_BLUE_COLOR;
    [self.refreshControl addTarget:self action:@selector(refreshRestaurants) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView registerClass:[RestaurantTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.searchButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_button"]];
    self.searchButton.center = CGPointMake(self.view.frame.size.width - self.view.frame.size.width * 0.15, self.view.frame.size.height - self.view.frame.size.width * 0.35);
    self.searchButton.backgroundColor = [UIColor clearColor];
    self.searchButton.userInteractionEnabled = YES;
    [self.view addSubview:self.searchButton];
    
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchForRestaurant)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self.searchButton addGestureRecognizer:self.tapGesture];
    
    self.loadMoreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80.0)];
    self.loadMoreView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.loadMoreButton = [[UIButton alloc]initWithFrame:CGRectMake(self.loadMoreView.frame.size.width/2 - self.loadMoreView.frame.size.width * 0.25, self.loadMoreView.frame.size.height/2 - self.loadMoreView.frame.size.height * 0.25, self.loadMoreView.frame.size.width * 0.5, self.loadMoreView.frame.size.height * 0.5)];
    self.loadMoreButton.titleLabel.font = [UIFont semiboldFontWithSize:16.0];
    [self.loadMoreButton setTitleColor:APPLICATION_FONT_COLOR forState:UIControlStateNormal];
    [self.loadMoreButton setTitle:@"Load more restaurants" forState:UIControlStateNormal];
    self.loadMoreButton.backgroundColor = [UIColor whiteColor];
    self.loadMoreButton.layer.borderColor = APPLICATION_FONT_COLOR.CGColor;
    self.loadMoreButton.layer.borderWidth = 1.5;
    self.loadMoreButton.layer.cornerRadius = self.loadMoreButton.frame.size.height * 0.08;
    [self.loadMoreButton addTarget:self action:@selector(loadMoreRestaurants) forControlEvents:UIControlEventTouchUpInside];
    [self.loadMoreView addSubview:self.loadMoreButton];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.color = [UIColor whiteColor];
    self.indicator.center = self.loadMoreButton.center;
    [self.loadMoreView addSubview:self.indicator];
    
    //Check if user is logged into Firebase, if not, show login scren
    FIRUser *currentUser = [[FIRAuth auth]currentUser];
    if (currentUser)
    {
        NSLog(@"User is signed in!");
    }
    else
    {
        //Sign them in if somehow they're not
        [[FIRAuth auth]signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"Anon sign in successful!");
                
                //Add user into db
                [[[[[FIRDatabase database]reference] child:@"users"]child:user.uid]
                 setValue:@{@"anonymous":@(user.anonymous)}];
            }
        }];
    }
    
    self.locationManager = [LocationManager sharedLocationInstance];
#warning Be careful with this delegate since this instance is a SINGELTON - we can only delegate this to one class at a time!
    self.locationManager.locationDelegate = self;
    
    self.dbRef = [[FIRDatabase database]reference];
    
    self.foodDataSource = [[RestaurantDataSource alloc]init];

    self.restaurantSet = [[NSMutableSet alloc]init];
    self.visibleRestaurants = [[NSMutableArray alloc]init];
    
    //self.loadingView = [[LoadingView alloc]initWithFrame:APPLICATION_FRAME];
    
    //Quick onboarding
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"com.truebite.onboarding.location"]) {
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        LocationPromptView *promptView = [[LocationPromptView alloc]initWithFrame:APPLICATION_FRAME];
        [currentWindow addSubview:promptView];
        
        AppDescriptionView *appDescripView = [[AppDescriptionView alloc]initWithFrame:APPLICATION_FRAME];
        [currentWindow addSubview:appDescripView];
        
        TitlePageView *title = [[TitlePageView alloc]initWithFrame:APPLICATION_FRAME];
        [currentWindow addSubview:title];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Reload here so a price changed by the user is reflected. (i.e. selectedRestaurant)
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.dbRef removeObserverWithHandle:self.restaurantHandle];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark Restaurant Data Methods

- (void)refreshRestaurants
{
    //Simply update the location using the manager since the delegate method below will get called when a location is retrieved!
    if (self.locationManager.authorizedStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        
        //Need to disable because we can't pull more restaurants WHILE we're updating the location/refreshing or else we'll have duplicate entries as of now. This is because we remove everything in our restaurant set on every refresh, but not when we load more!
        self.loadMoreButton.enabled = NO;
        self.loadMoreButton.alpha = 0.4;
    }else{
        UIAlertController *locationAlert = [UIAlertController alertControllerWithTitle:@"Oops..." message:@"Looks like you haven't enabled location services yet. Please go to Settings to do so!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.refreshControl endRefreshing];
            [self dismissViewControllerAnimated:locationAlert completion:nil];
        }];
        [locationAlert addAction:ok];
        [self presentViewController:locationAlert animated:YES completion:nil];
    }

}

- (void)userDidUpdateLocation:(CLLocation *)currentLocation
{
    self.restaurantRadius = THREE_QUARTER_MILE_RADIUS;
    
    //Don't need loading page with refresh control
    if (!self.refreshControl.refreshing) {
        [self.view addSubview:self.loadingView];
    }

    NSString *currentLat = [[NSNumber numberWithDouble:currentLocation.coordinate.latitude]stringValue];
    NSString *currentLon = [[NSNumber numberWithDouble:currentLocation.coordinate.longitude]stringValue];
    
    [self.foodDataSource retrieveNearbyRestaurantsWithLatitude:currentLat
                                                     longitude:currentLon
                                                    withRadius:[@(self.restaurantRadius) stringValue]
                                             completionHandler:^(id JSON) {
        NSArray *groups = JSON[@"response"][@"groups"];
        
        //NSLog(@"%@", JSON[@"response"]);
        
        NSDictionary *groupsData = [groups objectAtIndex:0];
        NSArray *restaurantArray = [groupsData valueForKey:@"items"];
        
        //Remove and refresh all restuarants every time user pulls to refresh.
        [self.restaurantSet removeAllObjects];
        
        for (NSDictionary *restaurantInfo in restaurantArray) {
            FoursquareRestaurant *restaurant = [[FoursquareRestaurant alloc]initWithDictionary:restaurantInfo];
            [self.restaurantSet addObject:restaurant];
        }
        
#pragma Need at least one restaurant in db... Find a fix for this. Also what if we want to add a new key to our db? Have to do something like this as well
        for (FoursquareRestaurant *restaurant in self.restaurantSet) {
            //Update/Save restaurants by their id into db.
            [[[self.dbRef child:@"restaurants"]child:restaurant.restaurantId]updateChildValues:[restaurant fireBaseDictionary]];
        }
        
        //Retrieve all restaurants stored in our db so we can get our price data if we have any.
        [[self.dbRef child:@"restaurants"]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *allRestaurants = snapshot.value;

            //NSLog(@"%@", snapshot.value);
            
            if (allRestaurants.count > 0) {
                for (FoursquareRestaurant *restaurant in self.restaurantSet) {
                    NSDictionary *foundRestaurant = [allRestaurants objectForKey:restaurant.restaurantId];
                    //If the restaurant isn't in our database, add it as a new node. otherwise it's a restaurant we already have saved so retrieve the relevant price data on it!
                    if (foundRestaurant) {
                        [restaurant retrievePriceDataFrom:foundRestaurant];
                    }
                }
                
                /*
                After filtering and gathering price data on all restaurants, convert our set to an array to be used with our tableview!
                Also, for some reason, this block gets called multiple times if user reloads/refreshes data multiple times so always make sure to flush and refresh table view dataset RIGHT BEFORE we populate and/or update it
                */
                
                [self.visibleRestaurants removeAllObjects];
                [self.visibleRestaurants addObjectsFromArray:[self.restaurantSet allObjects]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tableView.tableFooterView = self.loadMoreView;
                    [self sortWithFilter:@"distance"];
                    [self.tableView reloadData];
                
                    self.loadMoreButton.enabled = YES;
                    self.loadMoreButton.alpha = 1.0;
                    
                    //Only when user pulls to refresh
                    if (self.refreshControl.refreshing) {
                        [self.refreshControl endRefreshing];
                    }
                });
            }
        }];
    } failureHandler:^(id error) {
        NSLog(@"Error retrieving restaurants: %@", error);
        
        self.loadMoreButton.enabled = YES;
        self.loadMoreButton.alpha = 1.0;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops..." message:@"There was a problem trying to retrieve nearby restaurants. Please check your connection and try again!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
               
//        if (self.loadingView.superview) {
//            [self.loadingView removeFromSuperview];
//        }
    }];
}

- (void)loadMoreRestaurants
{
    self.loadMoreButton.hidden = YES;
    [self.indicator startAnimating];
    
    self.restaurantRadius += MILE_RADIUS;
    
    NSString *currentLat = [[NSNumber numberWithDouble:self.locationManager.currentLocation.coordinate.latitude]stringValue];
    NSString *currentLon = [[NSNumber numberWithDouble:self.locationManager.currentLocation.coordinate.longitude]stringValue];
    
    [self.foodDataSource retrieveNearbyRestaurantsWithLatitude:currentLat longitude:currentLon withRadius:[@(self.restaurantRadius) stringValue]completionHandler:^(id JSON) {
        NSArray *groups = JSON[@"response"][@"groups"];
        
        NSDictionary *groupsData = [groups objectAtIndex:0];
        NSArray *restaurantArray = [groupsData valueForKey:@"items"];
        
        //Let our set retrieve all unique restaurants
        [self.visibleRestaurants removeAllObjects];
        
        for (NSDictionary *restaurantInfo in restaurantArray) {
            FoursquareRestaurant *restaurant = [[FoursquareRestaurant alloc]initWithDictionary:restaurantInfo];
            [self.restaurantSet addObject:restaurant];
        }
        
        //Retrieve all restaurants stored in our db so we can get our price data if we have any.
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
                //After filtering and gathering price data on all restaurants, convert our set to an array to be used with our tableview!
                [self.visibleRestaurants addObjectsFromArray:[self.restaurantSet allObjects]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.loadMoreButton.hidden = NO;
                    [self.indicator stopAnimating];
                    [self sortWithFilter:@"distance"];
                    [self.tableView reloadData];
                });
            }
        }];
    } failureHandler:^(id error) {
        self.loadMoreButton.hidden = NO;
        [self.indicator stopAnimating];
        NSLog(@"Error retrieving restaurants: %@", error);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops..." message:@"There was a problem trying to retrieve nearby restaurants. Please check your connection and try again!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)appWillResignActive:(NSNotification*)note
{
    [self.refreshControl endRefreshing];
}


- (void)showMapView
{
    MapViewController* mapView = [[MapViewController alloc]init];
    
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
        [self.navigationController pushViewController:mapView animated:NO];
    }completion:nil];
}

- (void)selectFilter
{
    UIAlertController *filterSheet = [UIAlertController alertControllerWithTitle:@"Select Filter" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *priceFilter = [UIAlertAction actionWithTitle:@"Price" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sortWithFilter:@"individualAvgPrice"];
    }];
    UIAlertAction *distanceFilter = [UIAlertAction actionWithTitle:@"Distance" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sortWithFilter:@"distance"];
    }];
    UIAlertAction *ratingFilter = [UIAlertAction actionWithTitle:@"Rating" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sortWithFilter:@"rating.doubleValue"];
    }];
    
    [filterSheet addAction:priceFilter];
    [filterSheet addAction:ratingFilter];
    [filterSheet addAction:distanceFilter];
    [filterSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [filterSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:filterSheet animated:YES completion:nil];
}

- (void)sortWithFilter:(NSString*)filter
{
    BOOL ascending = YES;
    if ([filter isEqualToString:@"rating.doubleValue"]) {
        ascending = NO;
    }
    NSSortDescriptor *ratingOrder = [NSSortDescriptor sortDescriptorWithKey:filter ascending:ascending];
    [self.visibleRestaurants sortUsingDescriptors:@[ratingOrder]];
    [self.tableView reloadData];
}

- (void)searchForRestaurant
{
    SearchViewController *searchView = [[SearchViewController alloc]init];
    searchView.currentLocation = self.locationManager.currentLocation.coordinate;//Stores a copy of the value at that location in time instead of pointing this value which might change!
    
    //Get 5 restaurants nearby to prepopulate for user
    NSMutableArray *nearby = [[NSMutableArray alloc]init];
    if (self.visibleRestaurants.count >= 1) {
        for (int i = 0; i < 5; ++i) {
            [nearby addObject:[self.visibleRestaurants objectAtIndex:i]];
            
        }
    }
    searchView.nearbyRestaurants = nearby;
    [self.navigationController pushViewController:searchView animated:YES];
}

//- (void)logoutCurrentUser
//{
//    NSError *error;
//    [[FIRAuth auth]signOut:&error];
//    if (!error) {
//        NSLog(@"Sign out successful");
//    }
//}


#pragma mark - UITableView datasource/delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantDetailViewController *detailView = [[RestaurantDetailViewController alloc]init];
    detailView.selectedRestaurant = self.visibleRestaurants[indexPath.row];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Make sure we have items in the array because a user can scroll like a madman while we're reloading/adding which is also when we removeAllObjects from our data structures.
    if (self.visibleRestaurants.count > 0) {
        FoursquareRestaurant *restaurant = [self.visibleRestaurants objectAtIndex:indexPath.row];
        cell.restaurantName.text = restaurant.name;
        cell.addressLabel.text = restaurant.shortAddress;
        cell.categoryLabel.text = [NSString stringWithFormat:@"%@", restaurant.category];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%0.1fmi", restaurant.distance.doubleValue];
        cell.priceLabel.text = [NSString stringWithFormat:@"$%0.2f", restaurant.individualAvgPrice.doubleValue];
        [cell.starRatingView convertNumberToStars:restaurant.rating];
        [cell.featuredImage setImageWithURL:[NSURL URLWithString:restaurant.featuredImageURL]placeholderImage:[UIImage new]];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.visibleRestaurants.count;
}

@end
