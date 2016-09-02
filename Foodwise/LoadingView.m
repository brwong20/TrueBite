//
//  LoadingView.m
//  Foodwise
//
//  Created by Brian Wong on 8/30/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "LoadingView.h"
#import "UIFont+Extension.h"

@interface LoadingView()

@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UILabel *loadingLabel;

@end

@implementation LoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicator.color = [UIColor grayColor];
        self.indicator.center = CGPointMake(self.frame.size.width/4, self.frame.size.height/2.5);
        [self addSubview:self.indicator];
    
        self.loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.indicator.frame) + self.frame.size.width * 0.02, CGRectGetMidY(self.indicator.frame) - self.frame.size.height * 0.05, self.frame.size.width * 0.6, self.frame.size.height * 0.1)];
        self.loadingLabel.text = @"Loading restaurants...";
        self.loadingLabel.textColor = [UIColor lightGrayColor];
        self.loadingLabel.font = [UIFont fontWithSize:22.0];
        [self addSubview:self.loadingLabel];
        
        [self.indicator startAnimating];
        
    }
    
    return self;
}

@end
