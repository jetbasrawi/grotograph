#import "GTGAssetsGroupTableViewController.h"
#import "GTGAssetTableViewController.h"
#import "GTGAssetsGroup.h"
#import "AssetGroup.h"

#define ALBUM_ROW_HEIGHT 57

@implementation GTGAssetsGroupTableViewController {

    NSArray *_assetGroups;
    ALAssetsLibrary *_library;
@private
    __unsafe_unretained id <GTGAssetsGroupTableViewControllerDelegate> __delegate;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark -
#pragma mark View lifecycle

- (id)initWithDelegate:(id <GTGAssetsGroupTableViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        __delegate = delegate;
        self.wantsFullScreenLayout = YES;
    }

    return self;
//To change the template use AppCode | Preferences | File Templates.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Loading..."];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];  //To change the template use AppCode | Preferences | File Templates.


}


- (void) display:(NSArray *)assetGroups {

    //TODO: call main queue and do this on main thread in case it is called from a worker thread
    _assetGroups = assetGroups;

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
//    ALAssetsGroup *g = (ALAssetsGroup *) [_assetGroups objectAtIndex:indexPath.row];
//    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
//    NSInteger gCount = [g numberOfAssets];
    //[g valueForProperty:ALAssetsGroupPropertyName]
    //[UIImage imageWithCGImage:[(ALAssetsGroup *) [_assetGroups objectAtIndex:indexPath.row] posterImage]]

    GTGAssetsGroup *assetGroup = [_assetGroups objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", assetGroup.name, assetGroup.numberOfAssets];
    [cell.imageView setImage:assetGroup.posterImage];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    ALAssetsGroup *assetGroup = [_assetGroups objectAtIndex:indexPath.row];
//    [assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
//
//    _picker = [[GTGAssetTableViewController alloc]
//            initWithAssetGroup:assetGroup
//                  withDelegate:self.imagePickerControllerDelegate
//              withTitleMessage:@"Pick Photos"
//                     showDates:YES];
//
//    [self.navigationController pushViewController:_picker animated:YES];
//
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    GTGAssetsGroup *assetGroup = [_assetGroups objectAtIndex:indexPath.row];
    [__delegate gtgAssetsGroupTableVIewControllerDidSelectRowWithAssetGroup:assetGroup];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return ALBUM_ROW_HEIGHT;
}


#pragma mark - Command handlers

- (void) doneButtonClicked {
    [__delegate gtgAssetGroupTableViewControllerDidCancel];
}


@end

