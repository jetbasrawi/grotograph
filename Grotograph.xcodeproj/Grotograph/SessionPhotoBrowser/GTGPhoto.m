//
//  GTGPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "GTGPhoto.h"
#import "UIImage+Decompress.h"

// Private
@interface GTGPhoto ()

// Properties
@property(strong) UIImage *photoImage;
@property() BOOL workingInBackground;

// Private Methods
- (void)doBackgroundWork:(id <MWPhotoDelegate>)delegate;

@end


// MWPhoto
@implementation GTGPhoto

// Properties
@synthesize photoImage, workingInBackground;

#pragma mark Class Methods

+ (GTGPhoto *)photoWithImage:(UIImage *)image {
    return [[GTGPhoto alloc] initWithImage:image];
}

+ (GTGPhoto *)photoWithFilePath:(NSString *)path {
    return [[GTGPhoto alloc] initWithFilePath:path];
}

+ (GTGPhoto *)photoWithURL:(NSURL *)url {
    return [[GTGPhoto alloc] initWithURL:url];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.photoImage = image;
    }
    return self;
}

- (id)initWithFilePath:(NSString *)path {
    if ((self = [super init])) {
        photoPath = [path copy];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        photoURL = [url copy];
    }
    return self;
}


#pragma mark Photo

// Return whether the image available
// It is available if the UIImage has been loaded and
// loading from file or URL is not required
- (BOOL)isImageAvailable {
    return (self.photoImage != nil);
}

// Return image
- (UIImage *)image {
    return self.photoImage;
}

// Get and return the image from existing image, file path or url
- (UIImage *)obtainImage {
    if (!self.photoImage) {

        // Load
        UIImage *img = nil;
        if (photoPath) {

            // Read image from file
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfFile:photoPath options:NSDataReadingUncached error:&error];
            if (!error) {
                img = [[UIImage alloc] initWithData:data];
            } else {
                NSLog(@"Photo from file error: %@", error);
            }

        } else if (photoURL) {

            // Read image from URL and return
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:photoURL];
            NSError *error = nil;
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (data) {
                img = [[UIImage alloc] initWithData:data];
            } else {
                NSLog(@"Photo from URL error: %@", error);
            }

        }

        // Force the loading and caching of raw image data for speed
        [img decompress];

        // Store
        self.photoImage = img;

    }
    return self.photoImage;
}

// Release if we can get it again from path or url
- (void)releasePhoto {
    if (self.photoImage && (photoPath || photoURL)) {
        self.photoImage = nil;
    }
}

// Obtain image in background and notify the browser when it has loaded
- (void)obtainImageInBackgroundAndNotify:(id <MWPhotoDelegate>)delegate {

//    if (self.workingInBackground == YES) return; // Already fetching
//    self.workingInBackground = YES;
//    //[self performSelectorInBackground:@selector(doBackgroundWork:) withObject:delegate];
//
//    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *myAsset) {
//        UIImage *img = [UIImage imageWithCGImage:[[myAsset defaultRepresentation] fullScreenImage]];
//        if (img) {
//            self.photoImage = img;
//            [(NSObject *) delegate performSelectorOnMainThread:@selector(photoDidFinishLoading:) withObject:self waitUntilDone:NO];
//            self.workingInBackground = NO;
//        }
//    };
//
//
//    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *myError) {
//        NSLog(@"Cant get image - %@", [myError localizedDescription]);
//
//        //sleep(1);
//        NSLog(@"Failed to load photo");
//        //imgToReturn = [self loadThumb:imageURL withNumberOfAttemptsToLoadImageSoFar:numberOfAttempts + 1];
//
//        [(NSObject *) delegate performSelectorOnMainThread:@selector(photoDidFailToLoad:) withObject:self waitUntilDone:NO];
//        self.workingInBackground = NO;
//    };
//
//    if (photoPath && [photoPath length] && ![[photoPath pathExtension] isEqualToString:@"someextensionwedontwant"]) {
//        NSURL *assetURL = [NSURL URLWithString:photoPath];
//        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//        [assetsLibrary assetForURL:assetURL
//                       resultBlock:resultBlock
//                      failureBlock:failureBlock];
//    }
    //[(NSObject *) delegate performSelectorOnMainThread:@selector(photoDidFinishLoading:) withObject:self waitUntilDone:NO];
   // self.workingInBackground = NO;

}

// Run on background thread
// Download image and notify delegate
- (void)doBackgroundWork:(id <MWPhotoDelegate>)delegate {
//    @autoreleasepool {
//
//        // Load image
//        UIImage *img = [self obtainImage];
//
//        // Notify delegate of success or fail
//        if (img) {
//            [(NSObject *) delegate performSelectorOnMainThread:@selector(photoDidFinishLoading:) withObject:self waitUntilDone:NO];
//        } else {
//            [(NSObject *) delegate performSelectorOnMainThread:@selector(photoDidFailToLoad:) withObject:self waitUntilDone:NO];
//        }
//
//        // Finish
//        self.workingInBackground = NO;
//
//    }
}

@end
