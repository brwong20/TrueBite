//
//  HoursTableViewCell.h
//  Foodwise
//
//  Created by Brian Wong on 8/28/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HoursTableViewCell : UITableViewCell

@property (strong, nonatomic)UILabel *openNow;
@property (strong, nonatomic)UILabel *hoursTitle;
@property (strong, nonatomic)UILabel *hoursLabel;

- (void)resizeToFitHours:(NSString*)hours;
- (void)setTextWithFade:(NSString*)hours;

@end
