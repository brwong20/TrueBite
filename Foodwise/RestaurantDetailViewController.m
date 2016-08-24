//
//  RestaurantDetailViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/23/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface RestaurantDetailViewController ()

@property (strong, nonatomic)FIRDatabaseReference *dbRef;
@property (strong, nonatomic)UITextField *priceField;
@property (strong, nonatomic)UIButton *priceButton;

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dbRef = [[FIRDatabase database]reference];
    
    self.priceField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.35, self.view.frame.size.height/2 - self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.7, self.view.frame.size.height * 0.05)];
    self.priceField.placeholder = @"How much did you pay?";
    self.priceField.layer.cornerRadius = 8.0;
    self.priceField.backgroundColor = [UIColor lightGrayColor];
    self.priceField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.priceField];
    
    self.priceButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxY(self.priceField.frame) + 15.0, self.view.frame.size.width/2 - self.view.frame.size.width * 0.3, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.1)];
    [self.priceButton addTarget:self action:@selector(savePrice) forControlEvents:UIControlEventTouchUpInside];
    self.priceButton.titleLabel.text = @"Submit";
    self.priceButton.backgroundColor = [UIColor greenColor];
    self.priceButton.titleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.priceButton];
    
}

- (void)savePrice
{
    [self.selectedRestaurant.individualPrices addObject:[NSNumber numberWithDouble:[self.priceField.text doubleValue]]];
    [[[self.dbRef child:@"restaurants"]child:self.selectedRestaurant.restaurantId]updateChildValues:@{@"individualPrices":self.selectedRestaurant.individualPrices}];
}



@end
