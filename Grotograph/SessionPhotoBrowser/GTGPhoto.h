//
//  GTGPhoto.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>

// Class
@class GTGPhoto;

// Delegate
@protocol MWPhotoDelegate <NSObject>
- (void)photoDidFinishLoading:(GTGPhoto *)photo;
- (void)photoDidFailToLoad:(GTGPhoto *)photo;
@end

// MWPhoto
@interface GTGPhoto : NSObject {
	
	// Image
	NSString *photoPath;
	NSURL *photoURL;
	UIImage *photoImage;
	
	// Flags
	BOOL workingInBackground;
	
}

// Class
+ (GTGPhoto *)photoWithImage:(UIImage *)image;
+ (GTGPhoto *)photoWithFilePath:(NSString *)path;
+ (GTGPhoto *)photoWithURL:(NSURL *)url;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

// Public methods
- (BOOL)isImageAvailable;
- (UIImage *)image;
- (UIImage *)obtainImage;
- (void)obtainImageInBackgroundAndNotify:(id <MWPhotoDelegate>)notifyDelegate;
- (void)releasePhoto;

@end
