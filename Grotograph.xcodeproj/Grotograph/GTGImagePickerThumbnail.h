
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol GTGImagePickerThumbnailDelegate;

@interface GTGImagePickerThumbnail : UIView

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic) BOOL enabled;


- (id)initWithFrame:(CGRect)frame withDelegate:(id <GTGImagePickerThumbnailDelegate>)delegate;

- (void)displayWithAsset:(ALAsset *)asset;

- (void)displayWithImageSource:(id)imageSource;

- (void)displayWithURL:(NSURL *)url;


- (void)toggleSelection;
- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)selected;

- (void)unloadImage;


@end

@protocol GTGImagePickerThumbnailDelegate
-(void)thumbnailWillDisplay:(GTGImagePickerThumbnail *)thumbNail;
-(void)thumbnailDidToggleSelection:(GTGImagePickerThumbnail *)thumbNail;
@end
