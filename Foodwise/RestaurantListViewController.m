//
//  RestaurantListViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/20/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "RestaurantListViewController.h"
#import "Restaurant.h"
#import "RestaurantTableViewCell.h"
#import "RestaurantDetailViewController.h"

#import <UIImageView+AFNetworking.h>
#import <FirebaseAuth/FirebaseAuth.h>

@interface RestaurantListViewController()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *restaurantArray;

@end

@implementation RestaurantListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Foodwise";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(logoutCurrentUser)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMapView)];
    
    UIBarButtonItem *mapView = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMapView)];
    UIBarButtonItem *filter = [[UIBarButtonItem alloc]initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(selectFilter)];
    
    self.navigationItem.rightBarButtonItems = @[mapView, filter];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[RestaurantTableViewCell class] forCellReuseIdentifier:@"cell"];

    //To be used with our table view!
    self.restaurantArray = [NSMutableArray arrayWithArray:[self.restaurantSet allObjects]];
    
    //[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)showMapView
{
    [UIView animateWithDuration:0.5 animations:^{
         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
         [self.navigationController popViewControllerAnimated:NO];
    }completion:nil];
}

- (void)selectFilter
{
    UIAlertController *filterSheet = [UIAlertController alertControllerWithTitle:@"Select Filter" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *priceFilter = [UIAlertAction actionWithTitle:@"Price" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sortWithFilter:@"price"];
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
    
    [self presentViewController:filterSheet animated:YES completion:nil];
}

- (void)sortWithFilter:(NSString*)filter
{
    BOOL ascending = NO;
    if ([filter isEqualToString:@"distance"]) {
        ascending = YES;
    }
    NSSortDescriptor *ratingOrder = [NSSortDescriptor sortDescriptorWithKey:filter ascending:ascending];
    [self.restaurantArray sortUsingDescriptors:@[ratingOrder]];
    [self.tableView reloadData];
}

- (void)logoutCurrentUser
{
    NSError *error;
    [[FIRAuth auth]signOut:&error];
    if (!error) {
        NSLog(@"Sign out successful");
    }
}


#pragma mark - UITableView datasource/delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantDetailViewController *detailView = [[RestaurantDetailViewController alloc]init];
    detailView.selectedRestaurant = self.restaurantArray[indexPath.row];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    Restaurant *restaurant = [self.restaurantArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.restaurantName.text = restaurant.name;
    cell.addressLabel.text = restaurant.address;
    cell.ratingLabel.text = [restaurant.rating stringValue];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%0.2fmi", restaurant.distance.doubleValue];
    //[cell.displayImage setImageWithURL:[NSURL URLWithString:restaurant.imageURL]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.restaurantSet.count;
}

@end
