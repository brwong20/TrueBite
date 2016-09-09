//
//  RestaurantDetailViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/23/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//


#import "RestaurantDetailViewController.h"
#import "PriceUpdateController.h"
#import "RestaurantDetailViewCell.h"
#import "HoursTableViewCell.h"
#import "RestaurantInfoTableViewCell.h"
#import "RestaurantDataSource.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"
#import "SpecificMapView.h"
#import "LocationManager.h"
#import "WKWebViewController.h"
#import "LocationManager.h"
#import "LayoutBounds.h"
#import "TabledCollectionCell.h"
#import "ImageCollectionCell.h"
#import "MWPhotoBrowser.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <MapKit/MapKit.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import <UIImageView+AFNetworking.h>


@interface RestaurantDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, RestaurantDetailCellDelegate, SpecificMapViewDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic) FIRDatabaseReference *restaurantRef;
@property (assign, nonatomic) FIRDatabaseHandle priceHandle;
@property (strong, nonatomic) RestaurantDataSource *restaurantDataSource;
@property (strong, nonatomic) SpecificMapView *restaurantMapView;

@property (strong, nonatomic) NSString *hoursOfOperation;
@property (strong, nonatomic) NSString *tags;
@property (strong, nonatomic) NSNumber *reviewCount;

@property (nonatomic, strong) NSMutableArray *smallRestaurantPhotos;//Only for our cell's collection view
@property (nonatomic, strong) NSMutableArray *originalRestaurantPhotos;

@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@property (nonatomic, strong)UITableView *tableView;
@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"back_arrow"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitDetailView)];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"TrueBite"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.restaurantRef = [[[FIRDatabase database]reference]child:@"restaurants"];
    self.restaurantDataSource = [[RestaurantDataSource alloc]init];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.restaurantMapView = [[SpecificMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.38)];
    self.restaurantMapView.delegate = self;
    CLLocationCoordinate2D restaurantCoordinate = CLLocationCoordinate2DMake(self.selectedRestaurant.latitude.floatValue, self.selectedRestaurant.longitude.floatValue);
    self.restaurantMapView.coordinate = restaurantCoordinate;
    [self.restaurantMapView pinLocation:restaurantCoordinate];
    [self.restaurantMapView animateToLocation:restaurantCoordinate];
    
    self.tableView.tableFooterView = self.restaurantMapView;
    
    [self.view addSubview:self.tableView];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
    
    self.smallRestaurantPhotos = [[NSMutableArray alloc]init];
    self.originalRestaurantPhotos = [[NSMutableArray alloc]init];
    
#pragma ONLY pull this data once on viewDidLoad for now since it doesnt change often
    //Detailed restaurant data (hours, openNow, etc.) is a bitch to parse, doesn't change oftern, and isn't vital anywhere anywhere else so just retrieve everytime we go into this view.
    [self.restaurantDataSource getRestaurantDetailsFor:self.selectedRestaurant.restaurantId completionHandler:^(id JSON) {
        //Make properties for this data and set in cell since they dont change much - good to put in viewwillappear because maybe Open Now might change to Closed!
        
        //            NSArray *timeFrames = hoursDict[@"timeframes"];
        //            NSDictionary *today = [timeFrames firstObject];
        //            NSString *todayString = today[@"days"];
        //            NSArray *openTimes = today[@"open"];
        //            NSDictionary *renderedTime = [openTimes firstObject];
        
        NSDictionary *venueDetails = JSON[@"response"][@"venue"];
        
        //NSLog(@"%@", venueDetails);
        
        NSDictionary *hours = venueDetails[@"hours"];
        
        if (hours.count > 0) {
            NSArray *openTimes = hours[@"timeframes"];
            
            NSDictionary *hoursToday = [openTimes firstObject];
            NSDictionary *openHours = [hoursToday[@"open"]firstObject];
            
            NSString *hoursTodayString = [NSString stringWithFormat:@"%@", openHours[@"renderedTime"]];
            
            if (hoursTodayString && ![hoursTodayString isEqualToString:@""]) {
                self.hoursOfOperation = hoursTodayString;
            }
        }else{
            self.hoursOfOperation = @"Hours currently unavailable";
        }

        NSArray *tags = venueDetails[@"tags"];
        
        NSMutableString *tagString = [[NSMutableString alloc]init];
        if (tags.count == 0 || !tags) {
            [tagString appendString:@"No tags available"];
        }
        else
        {
            for (NSString *tag in tags) {
                if(tags.count == 1)
                {
                    [tagString appendString:tag];
                }
                else
                {
                    //Capitalize first letter of each word cuz swag.
                    NSString *cappedTag = [tag stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[tag substringToIndex:1]uppercaseString]];
                    [tagString appendString:[NSString stringWithFormat:@"%@, ", cappedTag]];
                }
            }
        }
        
        //Remove last comma and space if there are multiple tags
        if (tags.count > 1) {
            self.tags = [tagString substringToIndex:tagString.length - 2];
        }else{
            self.tags = tagString;
        }

        NSNumber *numReviews = venueDetails[@"ratingSignals"];
        
        if (numReviews.integerValue > 0) {
            self.reviewCount = numReviews;
        }else{
            self.reviewCount = @(0);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failureHandler:^(id error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops..." message:@"There was a retrieving this restaurant's information. Please check your connection and try again!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Since we modify a POINTER to a Restaurant object in the PriceUpdater, we just need to update the tableView to reflect the price change
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Remove listener at child node
    [super viewWillDisappear:animated];
}

- (void)exitDetailView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SpecificMapView delegate methods

- (void)presentNavigationAlertWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    UIAlertController *navAlert = [UIAlertController alertControllerWithTitle:@"Open with" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *appleMaps = [UIAlertAction actionWithTitle:@"Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placeMark];
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        mapItem.name = self.selectedRestaurant.name;
        [mapItem openInMapsWithLaunchOptions:launchOptions];
        
    }];
    
    UIAlertAction *googleMaps = [UIAlertAction actionWithTitle:@"Google Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]];
        
        NSString *destinationLat = [NSString stringWithFormat:@"%f", coordinate.latitude];
        NSString *destinationLng = [NSString stringWithFormat:@"%f", coordinate.longitude];
        
#warning Make sure to update location here....
        CLLocation *currentLocation = [[LocationManager sharedLocationInstance]currentLocation];
        NSString *currentLat = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
        NSString *currentLng = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@,%@&daddr=%@,%@&directionsmode=driving&views=", currentLat, currentLng, destinationLat, destinationLng]]];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [navAlert addAction:appleMaps];
    [navAlert addAction:googleMaps];
    [navAlert addAction:cancel];
    
    [self presentViewController:navAlert animated:YES completion:nil];
}

- (void)mapViewDidClose
{
    //Collapse mapView and bring user back to the restaurant's pin
    [UIView animateWithDuration:0.3 animations:^{
        self.restaurantMapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.38);
        self.restaurantMapView.mapView.frame = CGRectMake(0, CGRectGetMaxY(self.restaurantMapView.navigationButton.frame), self.restaurantMapView.frame.size.width, self.restaurantMapView.frame.size.height - self.restaurantMapView.navigationButton.frame.size.height);
     
        //Because our mapView expands outside of the tableFooterView onto the main view, simply set it as the table footer view again to have it in its original position again
        self.tableView.tableFooterView = self.restaurantMapView;
    }completion:^(BOOL finished) {
        [self.restaurantMapView animateToLocation:self.restaurantMapView.coordinate];
    }];
}

#pragma mark - RestaurantDetailViewCell delegate methods

- (void)priceButtonClicked
{
    PriceUpdateController *priceUpdateView = [[PriceUpdateController alloc]init];
    priceUpdateView.selectedRestaurant = self.selectedRestaurant;
    priceUpdateView.searchFlow = NO;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:priceUpdateView];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma UITableView delegate/datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 135.0;
    }
    else if (indexPath.row == 1)
    {
        return 55.0;
    }
    else if(indexPath.row == 2)
    {
//        //Dynamically calculate cell size based on what the hours look like
//        if (self.hoursOfOperation && ![self.hoursOfOperation isEqualToString:@""]) {
//            CGSize maxCellSize = CGSizeMake(self.view.frame.size.width, 90.0);
//            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//            
//            CGRect hoursLabelSize = [self.hoursOfOperation boundingRectWithSize:maxCellSize options:NSStringDrawingUsesLineFragmentOrigin
//                                                                     attributes:@{NSFontAttributeName:[UIFont fontWithSize:16.0], NSParagraphStyleAttributeName: paragraphStyle.copy}
//                                     
//                                                                        context:nil];
//            return hoursLabelSize.size.height + 40.0;//Don't forget to account for title & rest of cell!
//        }else{
//            return 50.0;
//        }
        
        return 55.0;
    }else if (indexPath.row == 3)
    {
        return 55.0;
    }
    else if (indexPath.row == 4)
    {
        //Dynamically calculate cell size based on what the address looks like
        if (self.selectedRestaurant.formattedAddress && ![self.selectedRestaurant.formattedAddress isEqualToString:@""]) {
            CGSize maxCellSize = CGSizeMake(self.view.frame.size.width, 110.0);
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            CGRect hoursLabelSize = [self.selectedRestaurant.formattedAddress boundingRectWithSize:maxCellSize options:NSStringDrawingUsesLineFragmentOrigin
                                                                                        attributes:@{NSFontAttributeName:[UIFont fontWithSize:16.0], NSParagraphStyleAttributeName: paragraphStyle.copy}
                                                                                           context:nil];
            return hoursLabelSize.size.height + 62.0;//Don't forget to account for title & rest of cell!
        }else{
            return 55.0;
        }
    }
    else if (indexPath.row == 5)
    {
        return 110.0;
    }
    else if(indexPath.row == 6)
    {
        return 46.0;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        RestaurantDetailViewCell *detailCell = [[RestaurantDetailViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailCell"];
        detailCell.delegate = self;
        [detailCell populateCellTypeWithData:self.selectedRestaurant];
        [detailCell.starRatingView convertNumberToStars:self.selectedRestaurant.rating];
        detailCell.category.text = self.selectedRestaurant.category;
        detailCell.distance.text = [NSString stringWithFormat:@"%0.2f mi away", self.selectedRestaurant.distance.doubleValue];
        detailCell.priceLabel.text = [NSString stringWithFormat:@"$%0.2f", self.selectedRestaurant.individualAvgPrice.doubleValue];
        if (self.reviewCount.integerValue == 1) {
            detailCell.ratingsCountLabel.text = [NSString stringWithFormat:@"%@ review", self.reviewCount];
        }else if(self.reviewCount.integerValue > 1){
            detailCell.ratingsCountLabel.text = [NSString stringWithFormat:@"%@ reviews", self.reviewCount];
        }
        return detailCell;
    }
    else if (indexPath.row == 1)
    {
        //Tags currently have same real-time behavior as hours so reuse this class and tweak it
        HoursTableViewCell *tagCell = [[HoursTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tagCell"];
        tagCell.hoursTitle.text = @"Cuisine";
        tagCell.openNow.hidden = YES;
        [tagCell setTextWithFade:self.tags];
        return tagCell;
    }
    else if (indexPath.row == 2)
    {
        HoursTableViewCell *hourCell = [[HoursTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hourCell"];
        
        if ([self.hoursOfOperation isEqualToString:@"Hours currently unavailable"])
        {
            hourCell.openNow.text = @"";
        }
        else if (self.selectedRestaurant.openNow)
        {
            hourCell.openNow.textColor = UIColorFromRGB(0x7AD313);
            hourCell.openNow.text = @"Open now";
        }
        else
        {
#warning Have a better check for 24 hr places since Foursquare sucks
            hourCell.openNow.textColor = [UIColor redColor];
            hourCell.openNow.text = @"Closed";
        }
        [hourCell setTextWithFade:self.hoursOfOperation];
        return hourCell;
    }
    else if (indexPath.row == 3)
    {
        UITableViewCell *menuCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"menuCell"];
        menuCell.selectionStyle = UITableViewCellSelectionStyleNone;
        menuCell.textLabel.font = [UIFont semiboldFontWithSize:17.0];
        menuCell.textLabel.textColor = APPLICATION_FONT_COLOR;
        menuCell.textLabel.text = @"Menu";
        menuCell.detailTextLabel.font = [UIFont fontWithSize:16.0];
        menuCell.detailTextLabel.textColor = [UIColor lightGrayColor];
        if ([self.selectedRestaurant.menuURL isEqualToString:@""]) {
            menuCell.detailTextLabel.text = @"Unavailable";
        }else{
            menuCell.detailTextLabel.text = @"Available";
            menuCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return menuCell;
    }
    else if (indexPath.row == 4)
    {
        RestaurantInfoTableViewCell *infoCell = [[RestaurantInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addressCell"];
        infoCell.phoneNumber.text = self.selectedRestaurant.formattedPhoneNumber;
        [infoCell resizeToFitAddress:self.selectedRestaurant.formattedAddress];
        return infoCell;
    }
    else if (indexPath.row == 5)
    {
        static NSString *cellIdentifier = @"photoCell";
        
        TabledCollectionCell *photoCell = (TabledCollectionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!photoCell) {
            photoCell = [[TabledCollectionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        return photoCell;
    }
    else
    {
        UITableViewCell *defaultCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailCell"];
        return defaultCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        if (![self.selectedRestaurant.menuURL isEqualToString:@""]) {
            //WKWebViewConfiguration *config = [WKWebViewConfiguration alloc]
            
            NSURL *menuURL = [NSURL URLWithString:self.selectedRestaurant.menuURL];
            
            WKWebViewController *webView = [[WKWebViewController alloc]init];
            webView.url = menuURL;
            [self.navigationController pushViewController:webView animated:YES];

        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5) {
        TabledCollectionCell *photoCell = (TabledCollectionCell*)cell;
        [photoCell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        NSInteger index = photoCell.collectionView.indexPath.row;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]]floatValue];
        [photoCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
        
#warning Retrieve photos and reload here for now to keep it clean and simple :-). Eventually want to refactor and put this somewhere else and get ref to this cell bc this can be called multiple times
        [self.restaurantDataSource getPhotosForRestaurant:self.selectedRestaurant.restaurantId completionHandler:^(id JSON) {
            NSArray *photos = JSON[@"response"][@"photos"][@"items"];
            
            //NSLog(@"%@", photos);
            
            if (photos.count > 0)
            {
                //If there aren't any new photos or if this method is called multiple times, this prevents dupes from being added.
                if (photos.count != self.smallRestaurantPhotos.count) {
                    for (NSDictionary *photoDict in photos)
                    {
                        NSString *prefix = photoDict[@"prefix"];
                        NSString *suffix = photoDict[@"suffix"];
                        NSString *smallPhotoURL = [NSString stringWithFormat:@"%@%@%@", prefix, HQ_SMALL_PHOTO_SIZE, suffix];
                        NSString *originalPhotoURL = [NSString stringWithFormat:@"%@%@%@", prefix, ORIGINAL_PHOTO_SIZE, suffix];
                        
                        [self.smallRestaurantPhotos addObject:smallPhotoURL];
                        [self.originalRestaurantPhotos addObject:originalPhotoURL];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Only reload our photo cell
                        [photoCell.collectionView reloadData];
                    });
                }
                
            }
            
        } failureHandler:^(id error) {
            NSLog(@"Unable to retrieve photos");
        }];

    }
}

#pragma mark - UICollectionView datasource/delegate methods - This is for our collection view embedded in our UITableViewCell

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.smallRestaurantPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Make sure to register the cell type you want to use in the TabledCollectionCell subclass!

    ImageCollectionCell *cell = (ImageCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    NSURL *photoURL = [NSURL URLWithString:self.smallRestaurantPhotos[indexPath.row]];
    [cell.imageView setImageWithURL:photoURL placeholderImage:[UIImage new]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Retrieve and convert all photos here so we don't have to load them while in the photo browser!
    NSMutableArray *photos = [NSMutableArray array];
    
    for (NSString *photoUrlString in self.originalRestaurantPhotos) {
        NSURL *photoURL = [[NSURL alloc]initWithString:photoUrlString];
        MWPhoto *photo = [MWPhoto photoWithURL:photoURL];
        [photos addObject:photo];
    }
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc]initWithPhotos:photos];
    
    photoBrowser.delegate = self;
    photoBrowser.displayActionButton = YES;
    photoBrowser.zoomPhotosToFill = YES;
    //photoBrowser.enableGrid = YES;
    
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    //[photoBrowser startOnGrid];
    
    [self.navigationController pushViewController:photoBrowser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.originalRestaurantPhotos.count;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    IndexedPhotoCollectionView *collectionView = (IndexedPhotoCollectionView *)scrollView;
    NSInteger index = collectionView.indexPath.row;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}


@end
