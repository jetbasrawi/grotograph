//
//  SessionPhotoBrowser.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "SessionPhotoBrowser.h"
#import "ZoomingScrollView.h"
#import "Project.h"
#import "Session.h"
#import "Photo.h"

#define PADDING 10

// Handle depreciations and supress hide warnings
@interface UIApplication (DepreciationWarningSuppresion)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end

@interface SessionPhotoBrowser () {

    NSString *_projectName;

    __unsafe_unretained NSManagedObjectContext *_managedObjectContext;

    NSArray *_photos;

    // Views
    UIScrollView *_pagingScrollView;

    // Paging
    NSMutableSet *_visiblePages, *_recycledPages;
    NSUInteger _currentPageIndex;
    NSUInteger _pageIndexBeforeRotation;

    // Navigation & controls
    UIToolbar *_toolbar;
    NSTimer *_controlVisibilityTimer;
    UIBarButtonItem *_previousButton, *_nextButton;

    // Misc
    BOOL _performingLayout;
    BOOL _rotating;
}

@property(nonatomic, strong) NSArray *photos;
@property(nonatomic, strong) NSString *projectName;

@end

// MWPhotoBrowser
@implementation SessionPhotoBrowser

@synthesize photos = _photos;
@synthesize projectName = _projectName;

- (NSArray *)photos {

    if (_photos == nil) {
        Project *project = nil;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:_managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(name = %@)", _projectName]];
        [request setEntity:entityDescription];

        NSError *error = nil;
        NSArray *objects = [_managedObjectContext executeFetchRequest:request error:&error];

        if (objects != nil) {
            if ([objects count] > 0)
                project = (Project *) [objects objectAtIndex:0];
        }
        else {
            //TODO : Error handling
            NSLog(@"Unable to load project from DB!");
        }

        if (project != nil) {
            NSMutableArray *gtgPhotos = [[NSMutableArray alloc] init];
            for (Session *session in project.sessions) {
                GTGPhoto *gtgPhoto = [[GTGPhoto alloc] initWithFilePath:session.keyFrame.url];
                [gtgPhotos addObject:gtgPhoto];
            }

            _photos = [[NSArray alloc] initWithArray:gtgPhotos];
        }
    }

    return _photos;
}

- (id)initWithProjectName:(NSString *)projectName withObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if ((self = [super init])) {

        NSLog(@"Init SessionPhotoBrowser");
        
        _projectName = projectName;
        _managedObjectContext = managedObjectContext;

        // Defaults
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
        _currentPageIndex = 0;
        _performingLayout = NO;
        _rotating = NO;

    }
    return self;
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {

    // Release any cached data, images, etc that aren't in use.

    // Release images
    [self.photos makeObjectsPerformSelector:@selector(releasePhoto)];
    [_recycledPages removeAllObjects];
    NSLog(@"didReceiveMemoryWarning");

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

// Release any retained subviews of the main view.
- (void)viewDidUnload {
    _currentPageIndex = 0;
    _pagingScrollView = nil;
    _visiblePages = nil;
    _recycledPages = nil;
    _toolbar = nil;
    _previousButton = nil;
    _nextButton = nil;
    _photos = nil;
}

- (void)dealloc {
    NSLog(@"Dealloc sessionPhotoBrowser");
    _photos = nil;
}

#pragma mark -
#pragma mark View

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    // View
    self.view.backgroundColor = [UIColor blackColor];

    // Setup paging scrolling view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self.view addSubview:_pagingScrollView];

    // Setup pages
    _visiblePages = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];

    [self tilePages];

    // Navigation bar
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

    // Only show toolbar if there's more that 1 photo
    if (self.photos.count > 1) {

        // Toolbar
        _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
        _toolbar.tintColor = nil;
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_toolbar];

        // Toolbar Items
        _previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowLeft.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
        _nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowRight.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:space];
        if (self.photos.count > 1) [items addObject:_previousButton];
        [items addObject:space];
        if (self.photos.count > 1) [items addObject:_nextButton];
        [items addObject:space];
        [_toolbar setItems:items];

    }

    // Super
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {

    // Super
    [super viewWillAppear:animated];

    // Layout
    [self performLayout];

    // Set status bar style to black translucent
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

    // Navigation
    [self updateNavigation];
    [self hideControlsAfterDelay];
    [self didStartViewingPageAtIndex:_currentPageIndex]; // initial

}

- (void)viewWillDisappear:(BOOL)animated {

    // Super
    [super viewWillDisappear:animated];

    // Cancel any hiding timers
    [self cancelControlHiding];
}

#pragma mark -
#pragma mark Layout

// Layout subviews
- (void)performLayout {

    // Flag
    _performingLayout = YES;

    // Toolbar
    _toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];

    // Remember index
    NSUInteger indexPriorToLayout = _currentPageIndex;

    // Get paging scroll view frame to determine if anything needs changing
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];

    // Frame needs changing
    _pagingScrollView.frame = pagingScrollViewFrame;

    // Recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

    // Adjust frames and configuration of each visible page
    for (ZoomingScrollView *page in _visiblePages) {
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
    }

    // Adjust contentOffset to preserve page location based on values collected prior to location
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];

    // Reset
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;

}

#pragma mark -
#pragma mark Photos

// Get image if it has been loaded, otherwise nil
- (UIImage *)imageAtIndex:(NSUInteger)index {
    if (self.photos && index < self.photos.count) {

        // Get image or obtain in background
        GTGPhoto *photo = [self.photos objectAtIndex:index];
        if ([photo isImageAvailable]) {
            return [photo image];
        } else {
            [photo obtainImageInBackgroundAndNotify:self];
        }

    }
    return nil;
}

#pragma mark -
#pragma mark MWPhotoDelegate

- (void)photoDidFinishLoading:(GTGPhoto *)photo {
    NSUInteger index = [self.photos indexOfObject:photo];
    if (index != NSNotFound) {
        if ([self isDisplayingPageForIndex:index]) {

            //Tell page to display image again
            ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
            if (page) [page displayImage];

        }
    }
}

- (void)photoDidFailToLoad:(GTGPhoto *)photo {
    NSUInteger index = [self.photos indexOfObject:photo];
    if (index != NSNotFound) {
        if ([self isDisplayingPageForIndex:index]) {

            // Tell page it failed
            ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
            if (page)
                [page displayImageFailure];

        }
    }
}

#pragma mark -
#pragma mark Paging

- (void)tilePages {

    NSLog(@"Tile pages");
    // Calculate which pages should be visible
    // Ignore padding as paging bounces encroach on that
    // and lead to false page loads
    
    CGRect visibleBounds = _pagingScrollView.bounds;
    int iFirstIndex = (int) floorf((CGRectGetMinX(visibleBounds) + PADDING * 2) / CGRectGetWidth(visibleBounds));
    int iLastIndex = (int) floorf((CGRectGetMaxX(visibleBounds) - PADDING * 2 - 1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > self.photos.count - 1) iFirstIndex = self.photos.count - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > self.photos.count - 1) iLastIndex = self.photos.count - 1;

    // Recycle no longer needed pages
    for (ZoomingScrollView *page in _visiblePages) {
        if (page.index < (NSUInteger) iFirstIndex || page.index > (NSUInteger) iLastIndex) {
            [_recycledPages addObject:page];
            //NSLog(@"  ------  Removed page at index %i", page.index);
            page.index = NSNotFound; // empty
            [page removeFromSuperview];
        }
    }
    [_visiblePages minusSet:_recycledPages];

    // Add missing pages
    for (NSUInteger index = (NSUInteger) iFirstIndex; index <= (NSUInteger) iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ZoomingScrollView *page = [self dequeueRecycledPage];
            if (!page) {
                page = [[ZoomingScrollView alloc] init];
                page.photoBrowser = self;
            }
            [self configurePage:page forIndex:index];
            [_visiblePages addObject:page];
            [_pagingScrollView addSubview:page];
            //NSLog(@"  +++++++  Added page at index %i", page.index);
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (ZoomingScrollView *page in _visiblePages)
        if (page.index == index) return YES;
    return NO;
}

- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    ZoomingScrollView *thePage = nil;
    for (ZoomingScrollView *page in _visiblePages) {
        if (page.index == index) {
            thePage = page;
            break;
        }
    }
    return thePage;
}

- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.index = index;
}

- (ZoomingScrollView *)dequeueRecycledPage {
    ZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        //[[page retain] autorelease];
        [_recycledPages removeObject:page];
    }
    return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {

    NSLog(@"didStartViewingPageAtIndex %d", index);

    NSUInteger i;
    if (index > 0) {

        // Release anything < index - 1
        for (i = 0; i < index - 1; i++) {
            [(GTGPhoto *) [self.photos objectAtIndex:i] releasePhoto];
            //NSLog(@"Release image at index %i", i);
        }

        // Preload index - 1
        i = index - 1;
        if (i < self.photos.count) {
            [(GTGPhoto *) [self.photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self];
            //NSLog(@"Pre-loading image at index %i", i);
        }
    }
    if (index < self.photos.count - 1) {

        // Release anything > index + 1
        for (i = index + 2; i < self.photos.count; i++) {
            [(GTGPhoto *) [self.photos objectAtIndex:i] releasePhoto];
            //NSLog(@"Release image at index %i", i);
        }

        // Preload index + 1
        i = index + 1;
        if (i < self.photos.count) {
            [(GTGPhoto *) [self.photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self];
            //NSLog(@"Pre-loading image at index %i", i);
        }
    }
}

#pragma mark -
#pragma mark Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * self.photos.count, bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
    return CGRectMake(0, 20, self.view.bounds.size.width, height);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
    return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (_performingLayout || _rotating) return;

    // Tile pages
    [self tilePages];

    // Calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    int index = (int) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > self.photos.count - 1) index = self.photos.count - 1;
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Hide controls when dragging begins
    [self setControlsHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Update nav when page changes
    [self updateNavigation];
}

#pragma mark -
#pragma mark Navigation

- (void)updateNavigation {

    // Title
    if (self.photos.count > 1) {
        self.title = [NSString stringWithFormat:@"%i of %i", _currentPageIndex + 1, self.photos.count];
    } else {
        self.title = nil;
    }

    // Buttons
    _previousButton.enabled = (_currentPageIndex > 0);
    _nextButton.enabled = (_currentPageIndex < self.photos.count - 1);

}

- (void)jumpToPageAtIndex:(NSUInteger)index {

    // Change page
    if (index < self.photos.count) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        _pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
        [self updateNavigation];
    }

    // Update timer to give more time
    [self hideControlsAfterDelay];

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

#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    // Remember page index before rotation
    _pageIndexBeforeRotation = _currentPageIndex;
    _rotating = YES;

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    // Perform layout
    _currentPageIndex = _pageIndexBeforeRotation;
    [self performLayout];

    // Delay control holding
    [self hideControlsAfterDelay];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _rotating = NO;
}

#pragma mark -
#pragma mark Properties

- (void)setInitialPageIndex:(NSUInteger)index {
    if (![self isViewLoaded]) {
        if (index >= self.photos.count) {
            _currentPageIndex = 0;
        } else {
            _currentPageIndex = index;
        }
    }
}

@end
