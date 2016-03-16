//
//  Created by jet_basrawi on 15/01/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface GTGAssetsGroup : NSObject
@property(nonatomic, strong) NSString * name;
@property(nonatomic) NSInteger numberOfAssets;
@property(nonatomic, retain) UIImage *posterImage;
@property(nonatomic, retain) ALAssetsGroup *assetGroup;

@end