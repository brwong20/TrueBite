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
        
        self.infoTitle = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 5.0, self.frame.size.width * 0.4, 18.0)];
        self.infoTitle.text = @"Address";
        self.infoTitle.font = [UIFont semiboldFontWithSize:17.0];
        self.infoTitle.textColor = APPLICATION_FONT_COLOR;
        [self.contentView addSubview:self.infoTitle];
        
        self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.infoTitle.frame), self.frame.size.width * 0.58, 60.0)];
        self.addressLabel.numberOfLines = 0;
        self.addressLabel.textColor = [UIColor lightGrayColor];
        self.addressLabel.font = [UIFont fontWithSize:16.0];
        [self.contentView addSubview:self.addressLabel];
        
        //Make phone call it's own cell
        self.phoneNumber = [[UITextView alloc]initWithFrame:CGRectMake(APPLICATION_FRAME.size.width - self.frame.size.width * 0.4, CGRectGetMinY(self.addressLabel.frame), self.frame.size.width * 0.4, 20.0)];
        self.phoneNumber.textContainerInset = UIEdgeInsetsZero;
        self.phoneNumber.textAlignment = NSTextAlignmentRight;
        self.phoneNumber.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
        self.phoneNumber.editable = NO;
        self.phoneNumber.font = [UIFont fontWithSize:16.0];
        self.phoneNumber.userInteractionEnabled = YES;
        self.phoneNumber.scrollEnabled = NO;
        [self.contentView addSubview:self.phoneNumber];
        
        //[LayoutBounds drawBoundsForAllLayers:self];
    }
    return self;
}

- (void)resizeToFitAddress:(NSString*)address
{
    self.addressLabel.text = address;
    [self.addressLabel sizeToFit];
    
    CGRect addressFrame = self.addressLabel.frame;
    addressFrame.origin.x = CGRectGetMinX(self.infoTitle.frame);
    addressFrame.origin.y = CGRectGetMaxY(self.infoTitle.frame) + 2.0;
    self.addressLabel.frame = addressFrame;
}

@end
