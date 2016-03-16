//
//  ProjectMainView.m
//  Grotograph
//
//  Created by Jet Basrawi on 20/12/2011.
//  Copyright (c) 2011 Free for all products Ltd. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "SessionBrowserViewController.h"
#import "NSArray-Set.h"
#import "SessionPhotoBrowser/ImportAssetsViewController.h"
//#import "SessionBrowserPageController.h"
#import "Asset.h"
#import "ActionRequiredView.h"
#import "Asset.h"
#import "FileSaver.h"
#import "Project+Queries.h"
#import "NSDate+Utils.h"

#define PADDING 10
#define OVERLAY_ALPHA 0.3

// Handle deprecations and suppress hide warnings
@interface UIApplication (DepreciationWarningSuppresion)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end


@interface SessionBrowserViewController ()

@property(nonatomic, strong) NSArray *sessions;


- (CGRect)frameForPagingScrollView;

- (CGSize)contentSizeForPagingScrollView;

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;

- (CGRect)frameForPageAtIndex:(int)index;

- (void)updateNavigation;

- (BOOL)pageIsOutOfBounds:(int)pageIndex;

- (void)setControlsHidden:(BOOL)hidden;

- (void)cancelControlHiding;

- (void)hideControls;

- (SessionBrowserPageView *)dequeueRecycledPage;

- (void)loadPage:(int)pageIndex;

- (void)unloadPage:(int)pageIndex;

- (SessionBrowserPageView *)pageAtIndex:(int)pageIndex;

- (void)setToolBarForScrolling;

- (void)toggleOverlayPreviousPage;

- (void)toggleOverlayNextPage;

- (void)endEditMode;

- (void)chooseKeyframeButtonClicked;

- (void)handleImportImageButtonClicked;

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType;

- (void)showChooseKeyframeViewAsModal;


- (void)setNavBarForEditing;

- (void)setNavBarForScrolling;

@end


@implementation SessionBrowserViewController {

    int _currentPageIndex;
    BOOL _performingLayout;
    BOOL _rotating;
    UIScrollView *_pagingScrollView;

    NSMutableArray *_loadedPages;
    NSMutableSet *_recycledPages;

    UIToolbar *_toolbar;
    UIBarButtonItem *_importButton;
    UIBarButtonItem *_nextButton;
    UIBarButtonItem *_chooseKeyframeButton;
    UIBarButtonItem *_overlayPreviousButton;
    UIBarButtonItem *_overlayNextButton;
    UIBarButtonItem *_cameraButton;

    NSTimer *_controlVisibilityTimer;
    Project *_project;

    UIImagePickerController *_imagePicker;
    CameraOverlayView *_overlay;
    ChooseKeyframeViewController *_picker;
    ImportAssetsViewController *_importAssetsViewController;
}

@synthesize sessions = _sessions;

- (NSArray *)sessions {

    if (_sessions == nil) {
        _sessions = [NSArray arrayByOrderingSet:_project.sessions byKey:@"date" ascending:YES];
    }

    return _sessions;
}

- (id)initWithProject:(Project *)project {

    if ((self = [super init])) {

        NSLog(@"Init SessionBrowser");

        _project = project;

        // Defaults
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
        self.view.backgroundColor = [UIColor blackColor];
        _currentPageIndex = 0;
        _performingLayout = NO;
        _rotating = NO;


    }

    return self;
}

- (void)didReceiveMemoryWarning {

    //_sessions = nil;
    //[_recycledPages removeAllObjects];
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    _project = nil;
    _nextButton = nil;
    _importButton = nil;
    _toolbar = nil;
    _recycledPages = nil;
    _loadedPages = nil;
    _currentPageIndex = 0;
    _pagingScrollView = nil;
    _sessions = nil;
    [super viewDidUnload];
}

- (void)dealloc {

    _project = nil;
    _pagingScrollView = nil;

    NSLog(@" - - < dealloc KeyframeBrowser");
}



#pragma mark - View lifecycle



- (CGRect)getFrameForEmptyProjectView {

    CGRect bounds = self.view.bounds;
    bounds.origin.y = 64;
    bounds.size.height -= 64 + 44;
    return bounds;

}

- (void)viewDidLoad {

    [super viewDidLoad];

    NSUInteger numSessionsToDisplay = self.sessions.count;
    NSLog(@"Number of sessions %d", numSessionsToDisplay);

    self.view.backgroundColor = [UIColor blackColor];

    if (self.sessions.count > 0) {

        CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
        _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
        _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pagingScrollView.pagingEnabled = YES;
        _pagingScrollView.delegate = self;
        _pagingScrollView.showsHorizontalScrollIndicator = NO;
        _pagingScrollView.showsVerticalScrollIndicator = NO;
        _pagingScrollView.backgroundColor = [UIColor blackColor];
        _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
        _pagingScrollView.alwaysBounceHorizontal = YES;
        _pagingScrollView.alwaysBounceVertical = NO;


        [self.view addSubview:_pagingScrollView];

        NSMutableArray *loadedPages = [[NSMutableArray alloc] initWithCapacity:numSessionsToDisplay];
        for (unsigned i = 0; i < numSessionsToDisplay; i++) {
            [loadedPages addObject:[NSNull null]];
        }
        _loadedPages = loadedPages;

        _recycledPages = [[NSMutableSet alloc] init];

        [self jumpToPageAtIndex:numSessionsToDisplay - 1];

        [self loadPage:_currentPageIndex];
        [self loadPage:_currentPageIndex - 1];
        [self loadPage:_currentPageIndex + 1];

        [self setNavBarForScrolling];

    }
    else {
        ActionRequiredView *emptyProjectView = [[ActionRequiredView alloc]
                initWithFrame:[self getFrameForEmptyProjectView]
                  withHeading:_project.name
                  withMessage:@"Import existing photos or use the camera to take new photos."];
        [self.view addSubview:emptyProjectView];
    }




    //[self logFrames:@"At end of session browser view did load"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set status bar style to black translucent
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];

    self.navigationController.navigationBar.tintColor = nil;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

        _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
        _toolbar.tintColor = nil;
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_toolbar];

        [self setToolBarForScrolling];
}

- (void)viewDidAppear:(BOOL)animated {
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Set status bar style to black translucent
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [self cancelControlHiding];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {

    CGRect visibleBounds = _pagingScrollView.bounds;

    int pageIndex = (int) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));

    if ([self pageIsOutOfBounds:pageIndex])
        return;

    if (pageIndex != _currentPageIndex) {
        _currentPageIndex = pageIndex;
    }
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self logFrames:@"Will begin dragging"];
//    Session *session = [self.sessions objectAtIndex:(NSUInteger) _currentPageIndex];
//
//    if (session.keyFrame)
//        [self hideControls];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateNavigation];

    [self loadPage:_currentPageIndex];
    [self loadPage:_currentPageIndex - 1];
    [self loadPage:_currentPageIndex + 1];

    [self unloadPage:_currentPageIndex - 2];
    [self unloadPage:_currentPageIndex + 2];

}

#pragma mark -
#pragma mark Geometry Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.size.width += (2 * PADDING);
    frame.origin.x -= PADDING;
    return frame;
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
    return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

//Returns the frame for the actual content area that will be displayed in the scroll view item, which will
//have some padding on either side.
- (CGRect)frameForPageAtIndex:(int)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.

    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = CGRectMake(
            (bounds.size.width * index) + PADDING - 1,
            bounds.origin.y,
            bounds.size.width - (PADDING * 2) + 2,
            bounds.size.height);

    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = [self frameForPagingScrollView];
    CGSize size = CGSizeMake((bounds.size.width) * _sessions.count, bounds.size.height);
    NSLog(@"Content size %f %f", size.height, size.width);
    return size;
}

#pragma mark -
#pragma mark Navigation

- (void)updateNavigation {

    Session *session = [self.sessions objectAtIndex:_currentPageIndex];

    if (session)
        self.title = [[session date] formattedDateString];

//    // Title
//    if (self.sessions.count > 1) {
//        self.title = [NSString stringWithFormat:@"%i of %i", _currentPageIndex + 1, self.sessions.count];
//    } else {
//        self.title = nil;
//    }
    
    

    // Buttons
    //_importButton.enabled = (_currentPageIndex > 0);
    //_nextButton.enabled = (_currentPageIndex < self.sessions.count - 1);

}

- (void)jumpToPageAtIndex:(int)index {

    if (index < self.sessions.count) {
        _currentPageIndex = index;
        CGRect pageFrame = [self frameForPageAtIndex:index];
        _pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x, 0);
        [self updateNavigation];
    }

    // Update timer to give more time
    //[self hideControlsAfterDelay];
}

- (void)gotoPreviousPage {
    [self jumpToPageAtIndex:_currentPageIndex - 1];
}

- (void)gotoNextPage {
    [self jumpToPageAtIndex:_currentPageIndex + 1];
}

#pragma mark -
#pragma mark Control Hiding / Showing

- (void)setControlsHidden:(BOOL)hidden {

    // Get status bar height if visible
    CGFloat statusBarHeight = 0;
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
    }

    // Status Bar
    if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
    }

    // Get status bar height if visible
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
    }

    // Set navigation bar frame
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    navBarFrame.origin.y = statusBarHeight;
    self.navigationController.navigationBar.frame = navBarFrame;

    // Bars
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
    [_toolbar setAlpha:hidden ? 0 : 1];
    [UIView commitAnimations];

    // Control hiding timer
    // Will cancel existing timer but only begin hiding if
    // they are visible
    [self hideControlsAfterDelay];

}

- (void)cancelControlHiding {
    // If a timer exists then cancel and release
    if (_controlVisibilityTimer) {
        [_controlVisibilityTimer invalidate];
        _controlVisibilityTimer = nil;
    }
}

// Enable/disable control visibility timer
- (void)hideControlsAfterDelay {
    [self cancelControlHiding];
    if (![UIApplication sharedApplication].isStatusBarHidden) {
        _controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
    }
}

- (void)hideControls {
    [self setControlsHidden:YES];
}

- (void)toggleControls {
    [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden];
}

- (void)setNavBarForEditing {

    UIBarButtonItem *button = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                 target:self
                                 action:@selector(handleSaveChangesForEdit)];

    self.title = NSLocalizedString(@"Edit", @"Edit");

    self.navigationItem.rightBarButtonItem = button;

    button = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                 target:self
                                 action:@selector(endEditMode)];

    self.navigationItem.leftBarButtonItem = button;
    self.navigationItem.hidesBackButton = YES;
}


- (void)setNavBarForChoosingKeyframe {

    UIBarButtonItem *button = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                 target:self
                                 action:@selector(handleChooseKeyframeClicked)];

    self.title = NSLocalizedString(@"Choose Keyframe", @"Choose Keyframe");

    self.navigationItem.rightBarButtonItem = button;

}

- (void)setNavBarForScrolling {

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;

    //TODO: Hide Edit button if there is no image to edit
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                 target:self
                                 action:@selector(displayEditMode)];
    self.navigationItem.rightBarButtonItem = buttonItem;

    [self updateNavigation];
}

- (void)setToolBarForEditing {

    // Toolbar Items
    _overlayPreviousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowLeft.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleOverlayPreviousPage)];
    _overlayNextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowRight.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleOverlayNextPage)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];

    if ([self pageAtIndex:_currentPageIndex - 1] != nil)
        [items addObject:_overlayPreviousButton];
    [items addObject:space];
    [items addObject:space];
    [items addObject:space];

    if ([self pageAtIndex:_currentPageIndex + 1] != nil)
        [items addObject:_overlayNextButton];
    [_toolbar setItems:items];
}


- (void)setToolBarForScrolling {

    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera)];
    _importButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(handleImportImageButtonClicked)];
    _chooseKeyframeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(chooseKeyframeButtonClicked)];

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];

    [items addObject:_importButton];
    [items addObject:space];
    [items addObject:_chooseKeyframeButton];
    [items addObject:space];
    [items addObject:_cameraButton];
    [_toolbar setItems:items];

}



#pragma mark - Pages and paging

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (BOOL)pageIsOutOfBounds:(int)pageIndex {
    if (pageIndex < 0) {
        return true;
    }
    else if (pageIndex >= self.sessions.count) {
        return true;
    }

    return false;
}

- (SessionBrowserPageView *)dequeueRecycledPage {
    SessionBrowserPageView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageAtIndex:(int)index {
    return [self pageAtIndex:index] != nil;
}

- (void)addPageToLoadedPages:(SessionBrowserPageView *)page atIndex:(int)index {
    [_loadedPages replaceObjectAtIndex:(NSUInteger) index withObject:page];
}

- (void)loadPage:(int)pageIndex {

    if ([self pageIsOutOfBounds:pageIndex])
        return;

    if ([self isDisplayingPageAtIndex:pageIndex])
        return;

    CGRect frame = [self frameForPageAtIndex:pageIndex];
    SessionBrowserPageView *page = [self dequeueRecycledPage];
    if (!page) {
        page = [[SessionBrowserPageView alloc] initWithFrame:frame andDelegate:self];
    }

    Session *session = [_sessions objectAtIndex:(NSUInteger) pageIndex];
    [page display:session withPageIndex:pageIndex withFrame:frame];

    [self addPageToLoadedPages:page atIndex:pageIndex];
    [_pagingScrollView addSubview:page];
}

- (void)unloadPage:(int)pageIndex {

    if ([self pageIsOutOfBounds:pageIndex])
        return;

    if (![self isDisplayingPageAtIndex:pageIndex])
        return;

    SessionBrowserPageView *page = [self pageAtIndex:pageIndex];
    if (page) {
        NSLog(@"Unloading page with index %d", pageIndex);
        [_recycledPages addObject:page];
        [page removeFromSuperview];
        [page unload];
        [_loadedPages replaceObjectAtIndex:(NSUInteger) pageIndex withObject:[NSNull null]];
    }
}

- (SessionBrowserPageView *)pageAtIndex:(int)pageIndex {
    SessionBrowserPageView *page = [_loadedPages objectAtIndex:(NSUInteger) pageIndex];
    if ((NSNull *) page == [NSNull null])
        return nil;

    return page;
}

#pragma mark - Overlay

- (void)overlayPage:(SessionBrowserPageView *)page {

//    PhotoView *currentPage = [self pageAtIndex:_currentPageIndex];
//    [_pagingScrollView bringSubviewToFront:currentPage];
//
//    CGRect currentPageRect = [self frameForPageAtIndex:_currentPageIndex];
//    [page setFrame:currentPageRect];
//
//    [currentPage setAlpha:OVERLAY_ALPHA];
}

- (void)removePageOverlay:(int)pageIndex {

//    PhotoView *currentPage = [self pageAtIndex:_currentPageIndex];
//    [currentPage setAlpha:1.0];
//
//    PhotoView *overlaidPage = [self pageAtIndex:pageIndex];
//    [overlaidPage setFrame:[self frameForPageAtIndex:pageIndex]];
}

- (void)toggleOverlayPreviousPage {
//    PhotoView *previousPage = [self pageAtIndex:_currentPageIndex - 1];
//
//    if (previousPage.frame.origin.x != [self frameForPageAtIndex:_currentPageIndex].origin.x) {
//        [self overlayPage:previousPage];
//    }
//    else {
//        [self removePageOverlay:_currentPageIndex - 1];
//    }
}

- (void)toggleOverlayNextPage {
//    PhotoView *nextPage = [self pageAtIndex:_currentPageIndex + 1];
//
//    if (nextPage.frame.origin.x != [self frameForPageAtIndex:_currentPageIndex].origin.x) {
//        [self overlayPage:nextPage];
//    }
//    else {
//        [self removePageOverlay:_currentPageIndex + 1];
//    }
}

#pragma mark - Display modes

- (void)displayEditMode {

//    _pagingScrollView.scrollEnabled = NO;
//    PhotoView *keyframeView = [self pageAtIndex:_currentPageIndex];
//    [keyframeView displayEditMode];
//
//    [self setNavBarForEditing];
//    [self setToolBarForEditing];
}

- (void)endEditMode {
//    _pagingScrollView.scrollEnabled = YES;
//
//    [self removePageOverlay:_currentPageIndex - 1];
//    [self removePageOverlay:_currentPageIndex + 1];
//
//    [self setNavBarForScrolling];
//    [self setToolBarForScrolling];
}


#pragma mark - Command handling


- (void)chooseKeyframeButtonClicked {
    [self showChooseKeyframeViewAsModal];

}

- (void)handleSaveChangesForEdit {

//    //Get transforms from the current keyframeView and update the entity
//    PhotoView *pageAtIndex = [self pageAtIndex:_currentPageIndex];
//    [pageAtIndex commitChanges];
}

- (void)handleChooseKeyframeClicked {
    //To change the template use AppCode | Preferences | File Templates.

}


- (void)handleImportImageButtonClicked {
    NSLog(@"Handle Import Images");
    _importAssetsViewController = [[ImportAssetsViewController alloc] initWithProject:_project withDelegate:self];
    UINavigationController *localNavController = [[UINavigationController alloc] initWithRootViewController:_importAssetsViewController];
    [self presentModalViewController:localNavController animated:YES];
}

#pragma Mark - ActionSheet delegate

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc]
            initWithTitle:nil delegate:self
        cancelButtonTitle:@"Cancel"
   destructiveButtonTitle:nil otherButtonTitles:@"Choose Keyframe", @"Adjust Keyframe", @"Import", nil];

    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //[self showKeyFrameSelector];
    } else if (buttonIndex == 1) {
        //[self showKeyFrameSelector];
    } else if (buttonIndex == 2) {
        //[self showImportImagesView];
    } else if (buttonIndex == 3) {

    } else if (buttonIndex == 4) {

    }
}

#pragma mark - Logging

- (void)logFrames:(NSString *)heading {

//    NSLog(@" ");
//    if (heading != nil)
//        NSLog(@"Log frames %@", heading);
//
//    NSLog(@"Content offset %f", _pagingScrollView.contentOffset.x);
//
//    int count = 0;
//
//    for (int i = 0; i < _loadedPages.count; i++) {
//
//        GTGSessionBrowserPage *page = [self pageAtIndex:i];
//
//        if (page) {
//
//            NSLog(@"Frame for page with index %d = %f %f %f %f", page.pageIndex, page.frame.origin.x, page.frame.origin.y, page.frame.size.width, page.frame.size.height);
//
//            int subViewCount = 0;
//            for (UIView *view in page.subviews) {
//                NSLog(@" - Subview frame at  %d = %f %f %f %f", subViewCount, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//                subViewCount++;
//            }
//        }
//    }

//    NSArray *subviews = _pagingScrollView.subviews;
//    for (UIView *view in subviews) {
//        NSLog(@"Frame at subview %d = %f %f %f %f", count, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//
//        int subViewCount = 0;
//        for (UIView *v in view.subviews) {
//            NSLog(@" - Subview frame at  %d = %f %f %f %f", subViewCount, v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
//            subViewCount++;
//        }
//
//
//        count++;
//    }
}


#pragma mark - Image Picker

- (void)showCamera {
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        if (!_imagePicker)
            _imagePicker = [[UIImagePickerController alloc] init];

        _imagePicker.mediaTypes = mediaTypes;
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
        _imagePicker.sourceType = sourceType;

        _imagePicker.showsCameraControls = NO;
        _overlay = [[CameraOverlayView alloc] init];
        _overlay.delegate = self;
        _imagePicker.cameraOverlayView = _overlay.view;
        [self presentModalViewController:_imagePicker animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:@"Error accessing media"
                      message:@"Device doesn’t support that media source."
                     delegate:nil cancelButtonTitle:@"Drat!"
            otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    //To change the template use AppCode | Preferences | File Templates.

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    NSDate *today = [NSDate date];
    Session *session = [_project sessionForDate:today];
    if (!session) {
        session = [_project createSessionWithDate:today];
    }

    __unsafe_unretained Asset *photo = [NSEntityDescription
            insertNewObjectForEntityForName:@"Asset"
                     inManagedObjectContext:session.managedObjectContext];

    ALAssetsLibraryWriteImageCompletionBlock completeBlock = ^(NSURL *assetURL, NSError *error) {
        if (!error) {
#pragma mark get image url from camera capture.
            NSString *uuid = [FileSaver getUUID];
            [photo setDateCreated:[[NSDate alloc] init]];
            [photo setUuid:uuid];
            [photo setUrl:[NSString stringWithFormat:@"%@", assetURL]];
            [session addAssetsObject:photo];

            NSError *error = nil;
            [session.managedObjectContext save:&error];

            if (error) {
                //TODO:
            }

            NSLog(@"Image saved at %@", photo.url);
        }
        else {
            //Error handling here
        }
    };

    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[image CGImage]
                                  orientation:(ALAssetOrientation) [image imageOrientation]
                              completionBlock:completeBlock];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //To change the template use AppCode | Preferences | File Templates.

}


#pragma mark - Camera overlay delegate methods

- (void)doneButtonPressed {

    [self dismissModalViewControllerAnimated:YES];

}

- (void)takePhotoButtonPressed {
    [_imagePicker takePicture];
}

#pragma mark - keyframe picker

- (void)showChooseKeyframeViewAsModal {

    Session *session = [_sessions objectAtIndex:(NSUInteger) _currentPageIndex];

    _picker = [[ChooseKeyframeViewController alloc] initWithSession:session withDelegate:self];
        [_picker setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    UINavigationController *localNavController = [[UINavigationController alloc] initWithRootViewController:_picker];
    [self presentModalViewController:localNavController animated:YES];
}

#pragma mark - ChooseKeyframeViewControllerDelegate methods

- (void)chooseKeyframeViewControllerDidFinishChoosingKeyframeWithPhoto:(Asset *)photo {

    NSLog(@"Finished choosing %@", photo);

    if (photo != nil) {

        Session *session = [self.sessions objectAtIndex:(NSUInteger) _currentPageIndex];
        session.keyFrame = photo;

        NSError *error;
        [session.managedObjectContext save:&error];

        SessionBrowserPageView *page = [self pageAtIndex:_currentPageIndex];
        [page display:session withPageIndex:_currentPageIndex withFrame:[self frameForPageAtIndex:_currentPageIndex]];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}


#pragma mark - Browser page delegate methods

- (void)gtgSessionBrowserPageDidDisplay:(SessionBrowserPageView *)page {
    if (page == [self pageAtIndex:_currentPageIndex])
        [self dismissModalViewControllerAnimated:YES];

}

#pragma mark - ImportAssetsViewControllerDelegate Methods

- (void)importAssetsViewControllerDidFinish {
    [self dismissModalViewControllerAnimated:YES];
    _importAssetsViewController = nil;

}


@end
