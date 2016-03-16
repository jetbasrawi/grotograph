//
//  ImageUtils.h
//  Grotograph
//
//  Created by Jet Basrawi on 14/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIImage*) imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
+ (UIImage *) scaleImage: (UIImage *)image scaleFactor:(float)scaleBy;

@end
