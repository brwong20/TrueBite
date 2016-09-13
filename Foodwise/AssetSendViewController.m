//
//  AssetSendViewController.m
//  TrueBite
//
//  Created by Brian Wong on 9/5/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "AssetSendViewController.h"
#import "PriceFilterView.h"
#import "FIRDatabaseManager.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <MBProgressHUD.h>
#import <UIView+Toast.h>

@interface AssetSendViewController() <UIScrollViewDelegate, PriceFilterDelegate>

@property (nonatomic, strong) FIRDatabaseManager *dbManager;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

//@property (nonatomic, strong) PriceFilterView *priceFilterView;

@property (nonatomic, strong) MBProgressHUD *saveHUD;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation AssetSendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dbManager = [FIRDatabaseManager sharedManager];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView setImage:self.selectedImage];
    [self.view addSubview:self.imageView];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.contentSize = CGSizeMake(2 * self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
//    //Starts on right for now, so user has to scroll left for price filter
//    self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height);
//    [self.view addSubview:self.scrollView];
//    
//    self.priceFilterView = [[PriceFilterView alloc]initWithFrame:self.imageView.frame];
//    self.priceFilterView.delegate = self;
//    [self.scrollView addSubview:self.priceFilterView];
    
    self.cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - self.view.frame.size.height * 0.13, self.view.frame.size.height * 0.13, self.view.frame.size.height * 0.13)];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setImage:[UIImage imageNamed:@"decline_icon"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(exitImageView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
//    self.saveButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.height * 0.08, self.view.frame.size.height - self.view.frame.size.height * 0.16, self.view.frame.size.height * 0.16, self.view.frame.size.height * 0.16)];
//    self.saveButton.backgroundColor = [UIColor clearColor];
//    [self.saveButton setImage:[UIImage imageNamed:@"gallery-save"] forState:UIControlStateNormal];
//    [self.saveButton addTarget:self action:@selector(saveImageToAlbum) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.saveButton];
//    
    self.submitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - self.view.frame.size.height * 0.13, self.view.frame.size.height - self.view.frame.size.height * 0.13, self.view.frame.size.height * 0.13, self.view.frame.size.height * 0.13)];
    self.submitButton.backgroundColor = [UIColor clearColor];
    [self.submitButton setImage:[UIImage imageNamed:@"done_icon1"] forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    
    self.saveHUD = [[MBProgressHUD alloc]init];
    [self.view addSubview:self.saveHUD];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)exitImageView
{
    [self.navigationController popViewControllerAnimated:NO];
}


//Differentiate if we need to save filter image or reg image! - Refactor this check and functionality in a method
- (void)saveImageToAlbum
{
    self.saveHUD.labelText = @"Saving photo";
    [self.saveHUD show:YES];
    
    UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0.0);
    
    //Render and copy the image first, then render whatever the scrollview is onto the image.
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    //[self.priceFilterView prepareFilterForRender];//Find a better way to do this!
    //[self.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(img, nil, @selector(hideHUD), nil);
    UIGraphicsEndImageContext();
}


//TODO: Tell user they have to set a valid price (not 00.00) - use a toast
//TODO: If user clicks button while uipicker is scrolling, tell them they have to pick valid price
- (void)complete
{
    //Remember to check for photo filter!!!
    self.saveHUD.labelText = @"Uploading photo";
    
//    CGPoint originalPosition = CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height);
//    
//    if (!CGPointEqualToPoint(self.scrollView.contentOffset, originalPosition)) {
//        
//        if(!self.priceFilterView.currentPrice){
//            [self.view makeToast:@"Please submit a price greater than $0.00" duration:1.0 position:CSToastPositionCenter];
//            return;
//        }
//        
//        UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0.0);
//        
//        //Render and copy the image first, then render whatever the scrollview is onto the image (even if there's nothing there!)
//        [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
//        [self.priceFilterView prepareFilterForRender];//Find a better way to do this!
//        [self.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
//        
//        //User must be on our price filter if not on original offset, so retrieve the price data
//        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        [self.saveHUD show:YES];
//        
//        [self.dbManager uploadPricedPhotoForRestaurant:self.selectedRestaurant photo:img price:self.priceFilterView.currentPrice completionHandler:^(id metadata) {
//            [self.dbManager updateAverageForRestaurant:self.selectedRestaurant withNewPrice:self.priceFilterView.currentPrice completionHandler:^(id newAverage) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self hideHUD];
//                    [self.navigationController setNavigationBarHidden:NO];
//                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];//Back to detail view
//                });
//            } failureHandler:^(id error) {
//                NSLog(@"Couldnt update price with photo");
//            }];
//        } failureHandler:^(id error) {
//            NSLog(@"Couldnt upload photo");
//        }];
//    }
//    else
//    {
        [self.saveHUD show:YES];
        
        UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0.0);
        
        //Render and copy the image first, then render whatever the scrollview is onto the image (even if there's nothing there!)
        [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        //User must be on our price filter if not on original offset, so retrieve the price data
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.dbManager uploadPhotoForRestaurant:self.selectedRestaurant photo:img completionHandler:^(id metadata) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHUD];
                [self.navigationController setNavigationBarHidden:NO];
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];
            });
        } failureHandler:^(id error) {
            NSLog(@"Failed uploading regular photo");
        }];
//    }
}
- (void)hideHUD
{
    [self.saveHUD hide:YES];
}

#pragma mark - UIPickerViewDelegate methods

//Don't let user submit when picker is still scrolling or else it won't show (change alpha of button)
//- (void)didStartPickingPrice
//{
//    self.submitButton.enabled = NO;
//}
//
//- (void)didEndPickingPrice
//{
//    self.submitButton.enabled = YES;
//}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
