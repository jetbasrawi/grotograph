
#import <Foundation/Foundation.h>

@class GTGAsset;
@class Asset;
@class AssetTransformation;

@protocol GTGAssetDelegate <NSObject>

-(void)assetDidFinishLoading:(GTGAsset *)asset;
-(void)photoDidFailToLoad:(GTGAsset *)asset;

@end

@interface GTGAsset : NSObject

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) Asset *cdAsset;

- (id)initWithAsset:(Asset *)asset;
- (BOOL)imageIsLoaded;

- (void)loadAsynchronousThenNotify:(id <GTGAssetDelegate>)notifyDelegate;
- (void)unload;


+ (GTGAsset *)gtgAssetWithAsset:(Asset *)asset;
@end