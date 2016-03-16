//
//  Created by jet_basrawi on 22/12/2011.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "GTGAsset.h"
#import "Asset.h"
#import "AssetTransformation.h"


@implementation GTGAsset {

    BOOL _workingInBackground;

@private
    UIImage *_image;
    Asset *_cdAsset;
}

@synthesize cdAsset = _cdAsset;

- (id)initWithAsset:(Asset *)asset {

    if ((self = [self init])) {
         _cdAsset = asset;
    }
    return self;
}

- (void)dealloc {
    NSLog(@" - - < dealloc GTPhoto");
}

- (UIImage *)image {
    return _image;
}

- (BOOL)imageIsLoaded {
    return _image != nil;
}

- (void)loadAsynchronousThenNotify:(id <GTGAssetDelegate>)notifyDelegate {
    if (_workingInBackground == YES) return; //already fetching

    //NSLog(@"obtainImageInBackGround %@", imagePath);

    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *myAsset) {
        UIImage *img = [UIImage imageWithCGImage:[[myAsset defaultRepresentation] fullScreenImage]];
        if (img) {
            _image = img;
            [(NSObject *) notifyDelegate performSelectorOnMainThread:@selector(assetDidFinishLoading:) withObject:self waitUntilDone:NO];
            _workingInBackground = NO;
            //NSLog(@"Image loaded %@", imagePath);
        }
    };

    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *myError) {
        NSLog(@"Cant get image - %@", [myError localizedDescription]);
        [(NSObject *) notifyDelegate performSelectorOnMainThread:@selector(photoDidFailToLoad:) withObject:self waitUntilDone:NO];
        _workingInBackground = NO;
    };

    NSURL *assetURL = [NSURL URLWithString:_cdAsset.url];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:assetURL
                   resultBlock:resultBlock
                  failureBlock:failureBlock];

}

- (void)unload {
    _image = nil;
}

+ (GTGAsset *)gtgAssetWithAsset:(Asset *)asset {
    return [[self alloc] initWithAsset:asset];
}
@end