//
//  KeyFrameSelectionView.m
//  Grotograph
//
//  Created by Jet Basrawi on 12/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import "KeyFrameSelectionView.h"
#import "KeyFrameSelectionScrollItemView.h"
#import "Photo.h"
#import "NSArray-Set.h"
#import <ImageIO/CGImageSource.h>
#import "ExifDataExtractor.h"
#import "FileSaver.h"

@interface KeyFrameSelectionView (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (UIImage *)loadImage:(NSString *) imageName;
- (UIImage *)loadThumb:(NSString *) imageName;

@end

@implementation KeyFrameSelectionView

@synthesize photosInSession = _photosInSession;
@synthesize scrollView = _scrollView;
@synthesize viewControllers = _viewControllers;
@synthesize currentSession = _currentSession;
@synthesize currentPage = _currentPage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (void)viewDidLoad
{
    [self setDoneBarButton];
    
	self.photosInSession = [NSArray 
                            arrayByOrderingSet:self.currentSession.photos 
                            byKey:@"dateCreated" 
                            ascending:YES];
    
    int numberOfImagesInSession = [self.currentSession.photos count];
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < numberOfImagesInSession; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfImagesInSession, self.self.self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    [self loadScrollViewWithPage:2];
}

-(void)viewWillAppear:(BOOL)animated    
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.translucent = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
  
}

- (void)loadScrollViewWithPage:(int)page
{
    int numberOfImagesInSession = [self.currentSession.photos count];
    
    if (page < 0)
        return;
    if (page >= numberOfImagesInSession)
        return;
 
     NSLog(@"loadScrollViewWithPage %d", page);
    
    // replace the placeholder if necessary
    KeyFrameSelectionScrollItemView *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[KeyFrameSelectionScrollItemView alloc] initWithPageNumber:page andSession:self.currentSession andPhotos:self.photosInSession];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // if not already added to the scroll view, add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        NSLog(@"Adding new item to scroll view at page %d", page);
        
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

- (UIImage*)loadThumb:(NSString*)imageName 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@.jpg", imageName]];
    NSLog(@"Loading photo at filename %@", fullPath);
    return [UIImage imageWithContentsOfFile:fullPath];
}


- (UIImage*)loadImage:(NSString*)imageName 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imageName]];
    return [UIImage imageWithContentsOfFile:fullPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page != self.currentPage)
    {
        self.currentPage = page;
        [self setTitle:[NSString stringWithFormat:@"%d of %d", page + 1, [self.photosInSession count]]];
    }
}


// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadScrollViewWithPage:self.currentPage - 2];
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage + 1];
    [self loadScrollViewWithPage:self.currentPage + 2];
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) selectKeyFrameImage
{
    Photo *photo = [self.photosInSession objectAtIndex:self.currentPage];
    self.currentSession.keyFrame = photo;
    
    NSLog(@"Saving keyframe");    
    NSError *error = nil;
    [self.currentSession.managedObjectContext save:&error];
    NSLog(@"Saved");
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDoneBarButton
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] 
                               initWithTitle:@"Select" 
                               style:UIBarButtonItemStyleDone 
                               target:self 
                               action:@selector(selectKeyFrameImage)];
    
    self.navigationItem.rightBarButtonItem = button;
}


@end
