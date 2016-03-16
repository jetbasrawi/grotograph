
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol GTGAssetThumbnailViewDelegate;

@interface GTGAssetThumbnailView : UIView

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic) BOOL enabled;


- (id)initWithFrame:(CGRect)frame withDelegate:(id <GTGAssetThumbnailViewDelegate>)delegate;

- (void)displayWithAsset:(ALAsset *)asset;

- (void)displayWithImageSource:(id)imageSource;

- (void)displayWithURL:(NSURL *)url;


- (void)toggleSelection;
- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)selected;

- (void)unloadImage;


@end

@protocol GTGAssetThumbnailViewDelegate
-(void)thumbnailWillDisplay:(GTGAssetThumbnailView *)thumbNail;
-(void)thumbnailDidToggleSelection:(GTGAssetThumbnailView *)thumbNail;
@end
