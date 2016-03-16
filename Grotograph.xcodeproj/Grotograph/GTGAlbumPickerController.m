#import "GTGAlbumPickerController.h"
#import "GTGAssetPickerThumbTableView.h"
#import "GTGImagePickerController.h"

#define ALBUM_ROW_HEIGHT 57

@implementation GTGAlbumPickerController {

    NSMutableArray *_assetGroups;
    ALAssetsLibrary *_library;
@private
    __unsafe_unretained id <GTGImagePickerControllerDelegate> _imagePickerControllerDelegate;
    GTGAssetPickerThumbTableView *_picker;
}

#pragma mark -
#pragma mark View lifecycle


@synthesize imagePickerControllerDelegate = _imagePickerControllerDelegate;

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.navigationItem setTitle:@"Loading..."];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                 target:self.imagePickerControllerDelegate
                                 action:@selector(gtgImagePickerControllerDidCancel)];

    [self.navigationItem setRightBarButtonItem:cancelButton];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    _assetGroups = tempArray;

    _library = [[ALAssetsLibrary alloc] init];

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {

            // Group enumerator Block
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group == nil) {
                    return;
                }

                [_assetGroups addObject:group];

                // Reload albums
                [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
            };

            // Group Enumerator Failure Block
            void (^assetGroupEnumeratorFailure)(NSError *) = ^(NSError *error) {

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];

                NSLog(@"A problem occured %@", [error description]);
            };

            // Enumerate Albums
            [_library enumerateGroupsWithTypes:ALAssetsGroupAll
                                    usingBlock:assetGroupEnumerator
                                  failureBlock:assetGroupEnumeratorFailure];
        }
    });
}

- (void)reloadTableView {

    [self.tableView reloadData];
    [self.navigationItem setTitle:@"Source"];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_assetGroups count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"AssetCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Get count
    ALAssetsGroup *g = (ALAssetsGroup *) [_assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [g valueForProperty:ALAssetsGroupPropertyURL], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *) [_assetGroups objectAtIndex:indexPath.row] posterImage]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

        ALAssetsGroup *assetGroup = [_assetGroups objectAtIndex:indexPath.row];
        [assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];

        _picker = [[GTGAssetPickerThumbTableView alloc] initWithAssetGroup:assetGroup withDelegate:self.imagePickerControllerDelegate withTitleMessage:@"Pick Photos" showDates:YES];

    

    [self.navigationController pushViewController:_picker animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return ALBUM_ROW_HEIGHT;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

