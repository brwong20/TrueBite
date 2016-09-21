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
        UIView *starBackground = [[UIView alloc]initWithFrame:CGRectMake(xPoint, 0, self.ratingContainer.frame.size.width/5, self.ratingContainer.frame.size.height)];
        starBackground.backgroundColor = UIColorFromRGB(0xDCDBDC);
        [self.ratingContainer addSubview:starBackground];
        
        UIImageView *fullStar = [[UIImageView alloc]initWithFrame:CGRectMake(starBackground.frame.size.width/2 - starBackground.frame.size.width * 0.4, starBackground.frame.size.height/2 - starBackground.frame.size.height * 0.4, starBackground.frame.size.width * 0.8, starBackground.frame.size.height * 0.8)];
        fullStar.contentMode = UIViewContentModeScaleAspectFit;
        fullStar.backgroundColor = [UIColor clearColor];
        [fullStar setImage:[UIImage imageNamed:@"star_full"]];
        [starBackground addSubview:fullStar];
        
        xPoint += self.ratingContainer.frame.size.width/4.75;
    }
    
    //Add half star first since there can only be one, then fill the rest with empty stars - We round all ratings UP (i.e 7.5 = 8 = 4 stars)
    if (halfStar == 1) {
        UIView *starBackground = [[UIView alloc]initWithFrame:CGRectMake(xPoint, 0, self.ratingContainer.frame.size.width/5, self.ratingContainer.frame.size.height)];
        starBackground.backgroundColor = UIColorFromRGB(0xDCDBDC);
        [self.ratingContainer addSubview:starBackground];
        
        UIImageView *halfStar = [[UIImageView alloc]initWithFrame:CGRectMake(starBackground.frame.size.width/2 - starBackground.frame.size.width * 0.4, starBackground.frame.size.height/2 - starBackground.frame.size.height * 0.4, starBackground.frame.size.width * 0.8, starBackground.frame.size.height * 0.8)];
        halfStar.contentMode = UIViewContentModeScaleAspectFit;
        halfStar.backgroundColor = [UIColor clearColor];
        
        //If rating is X.5, round up by giving it a full star :)
        if (decimal >= 0.5) {
            [halfStar setImage:[UIImage imageNamed:@"star_full"]];
        }else{
            [halfStar setImage:[UIImage imageNamed:@"star_half"]];
        }
        [starBackground addSubview:halfStar];
        
        xPoint += self.ratingContainer.frame.size.width/4.75; //Right after the last full star!
    }
    
    NSInteger starsLeft = MAX_STARS - (fullStars + halfStar);
    
    //Empty stars
    for (int j = 0; j < starsLeft; j++) {
        UIView *starBackground = [[UIView alloc]initWithFrame:CGRectMake(xPoint, 0, self.ratingContainer.frame.size.width/5, self.ratingContainer.frame.size.height)];
        starBackground.backgroundColor = UIColorFromRGB(0xDCDBDC);
        [self.ratingContainer addSubview:starBackground];
        
        UIImageView *emptyStar =  [[UIImageView alloc]initWithFrame:CGRectMake(starBackground.frame.size.width/2 - starBackground.frame.size.width * 0.4, starBackground.frame.size.height/2 - starBackground.frame.size.height * 0.4, starBackground.frame.size.width * 0.8, starBackground.frame.size.height * 0.8)];
        emptyStar.contentMode = UIViewContentModeScaleAspectFit;
        emptyStar.backgroundColor = [UIColor clearColor];
        [emptyStar setImage:[UIImage imageNamed:@"star_empty"]];
        [starBackground addSubview:emptyStar];
        
        xPoint += self.ratingContainer.frame.size.width/4.75;
    }
    
    //[LayoutBounds drawBoundsForAllLayers:self];
}

@end
