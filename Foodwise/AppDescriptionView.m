//
//  AppDescriptionView.m
//  TrueBite
//
//  Created by Brian Wong on 8/31/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "AppDescriptionView.h"
#import "FoodwiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

@interface AppDescriptionView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIImageView *bowlImageView;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *okButton;

@end

@implementation AppDescriptionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.35 , frame.size.height * 0.2, frame.size.width * 0.7, frame.size.height * 0.12)];
        self.titleLabel.textColor = APPLICATION_FONT_COLOR;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont mediumFontWithSize:22.0];
        self.titleLabel.text = @"A community focused on smart dining";
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        self.descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame), frame.size.width * 0.7, frame.size.height * 0.3)];
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
        self.descriptionTextView.font = [UIFont fontWithSize:18.0];
        self.descriptionTextView.text = @"Report meal costs to improve spending for all. Know what you'll pay before eating!\n\nPrices include tax and tip.";
        self.descriptionTextView.backgroundColor = [UIColor clearColor];
        self.descriptionTextView.userInteractionEnabled = NO;
        self.descriptionTextView.editable = NO;
        self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
        [self addSubview:self.descriptionTextView];
        
        self.bowlImageView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.125, frame.size.height * 0.75 - frame.size.width * 0.2, frame.size.width * 0.25, frame.size.width * 0.3)];
        [self.bowlImageView setImage:[UIImage imageNamed:@"soup"]];
        self.bowlImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bowlImageView];
        
        self.okButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.225, frame.size.height - frame.size.height * 0.12, frame.size.width * 0.45, frame.size.height * 0.07)];
        self.okButton.backgroundColor = APPLICATION_BLUE_COLOR;
        self.okButton.layer.cornerRadius = self.okButton.frame.size.height * 0.5;
        self.okButton.titleLabel.font = [UIFont semiboldFontWithSize:20.0];
        [self.okButton setTitle:@"Let's eat" forState:UIControlStateNormal];
        [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.okButton addTarget:self action:@selector(okButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.okButton];
    }
    
    return self;
    
}

- (void)okButtonClicked
{
    [self removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"com.truebite.onboarding.detail"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
