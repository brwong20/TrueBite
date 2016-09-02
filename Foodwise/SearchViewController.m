//
//  SearchViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/26/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "SearchViewController.h"
#import "RestaurantDataSource.h"
#import "FoursquareRestaurant.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"
#import "PriceUpdateController.h"

@interface SearchViewController()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) RestaurantDataSource *restaurantDataSource;

@property (nonatomic, strong) NSMutableArray *filteredRestaurants;
@property (nonatomic, strong) UIView *searchContainer;
@property (nonatomic, strong) UIImageView *searchIcon;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"back_arrow"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitSearch)];
    
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Where did you dine?"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.restaurantDataSource = [[RestaurantDataSource alloc]init];

    //Custom search bar...
    self.searchContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0)];
    self.searchContainer.backgroundColor = UIColorFromRGB(0x7A95A7);
    
    //Image width and content mode is purposely created this way to add padding to textfield's leftView.
    self.searchIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
    self.searchIcon.backgroundColor = [UIColor clearColor];
    self.searchIcon.contentMode = UIViewContentModeCenter;
    [self.searchIcon setImage:[UIImage imageNamed:@"search_pin"]];
    
    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(self.searchContainer.frame.size.width/2 - self.searchContainer.frame.size.width * 0.46, self.searchContainer.frame.size.height/2 - self.searchContainer.frame.size.height * 0.375, self.searchContainer.frame.size.width * 0.92, self.searchContainer.frame.size.height * 0.75)];
    self.searchField.backgroundColor = [UIColor whiteColor];
    self.searchField.font = [UIFont fontWithSize:17.0];
    self.searchField.placeholder = @"Search for a restaurant";
    self.searchField.layer.cornerRadius = self.searchField.frame.size.height * 0.2;
//    self.searchField.layer.borderWidth = 1.0;
//    self.searchField.layer.borderColor = [UIColor grayColor].CGColor;
    self.searchField.leftView = self.searchIcon;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    self.searchField.delegate = self;
    [self.searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.searchContainer addSubview:self.searchField];
    
    [self.view addSubview:self.searchContainer];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchContainer.frame), self.view.frame.size.width, self.view.frame.size.height - self.searchContainer.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
    self.filteredRestaurants = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //[LayoutBounds drawBoundsForAllLayers:self.searchContainer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.searchField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.searchField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)exitSearch
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate/datasource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCell"];

    FoursquareRestaurant *restaurant;
    if (self.searchField.text.length > 0) {
        restaurant = [self.filteredRestaurants objectAtIndex:indexPath.row];
    }else{
        restaurant = [self.nearbyRestaurants objectAtIndex:indexPath.row];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont semiboldFontWithSize:16.0];
    cell.textLabel.textColor = APPLICATION_FONT_COLOR;
    
    cell.detailTextLabel.font = [UIFont fontWithSize:14.0];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    cell.textLabel.text = restaurant.name;
    cell.detailTextLabel.text = restaurant.shortAddress;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoursquareRestaurant *selectedRestaurant = [[FoursquareRestaurant alloc]init];
    if (self.searchField.text.length == 0) {
        selectedRestaurant = [self.nearbyRestaurants objectAtIndex:indexPath.row];
    }else{
        selectedRestaurant = [self.filteredRestaurants objectAtIndex:indexPath.row];
    }
    
    PriceUpdateController *priceUpdateView = [[PriceUpdateController alloc]init];
    priceUpdateView.selectedRestaurant = selectedRestaurant;
    priceUpdateView.searchFlow = YES;
    [self.navigationController pushViewController:priceUpdateView animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Foursquare autocomplete requires >= 3 characters
    if (self.searchField.text.length > 0) {
        if (self.filteredRestaurants.count > 1) {
            return self.filteredRestaurants.count;
        }else{
            return 0;
        }
    }else{
        return self.nearbyRestaurants.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITextField methods

- (void)textFieldDidChange:(UITextField*)textField
{
    NSString *lat = [NSString stringWithFormat:@"%f", self.currentLocation.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", self.currentLocation.longitude];
    
    if (textField.text.length >= 1) {
        NSString *filteredString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        [self.filteredRestaurants removeAllObjects];
        [self.restaurantDataSource autoCompleteWithQuery:filteredString withLatitude:lat andLogitude:lng completionHandler:^(id JSON) {
            
            NSArray *miniVenues = JSON[@"response"][@"minivenues"]
            ;
            for (NSDictionary *miniDict in miniVenues) {
                //Check if result is a food spot first...
                BOOL isRestaurant = NO;
                NSArray *categories = miniDict[@"categories"];
                for (NSDictionary *category in categories) {
                    if ([category[@"name"] isEqualToString:@"Food"]) {
                        isRestaurant = YES;
                    }
                }
                
                if (isRestaurant) {
                    FoursquareRestaurant *miniRestaurant = [[FoursquareRestaurant alloc]initWithMiniDictionary:miniDict];
                    [self.filteredRestaurants addObject:miniRestaurant];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            
        } failureHandler:^(id error) {
            NSLog(@"ERROR SEARCHING: %@", error);
        }];
    }else{
        [self.tableView reloadData];
    }
}

#pragma mark - Keyboard/Tableview offset methods

- (void)keyboardWillShow:(NSNotification*)notification
{

    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].size;
    CGSize offsetSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    if (keyboardSize.height == offsetSize.height) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect viewFrame = self.tableView.frame;
            viewFrame.size.height -= (keyboardSize.height + self.searchContainer.frame.size.height);
            self.tableView.frame = viewFrame;
        }];
    }else{
        //If user opens up predictive view, add the offset size to the view
        [UIView animateWithDuration:0.1 animations:^{
            CGRect viewFrame = self.tableView.frame;
            //Add offset to view to account for dismissing and showing the predictive view1
            viewFrame.size.height += keyboardSize.height - offsetSize.height;
            self.tableView.frame = viewFrame;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration: 0.3 animations:^{
        self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.searchContainer.frame), self.view.frame.size.width, self.view.frame.size.height - self.searchContainer.frame.size.height);
    }];
}
@end
