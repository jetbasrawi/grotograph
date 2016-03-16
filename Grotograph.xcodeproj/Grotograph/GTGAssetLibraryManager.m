//
//  Created by jet_basrawi on 01/01/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "GTGAssetLibraryManager.h"


@implementation GTGAssetLibraryManager {

}



+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t predicate = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&predicate, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

@end