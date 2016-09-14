//
//  UIImage+ResizeHelper.h
//  Joyspace
//
//  Created by Andreas Lengyel on 10/12/15.
//  Copyright © 2015 Taplet Inc. All rights reserved.
//

@import UIKit;
@import ImageIO;

@interface UIImage (ResizeHelper)

- (NSData *)thumbnailScaleFromImage:(UIImage *)image;
- (NSData *)displayScaleFromImageData:(NSData *)imageData;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;

@end
