#import "GTGAssetTableViewCell.h"
#import "GTGAssetThumbnailView.h"
#import "GTGAssetTableViewController.h"
#import "NSDate+Utils.h"

@interface GTGAssetTableViewController ()

//- (void)importImages:(NSArray *)assets;

- (NSArray *)getAllKeysSorted;

- (void)doneAction:(id)sender;

- (NSArray *)arrayForSection:(NSInteger)section;


@end

@implementation GTGAssetTableViewController {

    NSMutableArray *_imageSources;
    __unsafe_unretained id <GTGAssetTableViewControllerDelegate> __delegate;
    NSMutableSet *_selectedThumbnails;
    NSString *_titleMessage;
    ALAssetsGroup *_assetsGroup;
    BOOL _showDates;
    NSMutableDictionary *_sectionsDictionary;
    NSUInteger _assetsLoadedCount;
    NSUInteger _assetsEnumeratedCount;
    MBProgressHUD *_hud;
    BOOL _dataLoaded;
    NSArray *_allKeysSorted;
    
}

@synthesize enableMultipleSelection = _enableMultipleSelection;
@synthesize sectionsDictionary = _sectionsDictionary;


- (id)initWithPhotosOrAssets:(NSArray *)photosOrAssets
                withDelegate:(id <GTGAssetTableViewControllerDelegate>)delegate
            withTitleMessage:(NSString *)titleMessage {

    if ((self = [self initWithNibName:@"GTGAssetPickerThumbTableView" bundle:[NSBundle mainBundle]])) {

        _sectionsDictionary = [[NSMutableDictionary alloc] init];
        [_sectionsDictionary setValue:[NSMutableArray arrayWithArray:photosOrAssets] forKey:0];

        __delegate = delegate;
        _titleMessage = titleMessage;
        _enableMultipleSelection = YES;

        _selectedThumbnails = [NSMutableSet setWithCapacity:[[_sectionsDictionary valueForKey:0] count]];
    }
    return self;
}

- (GTGAssetTableViewController *)initWithAssetGroup:(ALAssetsGroup *)assetGroup
                                        withDelegate:(id <GTGAssetTableViewControllerDelegate>)delegate
                                    withTitleMessage:(NSString *)titleMessage
                                           showDates:(BOOL)showDates {

    if ((self = [self initWithNibName:@"GTGAssetPickerThumbTableView" bundle:[NSBundle mainBundle]])) {

        _sectionsDictionary = [[NSMutableDictionary alloc] init];
        _showDates = showDates;
        _assetsGroup = assetGroup;
        __delegate = delegate;
        _titleMessage = titleMessage;
        _enableMultipleSelection = YES;
        _selectedThumbnails = [NSMutableSet setWithCapacity:(NSUInteger) [assetGroup numberOfAssets]];
    }

    return self;

}

- (NSArray *)getAllKeysSorted {
    if (!_allKeysSorted)
    {
        NSArray *array = [[self.sectionsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        if (_dataLoaded)
        {
            _allKeysSorted = array;
            return _allKeysSorted;
        }
        else
        {
            return array;
        }
    }
    else
    {
        return _allKeysSorted;    
    }
}

- (void)dataDidLoad {

    if (_dataLoaded)
        return;

    NSLog(@"Data did load %d", _assetsLoadedCount);

    _dataLoaded = YES;

    //if (_hud)
    //  [_hud hide:YES];

    [self.tableView reloadData];
}

- (void)loadData {

    @autoreleasepool {

        _assetsLoadedCount = 0;
        _assetsEnumeratedCount = 0;
        [_assetsGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {

            if (asset == nil) {
                _assetsEnumeratedCount++;
                return;
            }

            if (_showDates) {

                NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
                NSString *dateKey = [date getDateKey];

                //NSLog(@"dateKey = %@", dateKey);

                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL keyExists = NO;

                    if ([self.sectionsDictionary allKeys]) {
                        for (NSString *k in [self.sectionsDictionary allKeys]) {
                            if ([k isEqualToString:dateKey]) {
                                keyExists = YES;
                                break;
                            }
                        }
                    }

                    if (!keyExists) {
                        //Insert new pair
                        NSMutableArray *newArray = [[NSMutableArray alloc] initWithObjects:asset, nil];
                        [self.sectionsDictionary setValue:newArray forKey:dateKey];
                    }
                    else {
                        //Add asset to the existing array
                        [(NSMutableArray *) [self.sectionsDictionary objectForKey:dateKey] addObject:asset];
                    }

                    _assetsLoadedCount++;
                    //[self dataDidLoad];
                });
            }
            else {

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![self.sectionsDictionary allKeys]) {
                        [self.sectionsDictionary setValue:[[NSMutableArray alloc] arrayByAddingObject:asset] forKey:0];
                    } else {
                        [(NSMutableArray *) [self.sectionsDictionary objectForKey:0] addObject:asset];
                    }
                    _assetsLoadedCount++;

                    //[self dataDidLoad];
                });
            }

            _assetsEnumeratedCount++;
            if (_assetsEnumeratedCount >= [_assetsGroup numberOfAssets])
                [self dataDidLoad];

            _hud.progress = (float) _assetsEnumeratedCount / (float) [_assetsGroup numberOfAssets];

            //NSLog(@"enumerated %d total %d progress %d hud %f", _assetsEnumeratedCount, [_assetsGroup numberOfAssets], _assetsEnumeratedCount / [_assetsGroup numberOfAssets], _hud.progress);

        }];
    }
}

- (void)viewDidLoad {

    self.title = _titleMessage;
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setAllowsSelection:NO];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];  //To change the template use AppCode | Preferences | File Templates.

    if ([_assetsGroup numberOfAssets] > 10) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];

        // Set determinate mode
        _hud.mode = MBProgressHUDModeDeterminate;

        _hud.dimBackground = YES;

        _hud.delegate = self;
        _hud.labelText = @"Extracting dates";
    }
}


- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"GTGAssetPickerThumbTableView did appear");

    if (_assetsGroup) {


        //[self loadData];

        [_hud showWhileExecuting:@selector(loadData) onTarget:self withObject:nil animated:YES];
    }

}


- (void)doneAction:(id)sender {

    NSArray *selectedThumbnails = [_selectedThumbnails allObjects];
    NSMutableArray *selectedAssets = [NSMutableArray arrayWithCapacity:selectedThumbnails.count];

    for (GTGAssetThumbnailView *thumbnail in selectedThumbnails) {
        [selectedAssets addObject:thumbnail.asset];
    }

    [__delegate gtgAssetTableViewControllerDidFinishPickingMediaWithInfo:selectedAssets withGTGAssetTableViewController:self];
    [_selectedThumbnails removeAllObjects];
}


#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numToReturn = 0;
    if (self.sectionsDictionary) {
        if ([self.sectionsDictionary allKeys]) {
            numToReturn = [[self.sectionsDictionary allKeys] count];
        }
    }

    return numToReturn;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:[[self getAllKeysSorted] objectAtIndex:section]];
    return [date formattedDateString];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

    float columnCount = 4;

    if (self.sectionsDictionary == nil) return 0;

    float count = [[self arrayForSection:section] count];

    if (count < columnCount)
        columnCount = count;

    if (columnCount == 0)
        return 0;

    float numRowsInSection = count / columnCount;
    return (NSInteger) ceil(numRowsInSection);
}

- (NSArray *)arrayForSection:(NSInteger)section {
    return [self.sectionsDictionary valueForKey:[[self getAllKeysSorted] objectAtIndex:section]];
}

- (NSArray *)urlsForIndexPath:(NSIndexPath *)indexPath {

    int index = (indexPath.row * 4);
    int maxIndex = (indexPath.row * 4 + 3);

    //NSLog(@"urlsForIndexPath section %d row %d", indexPath.section, indexPath.row);

    NSArray *sectionArray = [self arrayForSection:indexPath.section];

    NSArray *assetsToReturn;
    if (maxIndex < [sectionArray count]) {

        assetsToReturn = [NSArray arrayWithObjects:[sectionArray objectAtIndex:index],
                                                   [sectionArray objectAtIndex:index + 1],
                                                   [sectionArray objectAtIndex:index + 2],
                                                   [sectionArray objectAtIndex:index + 3],
                                                   nil];
    }

    else if (maxIndex - 1 < [sectionArray count]) {

        assetsToReturn = [NSArray arrayWithObjects:[sectionArray objectAtIndex:index],
                                                   [sectionArray objectAtIndex:index + 1],
                                                   [sectionArray objectAtIndex:index + 2],
                                                   nil];
    }

    else if (maxIndex - 2 < [sectionArray count]) {

        assetsToReturn = [NSArray arrayWithObjects:[sectionArray objectAtIndex:index],
                                                   [sectionArray objectAtIndex:index + 1],
                                                   nil];
    }

    else if (maxIndex - 3 < [sectionArray count]) {

        assetsToReturn = [NSArray arrayWithObject:[sectionArray objectAtIndex:index]];
    }

    return assetsToReturn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    GTGAssetTableViewCell *cell = (GTGAssetTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[GTGAssetTableViewCell alloc]
                initWithImageSources:[self urlsForIndexPath:indexPath]
               withThumbnailDelegate:self
                     reuseIdentifier:CellIdentifier];
    } else {
        [cell setImageSources:[self urlsForIndexPath:indexPath]];
    }

    return cell;
}

- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79;
}

- (void)thumbnailWillDisplay:(GTGAssetThumbnailView *)thumbnail {

    if ([_selectedThumbnails containsObject:thumbnail.asset]) {
        thumbnail.enabled = YES;
        [thumbnail setIsSelected:YES];
    }
    else {

        [thumbnail setIsSelected:NO];
    }

    [__delegate gtgAssetTableViewControllerWillDisplayThumbnail:thumbnail];
}

- (void)thumbnailDidToggleSelection:(GTGAssetThumbnailView *)thumbNail {

    if ([thumbNail isSelected]) {
        if (self.enableMultipleSelection) {
            [_selectedThumbnails addObject:thumbNail];
        }
        else {
            GTGAssetThumbnailView *lastThumbnail = [_selectedThumbnails anyObject];
            if (lastThumbnail && lastThumbnail != thumbNail) {
                [_selectedThumbnails removeObject:lastThumbnail];
                [lastThumbnail setIsSelected:NO];
            }

            if (lastThumbnail != thumbNail) {
                [_selectedThumbnails addObject:thumbNail];

                NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:1];
                for (GTGAssetThumbnailView *thumb in [_selectedThumbnails allObjects]) {
                    [assets addObject:thumb.asset];
                }
            }
        }
    }
    else {
        if (self.enableMultipleSelection) {
            [_selectedThumbnails removeObject:thumbNail];
        }
        else {
            if ([_selectedThumbnails containsObject:thumbNail]) {
                [thumbNail setIsSelected:YES];

            }

        }
    }
}


@end
