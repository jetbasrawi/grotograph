

#import <UIKit/UIKit.h>
#import "Session.h"
#import "Photo.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@interface KeyFrameSelectionScrollItemView : UIViewController
{
    int pageNumber;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithPageNumber:(int)page andSession:(Session *)session andPhotos:(NSArray *)photos;

//- (IBAction)rotateImage;

@end
