//
//  ImageUtils.m
//  Grotograph
//
//  Created by Jet Basrawi on 14/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import "ImageUtils.h"

/** Degrees to Radian **/
#define radians( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define degrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )


@implementation ImageUtils

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{  
    CGSize imageSize = sourceImage.size;
    
    //If the image was taken in portrait orientation the height and the width should switch becasue
    //at this point the image is in landscape orientation
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if ((sourceImage.imageOrientation == UIImageOrientationRight) || (sourceImage.imageOrientation == UIImageOrientationLeft)) {
        width = imageSize.height;
        height = imageSize.width;
    }    
        
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;

    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        } else {
            scaleFactor = heightFactor; // scale to fit width
        }        
    } 
    return [ImageUtils scaleImage:sourceImage scaleFactor:scaleFactor];     
}

+ (UIImage *) scaleImage: (UIImage *)image scaleFactor:(float)scaleBy
{
    CGSize size = CGSizeMake(image.size.width * scaleBy, image.size.height * scaleBy);
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformScale(transform, scaleBy, scaleBy);
    CGContextConcatCTM(context, transform);
    
    // Draw the image into the transformed context and return the image
    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;  
}

@end
