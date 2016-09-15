//
//  UIImage+ResizeHelper.m
//  Joyspace
//
//  Created by Andreas Lengyel on 10/12/15.
//  Copyright © 2015 Taplet Inc. All rights reserved.
//

#import "UIImage+ResizeHelper.h"

@implementation UIImage (ResizeHelper)

- (NSData *)thumbnailScaleFromImage:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(320)
                                                           };
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    CFRelease(src);
    
    UIImage *newimage = [UIImage imageWithCGImage:thumbnail];
    CFRelease(thumbnail);
    
    NSData *thumbImageData = UIImageJPEGRepresentation(newimage, 0.5);
    
    return thumbImageData;
}

- (NSData *)displayScaleFromImageData:(NSData *)imageData
{
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(150)
                                                           };

    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    
    /* Need to convert back to UIImage to get the correct data format to upload to server */
    UIImage *resizedImage = [UIImage imageWithCGImage:thumbnail];
    NSData *resizedImageData = UIImageJPEGRepresentation(resizedImage, 0.90);
    
    NSLog(@"Image Size: %@",[NSByteCountFormatter stringFromByteCount:resizedImageData.length countStyle:NSByteCountFormatterCountStyleFile]);
    
    
    CFRelease(src);
    CFRelease(thumbnail);
    
    return resizedImageData;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
