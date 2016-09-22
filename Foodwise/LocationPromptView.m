//
//  IntroView.m
//  Foodwise
//
//  Created by Brian Wong on 8/30/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "LocationPromptView.h"
#import "LocationManager.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"

@interface LocationPromptView() <LocationManagerDelegate>

@property (strong, nonatomic) LocationManager *locationManager;

@property (strong, nonatomic) UIImageView *pinImage;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *privateLabel;
@property (strong, nonatomic) UIButton *permissionButton;

@end

@implementation LocationPromptView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {

        self.backgroundColor = [UIColor whiteColor];
        
        self.locationManager = [LocationManager sharedLocationInstance];
        
        self.pinImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.2, self.frame.size.height/2.7 - self.frame.size.width * 0.2, self.frame.size.width * 0.4, self.frame.size.width * 0.4)];
        self.pinImage.contentMode = UIViewContentModeCenter;
        [self.pinImage setImage:[UIImage imageNamed:@"map_pin"]];
        self.pinImage.backgroundColor = [UIColor clearColor];
        [self addSubview:self.pinImage];
        
        self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width * 0.8, self.frame.size.height * 0.3)];
        self.locationLabel.text = @"Grant location access to\nsee restaurants near you";
        self.locationLabel.font = [UIFont semiboldFontWithSize:20.0];
        self.locationLabel.textColor = APPLICATION_FONT_COLOR;
        self.locationLabel.textAlignment = NSTextAlignmentCenter;
        self.locationLabel.numberOfLines = 0;
        [self.locationLabel sizeToFit];
        self.locationLabel.center = CGPointMake(self.frame.size.width/2, CGRectGetMaxY(self.pinImage.frame) + self.frame.size.height * 0.05);
        [self addSubview:self.locationLabel];
        
        self.privateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width * 0.6, self.frame.size.height * 0.2)];
        self.privateLabel.text = @"(location will stay private)";
        self.privateLabel.font = [UIFont fontWithSize:18.0];
        self.privateLabel.textColor = [UIColor lightGrayColor];
        [self.privateLabel sizeToFit];
        self.privateLabel.center = CGPointMake(self.frame.size.width/2, CGRectGetMaxY(self.locationLabel.frame) + self.frame.size.height * 0.02);
        [self addSubview:self.privateLabel];
        
        self.permissionButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.3, frame.size.height - frame.size.height * 0.12, self.frame.size.width * 0.6, self.frame.size.height * 0.07)];
        [self.permissionButton setTitle:@"Give access" forState:UIControlStateNormal];
        [self.permissionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.permissionButton.titleLabel setFont:[UIFont semiboldFontWithSize:20.0]];
        [self.permissionButton addTarget:self action:@selector(requestLocationPermission) forControlEvents:UIControlEventTouchUpInside];
        self.permissionButton.layer.cornerRadius = self.frame.size.height * 0.035;
        self.permissionButton.backgroundColor = APPLICATION_BLUE_COLOR;

        [self addSubview:self.permissionButton];
    }
    
    return self;
}

- (void)requestLocationPermission
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"com.truebite.onboarding.location"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.locationManager requestLocationAuthorization];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.frame;
        frame.origin.y += self.frame.size.height;
        self.frame = frame;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
