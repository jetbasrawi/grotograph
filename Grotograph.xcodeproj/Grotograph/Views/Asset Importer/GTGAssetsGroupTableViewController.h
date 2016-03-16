
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Project.h"

@class GTGAssetsGroup;

@protocol GTGAssetsGroupTableViewControllerDelegate

   -(void)gtgAssetsGroupTableVIewControllerDidSelectRowWithAssetGroup:(GTGAssetsGroup *)assetGroup;
   -(void)gtgAssetGroupTableViewControllerDidCancel;

@end

@interface GTGAssetsGroupTableViewController : UITableViewController

- (id)initWithDelegate:(id <GTGAssetsGroupTableViewControllerDelegate>)_delegate;

- (void)display:(NSArray *)assetGroups;
@end

