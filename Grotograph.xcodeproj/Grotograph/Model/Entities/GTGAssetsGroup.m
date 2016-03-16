//
//  Created by jet_basrawi on 15/01/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GTGAssetsGroup.h"


@implementation GTGAssetsGroup {

@private
    ALAssetsGroup *_assetGroup;
    UIImage *_posterImage;
    NSInteger _numberOfAssets;
    NSString *_name;
}

@synthesize assetGroup = _assetGroup;
@synthesize posterImage = _posterImage;
@synthesize numberOfAssets = _numberOfAssets;
@synthesize name = _name;


- (NSString *)name {
    return [_assetGroup valueForProperty:ALAssetsGroupPropertyName];
}

- (NSInteger)numberOfAssets {
    return [_assetGroup numberOfAssets];
}

- (UIImage *)posterImage {
    return [UIImage imageWithCGImage:[_assetGroup posterImage]];
}

@end