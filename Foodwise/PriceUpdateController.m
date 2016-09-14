//
//  PriceUpdateController.m
//  Foodwise
//
//  Created by Brian Wong on 8/25/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "PriceUpdateController.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"
#import "MBProgressHUD.h"
#import "UIFont+Extension.h"
#import "RestaurantDataSource.h"
#import "FIRDatabaseManager.h"


#import <Firebase.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PriceUpdateController() <UITextFieldDelegate>

@property (nonatomic, strong) FIRDatabaseManager *dbManager;

@property (nonatomic, strong) RestaurantDataSource *restaurantDataSource;
@property (nonatomic, strong) FIRDatabaseReference *restaurantRef;
@property (nonatomic, assign) FIRDatabaseHandle priceHandle;

//Current price container
@property (nonatomic, strong) UIView *priceContainer;
@property (nonatomic, strong) UILabel *containerTitle;
@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *priceLabel;

//Price input field
@property (nonatomic, strong) UILabel *updateLabel;
@property (nonatomic, strong) UILabel *updateDescription;
@property (nonatomic, strong) UILabel *dollarSign;
@property (nonatomic, strong) UIView *period;

@property (nonatomic, strong) UITextField *priceField;
@property (nonatomic, strong) UIView *digitContainer;
@property (nonatomic, strong) UILabel *digitOne;
@property (nonatomic, strong) UILabel *digitTwo;
@property (nonatomic, strong) UILabel *digitThree;
@property (nonatomic, strong) UILabel *digitFour;
@property (nonatomic, strong) UIButton *submitButton;

//Price too high
@property (nonatomic, strong) UIView *highPriceView;
@property (nonatomic, strong) UILabel *reconsiderTitle;
@property (nonatomic, strong) UITextView *reconsiderTextView;
@property (nonatomic, strong) UIButton *resubmitButton;
@property (nonatomic, strong) UIButton *confirmButton;

//Animation for price change
@property (nonatomic, strong) UIView *priceChangeContainer;
@property (nonatomic, strong) UILabel *averageLabel;
@property (nonatomic, strong) UILabel *priceChangeLabel;
@property (nonatomic, strong) UILabel *oldPriceLabel;
@property (nonatomic, strong) UILabel *updatedPriceLabel;
@property (nonatomic, strong) UILabel *dollarLabel;

@end

@implementation PriceUpdateController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Update price"]];
    
    if (self.searchFlow) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"back_arrow"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitPriceUpdater)];
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(exitPriceUpdater)];
        
    }
    self.restaurantRef = [[[FIRDatabase database]reference]child:@"restaurants"];
    self.dbManager = [FIRDatabaseManager sharedManager];
    
    CGRect viewRect = self.view.frame;
    self.priceContainer = [[UIView alloc]initWithFrame:CGRectMake(viewRect.size.width/2 - viewRect.size.width * 0.375, viewRect.size.height * 0.02, viewRect.size.width * 0.75, viewRect.size.height * 0.16)];
    self.priceContainer.layer.borderColor = [UIColor grayColor].CGColor;
    self.priceContainer.layer.borderWidth = 1.0;
    self.priceContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.priceContainer];
    
    self.containerTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - self.priceContainer.frame.size.width * 0.4, self.priceContainer.frame.size.height * 0.06, self.priceContainer.frame.size.width * 0.8, self.priceContainer.frame.size.height * 0.2)];
    self.containerTitle.textColor = [UIColor lightGrayColor];
    self.containerTitle.font = [UIFont boldSystemFontOfSize:16.0];
    self.containerTitle.text = @"Average meal price at";
    self.containerTitle.backgroundColor = [UIColor clearColor];
    self.containerTitle.textAlignment = NSTextAlignmentCenter;
    [self.priceContainer addSubview:self.containerTitle];
    
    self.restaurantName = [[UILabel alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - self.priceContainer.frame.size.width * 0.45, CGRectGetMaxY(self.containerTitle.frame) + 5.0, self.priceContainer.frame.size.width * 0.9, self.priceContainer.frame.size.height * 0.2)];
    self.restaurantName.textColor = [UIColor blackColor];
    self.restaurantName.font = [UIFont boldSystemFontOfSize:16.0];
    self.restaurantName.text = self.selectedRestaurant.name;
    self.restaurantName.textAlignment = NSTextAlignmentCenter;
    [self.priceContainer addSubview:self.restaurantName];
    
    self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - self.priceContainer.frame.size.width * 0.25, CGRectGetMaxY(self.restaurantName.frame) + 10.0, self.priceContainer.frame.size.width * 0.5, self.priceContainer.frame.size.height * 0.3)];
    self.priceLabel.textColor = UIColorFromRGB(0x7AD313);
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    self.priceLabel.font = [UIFont boldSystemFontOfSize:24.0];
    self.priceLabel.text = [NSString stringWithFormat:@"$%0.2f", self.selectedRestaurant.individualAvgPrice.doubleValue];
    [self.priceContainer addSubview:self.priceLabel];
    
    self.updateLabel = [[UILabel alloc]initWithFrame:CGRectMake(viewRect.size.width/2 - viewRect.size.width * 0.4, CGRectGetMaxY(self.priceContainer.frame) + viewRect.size.height * 0.02, viewRect.size.width * 0.8, viewRect.size.height * 0.03)];
    self.updateLabel.backgroundColor = [UIColor clearColor];
    self.updateLabel.textAlignment = NSTextAlignmentCenter;
    self.updateLabel.textColor = [UIColor grayColor];
    self.updateLabel.font = [UIFont boldSystemFontOfSize:18.0];
    self.updateLabel.text = @"Enter the cost of your meal";
    [self.view addSubview:self.updateLabel];
    
    self.updateDescription = [[UILabel alloc]initWithFrame:CGRectMake(viewRect.size.width/2 - viewRect.size.width * 0.475, CGRectGetMaxY(self.updateLabel.frame) + 4.0, viewRect.size.width * 0.95, viewRect.size.height * 0.03)];
    self.updateDescription.backgroundColor = [UIColor clearColor];
    self.updateDescription.textColor = [UIColor lightGrayColor];
    self.updateDescription.textAlignment = NSTextAlignmentCenter;
    self.updateDescription.font = [UIFont systemFontOfSize:14.0];
    self.updateDescription.text = @"(Include tax & tip. Price is for 1 person)";
    [self.view addSubview:self.updateDescription];
    
    self.dollarSign = [[UILabel alloc]initWithFrame:CGRectMake(viewRect.size.width * 0.03, viewRect.size.height/2.75 - viewRect.size.width * 0.04, viewRect.size.width * 0.07, viewRect.size.height * 0.07)];
    self.dollarSign.text = @"$";
    self.dollarSign.textAlignment = NSTextAlignmentCenter;
    self.dollarSign.font = [UIFont systemFontOfSize:viewRect.size.height * 0.065];
    self.dollarSign.textColor = [UIColor blackColor];
    self.dollarSign.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.dollarSign];
    
    //Putting our textfields in this makes aligning them with the priceContainer easier.
    self.digitContainer = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.priceContainer.frame), CGRectGetMaxY(self.updateDescription.frame) + viewRect.size.height * 0.04, self.priceContainer.frame.size.width, viewRect.size.height * 0.12)];
    self.digitContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.digitContainer];
    
    //In order to not let the user edit the price and keep things behaving cleaner. We will use this textfield to populate the labels/"fake fields".
    self.priceField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 0.0, 0.0)];
    self.priceField.keyboardType = UIKeyboardTypeNumberPad;
    self.priceField.backgroundColor = [UIColor clearColor];
    self.priceField.tintColor = [UIColor clearColor];
    self.priceField.delegate = self;
    [self.priceField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [self.digitContainer addSubview:self.priceField];
    
    self.digitOne = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitOne.tag = 1;
    //self.digitOne.userInteractionEnabled = NO;
    self.digitOne.textAlignment = NSTextAlignmentCenter;
    self.digitOne.font = [UIFont systemFontOfSize:self.digitContainer.frame.size.height * 0.7];
    self.digitOne.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.digitOne.tintColor = [UIColor clearColor];
    self.digitOne.layer.borderWidth = 1.5;
    self.digitOne.backgroundColor = [UIColor clearColor];
    [self.digitContainer addSubview:self.digitOne];
    
    //Set up first and last digit to bound the textviews in the digit container then space them into the center proportionally (used 0.5 between digit 1 & 2/3 & 4).
    self.digitFour = [[UILabel alloc]initWithFrame:CGRectMake(self.digitContainer.frame.size.width - self.digitContainer.frame.size.width * 0.2, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitFour.tag = 4;
    //self.digitFour.userInteractionEnabled = NO;
    self.digitFour.textAlignment = NSTextAlignmentCenter;
    self.digitFour.font = [UIFont systemFontOfSize:self.digitContainer.frame.size.height * 0.7];
    self.digitFour.tintColor = [UIColor clearColor];
    self.digitFour.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.digitFour.layer.borderWidth = 1.5;
    self.digitFour.backgroundColor = [UIColor clearColor];
    [self.digitContainer addSubview:self.digitFour];
    
    self.digitTwo = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.digitOne.frame) + self.digitContainer.frame.size.width * 0.05, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitTwo.tag = 2;
    //self.digitTwo.userInteractionEnabled = NO;
    self.digitTwo.textAlignment = NSTextAlignmentCenter;
    self.digitTwo.font = [UIFont systemFontOfSize:self.digitContainer.frame.size.height * 0.7];
    self.digitTwo.tintColor = [UIColor clearColor];
    self.digitTwo.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.digitTwo.layer.borderWidth = 1.5;
    self.digitTwo.backgroundColor = [UIColor clearColor];
    [self.digitContainer addSubview:self.digitTwo];
    
    self.period = [[UIView alloc]initWithFrame:CGRectMake(self.priceContainer.frame.size.width/2 - viewRect.size.width * 0.01, CGRectGetMaxY(self.digitTwo.frame) - viewRect.size.width * 0.021, viewRect.size.width * 0.02, viewRect.size.width * 0.02)];
    self.period.layer.shouldRasterize = YES;
    self.period.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.period.backgroundColor = [UIColor grayColor];
    self.period.layer.cornerRadius = self.period.frame.size.height/2;
    [self.digitContainer addSubview:self.period];
    
    self.digitThree = [[UILabel alloc]initWithFrame:CGRectMake(self.digitFour.frame.origin.x - self.digitContainer.frame.size.width * 0.25, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitThree.tag = 3;
    //self.digitThree.userInteractionEnabled = NO;
    self.digitThree.textAlignment = NSTextAlignmentCenter;
    self.digitThree.font = [UIFont systemFontOfSize:self.digitContainer.frame.size.height * 0.7];
    self.digitThree.tintColor = [UIColor clearColor];
    self.digitThree.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.digitThree.layer.borderWidth = 1.5;
    self.digitThree.backgroundColor = [UIColor clearColor];
    [self.digitContainer addSubview:self.digitThree];

    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, viewRect.size.width, self.view.frame.size.height * 0.07)];
    self.submitButton.alpha = 0.0;
    self.submitButton.backgroundColor = UIColorFromRGB(0x17A1FF);
    self.submitButton.titleLabel.textColor = [UIColor whiteColor];
    self.submitButton.titleLabel.font = [UIFont semiboldFontWithSize:20.0];
    [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.priceField setInputAccessoryView:self.submitButton];
    
    [self.priceField becomeFirstResponder];

    self.restaurantDataSource = [[RestaurantDataSource alloc]init];
    
    //Since the search gives us barely any info of the restaurant, see if we have any, if not, add the new restaurant into our db with info
    if (self.searchFlow) {
        [[[[FIRDatabase database]reference] child:@"restaurants"]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *allRestaurants = snapshot.value;
            if (allRestaurants.count > 0) {
                    NSDictionary *foundRestaurant = [allRestaurants objectForKey:self.selectedRestaurant.restaurantId];
                
                    //If the restaurant isn't in our database, add it as a new node. otherwise it's a restaurant we already have saved so retrieve the relevant price data on it!
                    if (foundRestaurant) {
                        [self.selectedRestaurant retrievePriceDataFrom:foundRestaurant];
                    }else{
                        [self.restaurantDataSource getRestaurantDetailsFor:self.selectedRestaurant.restaurantId completionHandler:^(id JSON) {
                            NSDictionary *venueDetails = JSON[@"response"][@"venue"];

                            //Get needed info and create a new node in db
                            FoursquareRestaurant *newRestaurant = [[FoursquareRestaurant alloc]initWithDetailedDictionary:venueDetails andId:self.selectedRestaurant.restaurantId];
                            [[self.restaurantRef child:newRestaurant.restaurantId]updateChildValues:[newRestaurant fireBaseDictionary]];
                            self.selectedRestaurant = newRestaurant;
                            
                        } failureHandler:^(id error) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops..." message:@"There was a problem submitting your price for this new restaurant. Please check your connection and try again!" preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [alert dismissViewControllerAnimated:YES completion:nil];
                                self.submitButton.userInteractionEnabled = YES;
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }];
                    }
                }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.priceHandle) {
        [self.restaurantRef removeObserverWithHandle:self.priceHandle];
    }
}

- (void)submitButtonClicked
{
    //Don't want user submitting multiple prices at once
    //self.submitButton.userInteractionEnabled = NO;
    
    //Before anything, we must reverse the string since we make the user input them in reverse order
    NSString *reversedString = [self reverseString:self.priceField.text];
    NSNumber *priceToSubmit = [NSNumber numberWithDouble:(reversedString.doubleValue/100)];//We have to divide by 10 since we're always taking the price value in as a 4 digit value!
    
    //CHECK IF USER IS CONNECTED TO SERVER. IF NOT, NO COMPLETION BLOCKS ARE CALLED.....
    FIRDatabaseReference *connectedRef = [[FIRDatabase database] referenceWithPath:@".info/connected"];
    [connectedRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if([snapshot.value boolValue]){
            [self doubleCheckPrice:priceToSubmit];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops..." message:@"There was a problem trying to submit your price. Please check your connection and try again!" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    //[self doubleCheckPrice:priceToSubmit];
}

- (void)submitPrice
{
    NSNumber *oldPrice = self.selectedRestaurant.individualAvgPrice;
    
    //Before anything, we must reverse the string since we make the user input them in reverse order
    NSString *reversedString = [self reverseString:self.priceField.text];
    NSNumber *priceToSubmit = [NSNumber numberWithDouble:(reversedString.doubleValue/100)];//We have to divide by 10 since we're always taking the price value in as a 4 digit value!

#warning For some reason, Firebase sometimes doesn't perform a callback when a child is updated and needs multiple calls..
    [self.dbManager updateAverageForRestaurant:self.selectedRestaurant withNewPrice:priceToSubmit completionHandler:^(id newAverage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.submitButton.userInteractionEnabled = YES;
            
            //If we came into this method from the double check view.
            if (self.highPriceView.superview)
                [self.highPriceView removeFromSuperview];
            
            if (self.searchFlow) {
                [self showPriceUpdate:oldPrice toNewPrice:self.selectedRestaurant.individualAvgPrice];
            }else{
                [self exitPriceUpdater];
            }
        });
    } failureHandler:^(id error) {
        NSLog(@"ERROR UPDATING PRICE");
    }];
}

//Tries to keep the user in check if their price is too high
- (void)doubleCheckPrice:(NSNumber*)priceToSubmit
{
    //Checks to see if submitted price is off the average. If price was never set before, use that as first price
    if ((priceToSubmit.doubleValue >= self.selectedRestaurant.individualAvgPrice.doubleValue + 10.0 || priceToSubmit.floatValue <= self.selectedRestaurant.individualAvgPrice.floatValue - 10.0) && self.selectedRestaurant.individualAvgPrice.doubleValue != 0.0) {
        self.highPriceView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.4, self.view.frame.size.height/2 - self.view.frame.size.height * 0.225, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.45)];
        self.highPriceView.backgroundColor = UIColorFromRGB(0x92B9D7);
        
        self.reconsiderTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.highPriceView.frame.size.width/2 - self.highPriceView.frame.size.width * 0.3, self.highPriceView.frame.size.height * 0.1, self.highPriceView.frame.size.width * 0.6, APPLICATION_FRAME.size.height * 0.04)];
        self.reconsiderTitle.userInteractionEnabled = NO;
        self.reconsiderTitle.text = @"Are you sure?";
        self.reconsiderTitle.textColor = [UIColor whiteColor];
        self.reconsiderTitle.font = [UIFont semiboldFontWithSize:APPLICATION_FRAME.size.height * 0.033];
        self.reconsiderTitle.textAlignment = NSTextAlignmentCenter;
        [self.highPriceView addSubview:self.reconsiderTitle];
        
        self.reconsiderTextView = [[UITextView alloc]initWithFrame:CGRectMake(self.highPriceView.frame.size.width/2 - self.highPriceView.frame.size.width * 0.4, CGRectGetMaxY(self.reconsiderTitle.frame) + self.highPriceView.frame.size.height * 0.05, self.highPriceView.frame.size.width * 0.8, self.highPriceView.frame.size.height * 0.5)];
        self.reconsiderTextView.userInteractionEnabled = NO;
        self.reconsiderTextView.editable = NO;
        self.reconsiderTextView.font = [UIFont mediumFontWithSize:APPLICATION_FRAME.size.height * 0.025];
        self.reconsiderTextView.textAlignment = NSTextAlignmentCenter;
        self.reconsiderTextView.backgroundColor = [UIColor clearColor];
        self.reconsiderTextView.textColor = [UIColor whiteColor];
        self.reconsiderTextView.text = [NSString stringWithFormat:@"$%0.2f seems far off from the normal range...\nRemember, accurate pricing helps the whole community save money!", priceToSubmit.doubleValue];
        [self.highPriceView addSubview:self.reconsiderTextView];
        
        self.resubmitButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.highPriceView.frame.size.width * 0.44, self.highPriceView.frame.size.width * 0.18)];
        self.resubmitButton.center = CGPointMake(self.highPriceView.frame.size.width * 0.27, CGRectGetMaxY(self.reconsiderTextView.frame) + self.highPriceView.frame.size.height * 0.09);
        self.resubmitButton.layer.cornerRadius = self.resubmitButton.frame.size.height * 0.5;
        self.resubmitButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.resubmitButton.layer.borderWidth = 3.0;
        self.resubmitButton.titleLabel.font = [UIFont semiboldFontWithSize:20.0];
        [self.resubmitButton setTitle:@"Go back" forState:UIControlStateNormal];
        [self.resubmitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.resubmitButton addTarget:self action:@selector(cancelPriceSubmit) forControlEvents:UIControlEventTouchUpInside];
        [self.highPriceView addSubview:self.resubmitButton];
        
        self.confirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.highPriceView.frame.size.width * 0.44, self.highPriceView.frame.size.width * 0.18)];
        self.confirmButton.center = CGPointMake(self.highPriceView.frame.size.width * 0.73, CGRectGetMaxY(self.reconsiderTextView.frame) + self.highPriceView.frame.size.height * 0.09);
        self.confirmButton.layer.cornerRadius = self.resubmitButton.frame.size.height * 0.5;
        self.confirmButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.confirmButton.layer.borderWidth = 3.0;
        self.confirmButton.titleLabel.font = [UIFont semiboldFontWithSize:20.0];
        [self.confirmButton setTitle:@"I'm sure" forState:UIControlStateNormal];
        [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.confirmButton addTarget:self action:@selector(submitPrice) forControlEvents:UIControlEventTouchUpInside];
        [self.highPriceView addSubview:self.confirmButton];
        
        //Show over everything
        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
        [window addSubview:self.highPriceView];
        [window bringSubviewToFront:self.highPriceView];
    }else{
        //If not a crazy price, submit it
        [self submitPrice];
    }
}

- (void)cancelPriceSubmit
{
    if ([self.highPriceView superview]) {
        self.submitButton.userInteractionEnabled = YES;
        [self.highPriceView removeFromSuperview];
    }
}

- (void)showPriceUpdate:(NSNumber*)oldPrice toNewPrice:(NSNumber*)newPrice;
{
    //Comes up from bottom
    self.priceChangeContainer = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.42, -self.view.frame.size.height * 0.25, self.view.frame.size.width * 0.84, self.view.frame.size.height * 0.25)];
    self.priceChangeContainer.backgroundColor = UIColorFromRGB(0x92B9D7);
    self.priceChangeContainer.layer.cornerRadius = self.priceChangeContainer.frame.size.height * 0.03;
    self.priceChangeContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    self.priceChangeContainer.layer.borderWidth = 2.0;
    
    //Show over everything
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    [window addSubview:self.priceChangeContainer];
    [window bringSubviewToFront:self.priceChangeContainer];
    
    self.priceChangeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.priceChangeContainer.frame.size.width/2 - self.priceChangeContainer.frame.size.width * 0.475, self.priceChangeContainer.frame.size.height * 0.1, self.priceChangeContainer.frame.size.width * 0.95, self.priceChangeContainer.frame.size.height * 0.5)];
    self.priceChangeLabel.numberOfLines = 0;
    self.priceChangeLabel.text = @"Thanks for submitting a price.\nYour fellow foodies appreciate it!";
    self.priceChangeLabel.textAlignment = NSTextAlignmentCenter;
    self.priceChangeLabel.textColor = [UIColor whiteColor];
    self.priceChangeLabel.backgroundColor = [UIColor clearColor];
    self.priceChangeLabel.font = [UIFont semiboldFontWithSize:APPLICATION_FRAME.size.height * 0.03];
    [self.priceChangeLabel sizeToFit];
    [self.priceChangeContainer addSubview:self.priceChangeLabel];
    
    self.averageLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.priceChangeContainer.frame.size.width/2 - self.priceChangeContainer.frame.size.width * 0.25, CGRectGetMaxY(self.priceChangeLabel.frame) + 8.0, self.priceChangeContainer.frame.size.width * 0.5, APPLICATION_FRAME.size.height * 0.035)];
    self.averageLabel.font = [UIFont semiboldFontWithSize:APPLICATION_FRAME.size.height * 0.03];
    self.averageLabel.textAlignment = NSTextAlignmentCenter;
    self.averageLabel.textColor = [UIColor whiteColor];
    self.averageLabel.text = @"New Average";
    self.averageLabel.backgroundColor = [UIColor clearColor];
    [self.priceChangeContainer addSubview:self.averageLabel];
    
    self.dollarLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.averageLabel.frame) , CGRectGetMaxY(self.averageLabel.frame) + 3.0, self.priceContainer.frame.size.width * 0.15, APPLICATION_FRAME.size.height * 0.06)];
    self.dollarLabel.backgroundColor = [UIColor clearColor];
    self.dollarLabel.textAlignment = NSTextAlignmentRight;
    self.dollarLabel.textColor = [UIColor whiteColor];
    self.dollarLabel.font = [UIFont semiboldFontWithSize:APPLICATION_FRAME.size.height * 0.05];
    self.dollarLabel.text = @"$";
    [self.priceChangeContainer addSubview:self.dollarLabel];
    
    self.oldPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.dollarLabel.frame), CGRectGetMaxY(self.averageLabel.frame) + 3.0, self.priceChangeContainer.frame.size.width * 0.3, APPLICATION_FRAME.size.height * 0.06)];
    self.oldPriceLabel.text = [NSString stringWithFormat:@"%0.2f", oldPrice.doubleValue];
    self.oldPriceLabel.textAlignment = NSTextAlignmentCenter;
    self.oldPriceLabel.backgroundColor = [UIColor clearColor];
    self.oldPriceLabel.textColor = [UIColor whiteColor];
    self.oldPriceLabel.font = [UIFont semiboldFontWithSize:APPLICATION_FRAME.size.height * 0.05];
    self.oldPriceLabel.alpha = 1.0;
    [self.priceChangeContainer addSubview:self.oldPriceLabel];
    
    //Fade up from bottom to replace old price
    self.updatedPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.dollarLabel.frame), self.priceChangeContainer.frame.size.height, self.priceChangeContainer.frame.size.width * 0.3, APPLICATION_FRAME.size.height * 0.06)];
    self.updatedPriceLabel.text = [NSString stringWithFormat:@"%0.2f", newPrice.doubleValue];
    self.updatedPriceLabel.textAlignment = NSTextAlignmentCenter;
    self.updatedPriceLabel.backgroundColor = [UIColor clearColor];
    self.updatedPriceLabel.textColor = [UIColor whiteColor];
    self.updatedPriceLabel.font = [UIFont semiboldFontWithSize:APPLICATION_FRAME.size.height * 0.05];
    self.updatedPriceLabel.alpha = 0.0;
    [self.priceChangeContainer addSubview:self.updatedPriceLabel];
    
    //[LayoutBounds drawBoundsForAllLayers:self.priceChangeContainer];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect priceView = self.priceChangeContainer.frame;
        priceView.origin.y = self.view.frame.size.height/2 - self.view.frame.size.height * 0.2;
        self.priceChangeContainer.frame = priceView;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect oldLabel = self.oldPriceLabel.frame;
            self.oldPriceLabel.alpha = 0.0;
            oldLabel.origin.y -= 20.0;
            self.oldPriceLabel.frame = oldLabel;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect newLabel = self.updatedPriceLabel.frame;
                self.updatedPriceLabel.alpha = 1.0;
                newLabel.origin.y =  CGRectGetMaxY(self.averageLabel.frame) + 3.0;
                self.updatedPriceLabel.frame = newLabel;
            }completion:^(BOOL finished) {
                //Let the user see and read the animation
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.priceChangeContainer removeFromSuperview];
                    [self exitPriceUpdater];
                });
            }];
        }];
    }];
}

- (void)exitPriceUpdater
{
    if (self.searchFlow) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)reverseString:(NSString *)stringToReverse
{
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[stringToReverse length]];
    [stringToReverse enumerateSubstringsInRange:NSMakeRange(0, [stringToReverse length])
                                        options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                         [reversedString appendString:substring];
                                     }];
    return reversedString;
}

#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        //Delete numbers from last to first
        switch (range.location) {
            case 0:
                self.digitFour.text = nil;
                break;
            case 1:
                self.digitFour.text = self.digitThree.text;
                self.digitThree.text = nil;
                break;
            case 2:
                self.digitFour.text = self.digitThree.text;
                self.digitThree.text = self.digitTwo.text;
                self.digitTwo.text = nil;
                break;
            case 3:
                self.digitFour.text = self.digitThree.text;
                self.digitThree.text = self.digitTwo.text;
                self.digitTwo.text = self.digitOne.text;
                self.digitOne.text = nil;
                break;
            default:
                break;
        }
        return YES;
    } else if (textField.text.length == 4) {
        return NO;
    } else {
        //Since we're dealing with price, the way we input numbers are reversed so it looks better (numbers come in from the right)
        switch (range.location) {
            case 0:
                self.digitFour.text = string;
                break;
            case 1:
                self.digitThree.text = self.digitFour.text;
                self.digitFour.text = string;
                break;
            case 2:
                self.digitTwo.text = self.digitThree.text;
                self.digitThree.text = self.digitFour.text;
                self.digitFour.text = string;
                break;
            case 3:
                self.digitOne.text = self.digitTwo.text;
                self.digitTwo.text = self.digitThree.text;
                self.digitThree.text = self.digitFour.text;
                self.digitFour.text = string;
                break;
            default:
                break;
        }
        
        return YES;
    }
}

- (void)textFieldDidChange:(id)sender
{
    if (self.priceField.text.length > 2) {
        [UIView animateWithDuration:0.3 animations:^{
            self.submitButton.alpha = 1.0;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.submitButton.alpha = 0.0;
        }];
    }
}

@end
