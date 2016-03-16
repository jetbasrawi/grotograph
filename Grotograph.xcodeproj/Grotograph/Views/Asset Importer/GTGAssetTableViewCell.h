
#import <UIKit/UIKit.h>

@protocol GTGAssetThumbnailViewDelegate;


@interface GTGAssetTableViewCell : UITableViewCell


-(id)initWithImageSources:(NSArray *)imageSources withThumbnailDelegate:(id <GTGAssetThumbnailViewDelegate>)thumbnailDelegate reuseIdentifier:(NSString *)identifier;
-(void)setImageSources:(NSArray *)imageSources;

@end
