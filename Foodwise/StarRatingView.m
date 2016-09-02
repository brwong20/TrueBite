//
//  StarRatingView.m
//  Foodwise
//
//  Created by Brian Wong on 8/30/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "StarRatingView.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"

@interface StarRatingView()

@property (strong, nonatomic) UIView *ratingContainer;

@end

@implementation StarRatingView

static int MAX_STARS = 5;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.ratingContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.ratingContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:self.ratingContainer];
        
    }
    
    return self;
}

//Converts 10-scale rating to 5-scale stars
- (void)convertNumberToStars:(NSNumber *)rating
{
    //Increment to position properly in container
    CGFloat xPoint = 0.0;
 
    //Divide rating by 2 to get number of stars
    NSInteger intNumber = rating.doubleValue;
    
    //Round all dec UP!
    NSInteger fullStars = intNumber/2;
    int halfStar = intNumber % 2;
    double decimal = rating.doubleValue - intNumber;
    
    //Start by filling the full stars first
    for (int i = 0; i < fullStars; i++) {
        UIImageView *fullStar = [[UIImageView alloc]initWithFrame:CGRectMake(xPoint, self.ratingContainer.frame.size.height/2 - self.ratingContainer.frame.size.height * 0.475, self.ratingContainer.frame.size.width/5.25, self.ratingContainer.frame.size.height * 0.97)];
        fullStar.contentMode = UIViewContentModeScaleAspectFit;
        fullStar.backgroundColor = UIColorFromRGB(0xDCDBDC);
        [fullStar setImage:[UIImage imageNamed:@"star_full"]];
        [self.ratingContainer addSubview:fullStar];
        
        xPoint += self.ratingContainer.frame.size.width/5;
    }
    
    //Add half star first since there can only be one, then fill the rest with empty stars - We round all ratings UP (i.e 7.5 = 8 = 4 stars)
    if (halfStar == 1) {
        UIImageView *halfStar = [[UIImageView alloc]initWithFrame:CGRectMake(xPoint, self.ratingContainer.frame.size.height/2 - self.ratingContainer.frame.size.height * 0.475, self.ratingContainer.frame.size.width/5.25, self.ratingContainer.frame.size.height * 0.97)];
        halfStar.contentMode = UIViewContentModeScaleAspectFit;
        halfStar.backgroundColor = UIColorFromRGB(0xDCDBDC);
        
        //If rating is X.5, round up by giving it a full star :)
        if (decimal >= 0.5) {
            [halfStar setImage:[UIImage imageNamed:@"star_full"]];
        }else{
            [halfStar setImage:[UIImage imageNamed:@"star_half"]];
        }
        [self.ratingContainer addSubview:halfStar];
        
        xPoint += (self.ratingContainer.frame.size.width/5);//Right after the last full star!
    }
    
    NSInteger starsLeft = MAX_STARS - (fullStars + halfStar);
    
    //Empty stars
    for (int j = 0; j < starsLeft; j++) {
        UIImageView *emptyStar = [[UIImageView alloc]initWithFrame:CGRectMake(xPoint, self.ratingContainer.frame.size.height/2 - self.ratingContainer.frame.size.height * 0.475, self.ratingContainer.frame.size.width/5.25, self.ratingContainer.frame.size.height * 0.97)];
        emptyStar.contentMode = UIViewContentModeScaleAspectFit;
        emptyStar.backgroundColor = UIColorFromRGB(0xDCDBDC);
        [emptyStar setImage:[UIImage imageNamed:@"star_empty"]];
        [self.ratingContainer addSubview:emptyStar];
        
        xPoint += self.ratingContainer.frame.size.width/5;
    }
    
    
}

@end
