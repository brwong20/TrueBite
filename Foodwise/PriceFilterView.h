//
//  PriceFilterView.h
//  TrueBite
//
//  Created by Brian Wong on 9/5/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PriceFilterDelegate <NSObject>

@required 
- (void)didStartPickingPrice;
- (void)didEndPickingPrice;


@end

@interface PriceFilterView : UIView

@property (nonatomic, strong) NSNumber *currentPrice;
@property (weak, nonatomic) id<PriceFilterDelegate>delegate;

- (void)prepareFilterForRender;

@end
