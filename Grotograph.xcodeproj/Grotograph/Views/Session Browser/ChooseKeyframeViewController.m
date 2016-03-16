#import "ChooseKeyframeViewController.h"
#import "Session.h"
#import "NSArray-Set.h"
#import "GTGAssetTableViewController.h"
#import "Asset.h"

@interface ChooseKeyframeViewController ()

- (void)doneAction;

- (void)gtgImagePickerControllerDidCancel;

@end

@implementation ChooseKeyframeViewController {

    __unsafe_unretained Session *_session;
    __unsafe_unretained id <ChooseKeyframeViewControllerDelegate> __delegate;

    GTGAssetTableViewController *_fromSessionPicker;
    UINavigationController *_navigationController;
    
    UITabBarController *_tabBarController;

    NSArray *_photosArray;
}
- (id)initWithSession:(Session *)session withDelegate:(id <ChooseKeyframeViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _session = session;
        __delegate = delegate;
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)doneAction {
    NSLog(@"Done button clicked");


}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor blackColor]];
    _photosArray = [NSArray arrayByOrderingSet:_session.assets byKey:@"dateCreated" ascending:YES];
    _fromSessionPicker = [[GTGAssetTableViewController alloc]
            initWithPhotosOrAssets:_photosArray
                    withDelegate:self
                withTitleMessage:@"Choose Key Frame"];

    _fromSessionPicker.enableMultipleSelection = NO;

    UIViewController *photosFromDateViewController = [[UIViewController alloc] init];
    UIViewController *allPhotosViewController = [[UIViewController alloc] init];

    NSArray *controllers = [NSArray arrayWithObjects:_fromSessionPicker, photosFromDateViewController, allPhotosViewController, nil];

    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.viewControllers = controllers;
    _tabBarController.delegate = self;

    //_navigationController = [[UINavigationController alloc] initWithRootViewController:_tabBarController];
    [self.view addSubview:_tabBarController.view];

    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
        [self.navigationItem setRightBarButtonItem:doneButtonItem];
        [self.navigationItem setTitle:@"Session Photos"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];  //To change the template use AppCode | Preferences | File Templates.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)gtgImagePickerControllerWillDisplayThumbnail:(GTGAssetThumbnailView *)thumbnail {

    NSString *urlString = [[[[thumbnail.asset defaultRepresentation] url] absoluteString]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *keyframeURL = [_session.keyFrame.url
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([urlString isEqualToString:keyframeURL]) {
        [thumbnail setIsSelected:YES];
    }
}

- (void)gtgImagePickerControllerDidFinishPickingMediaWithInfo:(NSArray *)info withPicker:(GTGAssetTableViewController *)picker {

    ALAsset *selectedAsset = [info lastObject];
    if (!selectedAsset) {
        [self gtgImagePickerControllerDidCancel];
        return;
    }

    Asset *photo = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.url = %@", [[[selectedAsset defaultRepresentation] url] absoluteString]];

    NSError *error = nil;
    NSArray *objects = [_session.managedObjectContext executeFetchRequest:request error:&error];

    if (objects) {
        photo = [objects lastObject];
    }

    [__delegate chooseKeyframeViewControllerDidFinishChoosingKeyframeWithPhoto:photo];
}

- (void)gtgImagePickerControllerDidCancel {
    [__delegate chooseKeyframeViewControllerDidFinishChoosingKeyframeWithPhoto:nil];
}


- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    //To change the template use AppCode | Preferences | File Templates.
    NSLog(@"Did end customising");

}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"Did select view controller");

}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSLog(@"Should select view controller");

    return NO;


}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    NSLog(@"Will begin customising");

}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    NSLog(@"Will end customising");

}


@end
