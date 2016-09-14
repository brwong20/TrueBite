//
//  AddPhotoCollectionViewcell.m
//  TrueBite
//
//  Created by Brian Wong on 9/14/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "AddPhotoCollectionViewCell.h"
#import "UIFont+Extension.h"
#import "FoodwiseDefines.h"

@implementation AddPhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *plus = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, 50, 50)];
        plus.text = @"+";
        plus.font = [UIFont fontWithSize:45.0];
        plus.textColor = APPLICATION_FONT_COLOR;
        plus.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:plus];
        
        UILabel *addLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 60, 90, 25)];
        addLabel.text = @"Add photo";
        addLabel.textColor = APPLICATION_FONT_COLOR;
        addLabel.textAlignment = NSTextAlignmentCenter;
        addLabel.font = [UIFont mediumFontWithSize:15.0];
        addLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:addLabel];
    }
    
    return self;
}

@end
