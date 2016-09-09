//
//  ImageCollectionCell.m
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "ImageCollectionCell.h"

@implementation ImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = frame.size.height * 0.07;
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.475, frame.size.height/2 - frame.size.height * 0.475, frame.size.width * 0.95, frame.size.height * 0.95)];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.layer.cornerRadius = frame.size.height * 0.07;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.rasterizationScale = [[UIScreen mainScreen]scale];
        self.imageView.layer.shouldRasterize = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
    }
    
    return self;
}

@end
