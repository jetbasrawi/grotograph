#import "ImportAssetsViewController.h"
#import "SessionHelper.h"
#import "../Asset.h"
#import "GTGAssetsGroup.h"
#import "GTGAssetLibraryManager.h"

@interface ImportAssetsViewController ()

- (void)enumerateAssetGroups;

- (BOOL)shouldEnableSelectionForPhotoAtURL:(NSString *)url;

@end

@implementation ImportAssetsViewController {
    Project *_project;
    NSSet *_existingAssets;
    MBProgressHUD *_hud;
    GTGAssetTableViewController *_assetsTableViewController;
    GTGAssetsGroupTableViewController *_assetsGroupTableViewController;
    NSMutableArray *_assetGroups;
    __unsafe_unretained id <ImportAssetsViewControllerDelegate> __delegate;
}
- (id)initWithProject:(Project *)project withDelegate:(id <ImportAssetsViewControllerDelegate>)delegate {
    if (self == [self init]) {
        _project = project;
        __delegate = delegate;

        self.wantsFullScreenLayout = YES;
    }

    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ImportAssets did load");
    _assetGroups = [[NSMutableArray alloc] init];
    _assetsGroupTableViewController = [[GTGAssetsGroupTableViewController alloc] initWithDelegate:self];
    [self.view addSubview:_assetsGroupTableViewController.view];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:_assetsTableViewController
                                 action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem = doneButton;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];  //To change the template use AppCode | Preferences | File Templates.
    [self enumerateAssetGroups];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - GTGAssetsGroupsTableViewControllerDelegate Methods

- (void)gtgAssetsGroupTableVIewControllerDidSelectRowWithAssetGroup:(GTGAssetsGroup *)assetGroup {
    GTGAssetTableViewController *thumbView = [[GTGAssetTableViewController alloc] initWithAssetGroup:assetGroup.assetGroup
                                                                                        withDelegate:self
                                                                                    withTitleMessage:assetGroup.name
                                                                                           showDates:YES];
    [self.navigationController pushViewController:thumbView animated:YES];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                target:thumbView
                                                action:@selector(doneButtonClicked)];

    thumbView.navigationItem.rightBarButtonItem = doneButton;

}


-(void)gtgAssetGroupTableViewControllerDidCancel {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - GTGAssetsTableViewControllerDelegate Methods

- (void)gtgAssetTableViewControllerWillDisplayThumbnail:(GTGAssetThumbnailView *)thumbnail {
    thumbnail.enabled = [self shouldEnableSelectionForPhotoAtURL:[[[thumbnail.asset defaultRepresentation] url] absoluteString]];

}

- (void)gtgAssetTableViewControllerDidFinishPickingMediaWithInfo:(NSArray *)selectedAssets withGTGAssetTableViewController:(GTGAssetTableViewController *)picker {
    //To change the template use AppCode | Preferences | File Templates.

}

- (BOOL)shouldEnableSelectionForPhotoAtURL:(NSString *)url {


    //TODO: Preload existing assets so that they do not cause a delay
    if (!_existingAssets) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Asset"];

        //TODO:Limit results to current project
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.session.project.name = %@", _project.name];
        request.predicate = predicate;

        NSError *error;
        NSArray *objects = [_project.managedObjectContext executeFetchRequest:request error:&error];

        if (objects == nil) {
            NSLog(@"There was an error!");
            // Do whatever error handling is appropriate
        }

        if ([objects lastObject] != nil) {
            NSMutableArray *urls = [NSMutableArray arrayWithCapacity:[objects count]];
            for (Asset *asset in objects) {
                //NSLog(@"{PhotoURL %@", photo.url);
                if (asset.url)
                    [urls addObject:asset.url];
            }

            _existingAssets = [NSMutableSet setWithArray:urls];
        }
    }

    BOOL enabled = ![_existingAssets containsObject:url];

    return enabled;
}



- (void)hudWasHidden:(MBProgressHUD *)hud {
    NSLog(@"hudWasHidden with hud");
    _existingAssets = nil;
    [_assetsTableViewController.tableView reloadData];
}

- (void)hudWasHidden {
    NSLog(@"hudWasHidden");

    [_assetsTableViewController.tableView setNeedsLayout];

}





#pragma mark - Command handlers

- (void)doneButtonClicked {
    NSLog(@"Done button clicked");
    [__delegate importAssetsViewControllerDidFinish];
}


#pragma mark - asset enumeration

- (void)didEnumerateALAssetGroup:(ALAssetsGroup *)alAssetsGroup {
    NSLog(@"Did enumerate with group");
    GTGAssetsGroup *assetsGroup = [[GTGAssetsGroup alloc] init];
    assetsGroup.assetGroup = alAssetsGroup;
    [_assetGroups addObject:assetsGroup];
    [_assetsGroupTableViewController display:_assetGroups];
}

- (void)enumerateAssetGroups {
    ALAssetsLibrary *library = [GTGAssetLibraryManager defaultAssetsLibrary];

    @autoreleasepool {

        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {

            NSLog(@"Enumerate group");

            if (group == nil) {
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self didEnumerateALAssetGroup:group];
            });
        };

        // Group Enumerator Failure Block
        void (^assetGroupEnumeratorFailure)(NSError *) = ^(NSError *error) {

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:@"Error"
                              message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]]
                             delegate:nil cancelButtonTitle:@"Ok"
                    otherButtonTitles:nil];

                [alert show];
            });

            NSLog(@"A problem occured %@", [error description]);
        };

        // Enumerate Albums
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:assetGroupEnumerator
                             failureBlock:assetGroupEnumeratorFailure];
    }
}












//#pragma mark GTGImagePickerControllerDelegate Methods
//
//- (void)gtgImagePickerControllerWillDisplayThumbnail:(GTGAssetThumbnailView *)thumbnail {
//    thumbnail.enabled = [self shouldEnableSelectionForPhotoAtURL:[[[thumbnail.asset defaultRepresentation] url] absoluteString]];
//}
//
//
//- (void)importAssets:(NSArray *)info {
//    @autoreleasepool {
//
//        float doneCount = 0;
//
//        for (ALAsset *alAsset in info) {
//
//            NSString *uuid = [FileSaver getUUID];
//            //NSLog(@"Date taken............%@", (NSString *)[alAsset valueForProperty:ALAssetPropertyDate]);
//            //NSLog(@"Location............%@", (NSString *)[alAsset valueForProperty:ALAssetPropertyLocation]);
//            //NSLog(@"URLs............%@", (NSString *)[alAsset valueForProperty:ALAssetPropertyURLs]);
//            //NSArray *representations = [asset valueForProperty:ALAssetPropertyRepresentations];
//
//            NSDate *alAssetDate = [alAsset valueForProperty:ALAssetPropertyDate];
//            Session *session = [_project getOrCreateSessionForDate:alAssetDate];
//
//            //add images to relevant session
//            Asset *cdAsset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:session.managedObjectContext];
//            [cdAsset setDateCreated:alAssetDate];
//            [cdAsset setUuid:uuid];
//            [cdAsset setUrl:[[[alAsset defaultRepresentation] url] absoluteString]];
//
//            [session addAssetsObject:cdAsset];
//
//            //NSLog(@"Imported with url %@", [[[alAsset defaultRepresentation] url] absoluteString]);
//
//            doneCount++;
//
//            _hud.progress = (doneCount / [info count]);
//        }
//    }
//}
//
//- (void)gtgImagePickerControllerDidFinishPickingMediaWithInfo:(NSArray *)info withPicker:(GTGAssetTableViewController *)picker {
//
//    _assetsTableViewController = picker;
//
//    _hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:_hud];
//
//    // Set determinate mode
//    _hud.mode = MBProgressHUDModeDeterminate;
//
//
//    _hud.dimBackground = YES;
//
//    _hud.delegate = self;
//    _hud.labelText = @"Importing";
//
//    // myProgressTask uses the HUD instance to update progress
//    [_hud showWhileExecuting:@selector(importAssets:) onTarget:self withObject:info animated:YES];
//
//}






//- (void)gtgImagePickerControllerDidFinishPickingMediaWithInfo:(NSArray *)info {
//
//    @autoreleasepool {
//
//        for (NSDictionary *dict in info) {
//
//            //parse out the dates
//            //Get the exif data from the image
//            NSString *uuid = [FileSaver getUUID];
//
//            ALAsset *asset = [dict objectForKey:@"Asset"];
//
//            //NSLog(@"Date taken............%@", (NSString *)[asset valueForProperty:ALAssetPropertyDate]);
//            //NSLog(@"Location............%@", (NSString *)[asset valueForProperty:ALAssetPropertyLocation]);
//            //NSLog(@"URLs............%@", (NSString *)[asset valueForProperty:ALAssetPropertyURLs]);
//            //NSArray *representations = [asset valueForProperty:ALAssetPropertyRepresentations];
//
//            NSDate *photoDate = [asset valueForProperty:ALAssetPropertyDate];
//
//            SessionHelper *sessionHelper = [[SessionHelper alloc] init];
//            Session *session = [sessionHelper getOrCreateSessionForDate:photoDate fromProject:_project];
//
//            //add images to relevant session
//            Photo *photo = [NSEntityDescription
//                    insertNewObjectForEntityForName:@"Photo"
//                             inManagedObjectContext:session.managedObjectContext];
//
//            [photo setDateCreated:photoDate];
//            [photo setUuid:uuid];
//            [photo setUrl:[[[asset defaultRepresentation] url] absoluteString]];
//
//            [session addPhotosObject:photo];
//
//            NSError *error = nil;
//            [session.managedObjectContext save:&error];
//
//            if (error) {
//                NSLog(@"An error occured while saving managed object context for imported images %@", error);
//            }
//
//            NSLog(@"Imported with url %@", [[[asset defaultRepresentation] url] absoluteString]);
//        }
//    }
//}




//- (void)importImages:(NSArray *)assets {
//
//    ImportingStatusView *importingStatusView = [[ImportingStatusView alloc] init];
//    [self presentModalViewController:importingStatusView animated:NO];
//
//    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
//
//    dispatch_queue_t imageImportQueue = dispatch_queue_create("ImageImportQueue", NULL);
//    dispatch_async(imageImportQueue, ^{
//
//        @autoreleasepool {
//
//            float doneCount = 0.0;
//
//            for (ALAsset *asset in assets) {
//
//                NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
//                [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:UIImagePickerControllerMediaType];
//                [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:UIImagePickerControllerOriginalImage];
//                [workingDictionary setObject:asset forKey:@"Asset"];
//                [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
//
//                [returnArray addObject:workingDictionary];
//
//                doneCount++;
//
//                float progress = (doneCount / [assets count]);
//
//                NSLog(@"Progress = %f%%", progress);
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    importingStatusView.progressView.progress = progress;
//                });
//            }
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            [self dismissModalViewControllerAnimated:NO];
//            [self.delegate gtgImagePickerControllerDidFinishPickingMediaWithInfo:returnArray];
//        });
//    });
//
//    dispatch_release(imageImportQueue);
//}


@end
