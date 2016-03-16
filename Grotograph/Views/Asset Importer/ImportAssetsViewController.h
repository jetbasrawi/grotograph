
#import "MBProgressHUD.h"
#import "GTGAssetTableViewController.h"
#import "../GTGAssetsGroupTableViewController.h"

@class Project;

@protocol ImportAssetsViewControllerDelegate

- (void)importAssetsViewControllerDidFinish;

@end

@interface ImportAssetsViewController : UIViewController <GTGAssetTableViewControllerDelegate, MBProgressHUDDelegate, GTGAssetsGroupTableViewControllerDelegate>

- (id)initWithProject:(Project *)project withDelegate:(id <ImportAssetsViewControllerDelegate>)delegate;

@end


