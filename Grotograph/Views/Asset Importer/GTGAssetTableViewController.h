
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Project.h"
#import "GTGAssetThumbnailView.h"
#import "MBProgressHUD.h"

@protocol GTGAssetTableViewControllerDelegate;


@interface GTGAssetTableViewController : UITableViewController <GTGAssetThumbnailViewDelegate, MBProgressHUDDelegate>

- (id)initWithPhotosOrAssets:(NSArray *)photosOrAssets withDelegate:(id <GTGAssetTableViewControllerDelegate>)delegate withTitleMessage:(NSString *)titleMessage;

- (GTGAssetTableViewController *)initWithAssetGroup:(ALAssetsGroup *)assetGroup withDelegate:(id <GTGAssetTableViewControllerDelegate>)delegate withTitleMessage:(NSString *)titleMessage showDates:(BOOL)showDates;

@property(nonatomic) BOOL enableMultipleSelection;
@property(strong) NSMutableDictionary *sectionsDictionary;

@end

@protocol GTGAssetTableViewControllerDelegate

- (void) gtgAssetTableViewControllerWillDisplayThumbnail:(GTGAssetThumbnailView *)thumbnail;
- (void) gtgAssetTableViewControllerDidFinishPickingMediaWithInfo:(NSArray *)selectedAssets
                                  withGTGAssetTableViewController:(GTGAssetTableViewController *)picker;

@end
