//
//  RestaurantInfoTableViewCell.m
//  Foodwise
//
//  Created by Brian Wong on 8/28/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "RestaurantInfoTableViewCell.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"
#import "LayoutBounds.h"

@interface RestaurantInfoTableViewCell() <UITextViewDelegate>

@end

@implementation RestaurantInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self) {
        
        self.infoTitle = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 5.0, APPLICATION_FRAME.size.width * 0.3, 18.0)];
        self.infoTitle.text = @"Info";
        self.infoTitle.font = [UIFont semiboldFontWithSize:17.0];
        self.infoTitle.textColor = APPLICATION_FONT_COLOR;
        [self.contentView addSubview:self.infoTitle];
        
        self.phoneNumber = [[UITextView alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.infoTitle.frame) + 1.5, APPLICATION_FRAME.size.width * 0.7, 18.0)];
        self.phoneNumber.textColor = [UIColor lightGrayColor];
        self.phoneNumber.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
        self.phoneNumber.textAlignment = NSTextAlignmentLeft;
        self.phoneNumber.editable = NO;
        self.phoneNumber.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
        self.phoneNumber.font = [UIFont fontWithSize:16.0];
        self.phoneNumber.userInteractionEnabled = YES;
        self.phoneNumber.scrollEnabled = NO;
        [self.contentView addSubview:self.phoneNumber];
        
        self.addressTextView = [[UITextView alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.phoneNumber.frame) + 1.5, APPLICATION_FRAME.size.width * 0.7, 60.0)];
        self.addressTextView.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
        self.addressTextView.scrollEnabled = NO;
        self.addressTextView.userInteractionEnabled = NO;
        self.addressTextView.backgroundColor = [UIColor clearColor];
        self.addressTextView.textColor = [UIColor lightGrayColor];
        self.addressTextView.font = [UIFont fontWithSize:16.0];
        self.addressTextView.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.addressTextView];
        
        //[LayoutBounds drawBoundsForAllLayers:self];
    }
    return self;
}



@end
