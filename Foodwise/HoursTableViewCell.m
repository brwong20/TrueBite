//
//  HoursTableViewCell.m
//  Foodwise
//
//  Created by Brian Wong on 8/28/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "HoursTableViewCell.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"

@implementation HoursTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self) {
        self.hoursTitle = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 4.0, self.frame.size.width * 0.5, 18.0)];
        self.hoursTitle.textColor = APPLICATION_FONT_COLOR;
        self.hoursTitle.text = @"Hours today";
        self.hoursTitle.font = [UIFont semiboldFontWithSize:17.0];
        [self.contentView addSubview:self.hoursTitle];
        
        self.openNow = [[UILabel alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - self.frame.size.width * 0.3, CGRectGetMidY(self.hoursTitle.frame) - 7.5, self.frame.size.width * 0.3, 15.0)];
        self.openNow.textColor = [UIColor grayColor];
        self.openNow.textAlignment = NSTextAlignmentCenter;
        self.openNow.font = [UIFont fontWithSize:14.0];
        [self.contentView addSubview:self.openNow];
        
        self.hoursLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.hoursTitle.frame) + 3.0, self.frame.size.width * 0.95, 18.0)]; //Set to max so if smaller, sizeToFit will handle it as well as heightForRow...
        self.hoursLabel.numberOfLines = 1;
        self.hoursLabel.textColor =[UIColor lightGrayColor];
        self.hoursLabel.font = [UIFont fontWithSize:16.0];
        [self.contentView addSubview:self.hoursLabel];

        //[LayoutBounds drawBoundsForAllLayers:self];
    }
    
    return self;
}

- (void)setTextWithFade:(NSString*)hours
{
    self.hoursLabel.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        self.hoursLabel.text = hours;
        self.hoursLabel.alpha = 1.0;
    }];
}

//Hours can be as simple as M-S or complicated like M-F, S-S, etc.. so we'll resize the hoursLabel here to account for that
- (void)resizeToFitHours:(NSString*)hours
{
    self.hoursLabel.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        self.hoursLabel.text = hours;
        
        [self.hoursLabel sizeToFit];
        
        CGRect hourFrame = self.hoursLabel.frame;
        hourFrame.origin.x = CGRectGetMinX(self.hoursTitle.frame);
        hourFrame.origin.y = CGRectGetMaxY(self.hoursTitle.frame) + 3.0;
        self.hoursLabel.frame = hourFrame;
        
        self.hoursLabel.alpha = 1.0;
    }];
}

@end
