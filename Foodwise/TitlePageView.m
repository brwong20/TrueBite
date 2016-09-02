//
//  TitlePageView.m
//  TrueBite
//
//  Created by Brian Wong on 8/31/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "TitlePageView.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

//Eventually put these into their own VCs/storyboard!!
@interface TitlePageView()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIButton *startButton;

@end

@implementation TitlePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
    
        self.logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2.75 - frame.size.width * 0.25, frame.size.height/2 - frame.size.height * 0.1, frame.size.width * 0.5, frame.size.height * 0.11)];
        self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.logoImageView setImage:[UIImage imageNamed:@"TrueBite_Big"]];
        self.logoImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.logoImageView];
        
        self.descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.logoImageView.frame), CGRectGetMaxY(self.logoImageView.frame), frame.size.width * 0.6, frame.size.height * 0.17)];
        self.descriptionTextView.font = [UIFont fontWithSize:18.0];
        self.descriptionTextView.textColor = UIColorFromRGB(0x7A95A7);
        self.descriptionTextView.backgroundColor = [UIColor clearColor];
        self.descriptionTextView.userInteractionEnabled = NO;
        self.descriptionTextView.editable = NO;
        self.descriptionTextView.text = @"A community of eaters helping you find tasty meals & save money.";
        [self addSubview:self.descriptionTextView];
        
        self.startButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.225, frame.size.height - frame.size.height * 0.12, frame.size.width * 0.45, frame.size.height * 0.07)];
        self.startButton.backgroundColor = APPLICATION_BLUE_COLOR;
        self.startButton.layer.cornerRadius = self.startButton.frame.size.height * 0.5;
        self.startButton.titleLabel.font = [UIFont semiboldFontWithSize:20.0];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.startButton addTarget:self action:@selector(startButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.startButton];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"com.truebite.onboarding.title"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    return self;
}

- (void)startButtonClicked
{
    [[FIRAuth auth]signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Anon sign in successful!");
            
            //Add user into db
            [[[[[FIRDatabase database]reference] child:@"users"]child:user.uid]
             setValue:@{@"anonymous":@(user.anonymous)}];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"com.truebite.onboarding.title"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            });
        }else{
            UIAlertController *signInAlert = [UIAlertController alertControllerWithTitle:@"Oops..." message:@"Although we don't require you to create an account, you need an internet connection to start using the app. Please check your connection and try again!" preferredStyle:UIAlertControllerStyleAlert];
            [signInAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [signInAlert dismissViewControllerAnimated:YES completion:nil];
            }]];
        }
    }];
}

@end
