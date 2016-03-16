
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Project.h"

@protocol GTGImagePickerControllerDelegate;

@interface GTGAlbumPickerController : UITableViewController

@property(nonatomic, assign) id <GTGImagePickerControllerDelegate> imagePickerControllerDelegate;

@end

