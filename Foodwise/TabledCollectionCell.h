//
//  PhotoCollectionCell.h
//  TrueBite
//
//  Created by Brian Wong on 9/6/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IndexedPhotoCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *collectionCellIdentifier = @"photoCollectionCell";

@interface TabledCollectionCell : UITableViewCell

@property (nonatomic, strong) IndexedPhotoCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end
