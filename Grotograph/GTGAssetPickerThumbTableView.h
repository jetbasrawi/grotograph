
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Project.h"
#import "GTGImagePickerThumbnail.h"
#import "MBProgressHUD.h"

@protocol GTGImagePickerControllerDelegate;

@interface GTGAssetPickerThumbTableView : UITableViewController <GTGImagePickerThumbnailDelegate, MBProgressHUDDelegate>

- (id)initWithPhotosOrAssets:(NSArray *)photosOrAssets withDelegate:(id <GTGImagePickerControllerDelegate>)delegate withTitleMessage:(NSString *)titleMessage;

- (GTGAssetPickerThumbTableView *)initWithAssetGroup:(ALAssetsGroup *)assetGroup withDelegate:(id <GTGImagePickerControllerDelegate>)delegate withTitleMessage:(NSString *)titleMessage showDates:(BOOL)showDates;

@property(nonatomic) BOOL enableMultipleSelection;
@property(strong) NSMutableDictionary *sectionsDictionary;

@end