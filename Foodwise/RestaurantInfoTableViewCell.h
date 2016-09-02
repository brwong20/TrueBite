//
//  RestaurantInfoTableViewCell.h
//  Foodwise
//
//  Created by Brian Wong on 8/28/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantInfoTableViewCell : UITableViewCell

@property (strong, nonatomic)UILabel *infoTitle;
@property (strong, nonatomic)UILabel *addressLabel;
@property (strong, nonatomic)UITextView *phoneNumber;

- (void)resizeToFitAddress:(NSString*)address;

@end
