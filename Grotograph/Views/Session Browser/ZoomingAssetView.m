#import "ZoomingAssetView.h"
#import "Asset.h"
#import "AssetTransformation.h"

#define MAX_SCALE 20.0

@interface ZoomingAssetView ()
- (void)setMaxMinZoomScalesForCurrentBounds;
@end

@implementation ZoomingAssetView {

@private
    // Views
    UIViewTap *_tapView; // for background taps
    UIImageViewTap *_imageView;
    UIActivityIndicatorView *_spinner;
    __unsafe_unretained id <PhotoViewDelegate> _photoViewDelegate;
    GTGAsset *_photoImage;
    BOOL _zoomEnabled;
    GTGAsset *_asset;
}

@synthesize zoomEnabled = _zoomEnabled;

- (void)dealloc {
    NSLog(@" - - < dealloc PhotoView");
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id <PhotoViewDelegate>)delegate {
    if ((self = [super initWithFrame:frame])) {

        _photoViewDelegate = delegate;

        NSLog(@"PhotoView initWithFrame");
        self.clipsToBounds = YES;
        self.scrollEnabled = NO;
        self.zoomEnabled = YES;

        // Tap view for background
        _tapView = [[UIViewTap alloc] initWithFrame:frame];
        _tapView.tapDelegate = self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tapView.backgroundColor = [UIColor blackColor];
        [self addSubview:_tapView];

        // Image view
        _imageView = [[UIImageViewTap alloc] initWithFrame:CGRectZero];
        _imageView.tapDelegate = self;
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_imageView];

        // Spinner
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.hidesWhenStopped = YES;
        _spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
                UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_spinner];

        // Setup
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    }
    return self;
}

- (void)display:(GTGAsset *)asset {

    _asset = asset;
    [_photoImage loadAsynchronousThenNotify:self];
}

- (void)unload {
    _photoImage = nil;
}

- (void)setMaxMinZoomScalesForCurrentBounds {

    // Bail
    if (_imageView.image == nil)
        return;

    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.frame.size;

    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible

    // If image is smaller than the screen then ensure we show it at
    // min scale of 1
    if (xScale > 1 && yScale > 1) {
        minScale = 1.0;
    }

    // Calculate Max
    CGFloat maxScale = MAX_SCALE;
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        CGFloat scale = [[UIScreen mainScreen] scale];
        maxScale = maxScale / scale;
    }

    // Set
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;

    if (!_asset.cdAsset || _asset.cdAsset.transformation.zoomscale <= 0) {
        self.zoomScale = minScale;
    }
    else {
        self.zoomScale = [_asset.cdAsset.transformation.zoomscale floatValue];
    }

    // Reset position
    _imageView.frame = CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height);

    [self setNeedsLayout];

}


- (void)assetDidFinishLoading:(GTGAsset *)asset {

    //Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);

    UIImage *img = asset.image;
    _imageView.image = img;
    _imageView.hidden = NO;

    // Setup photo frame
    CGRect imageViewFrame;
    imageViewFrame.origin = CGPointZero;
    imageViewFrame.size = img.size;
    _imageView.frame = imageViewFrame;
    self.contentSize = imageViewFrame.size;

    [self setMaxMinZoomScalesForCurrentBounds];

    [_photoViewDelegate photoViewDidDisplay];

}

- (void)photoDidFailToLoad:(GTGAsset *)asset {
    //TODO:

}

#pragma mark -
#pragma mark UIView Layout

- (void)layoutSubviews {

    // Update tap view frame
    _tapView.frame = self.bounds;

    // Spinner
    if (!_spinner.hidden)
        _spinner.center = CGPointMake(floorf(self.bounds.size.width / 2.0),
                floorf(self.bounds.size.height / 2.0));
    // Super
    [super layoutSubviews];

    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;

//    NSLog(@"Image View Frame Origin %f, %f", frameToCenter.origin.x, frameToCenter.origin.y);
//    NSLog(@"Image View Frame Size %f x %f", frameToCenter.size.width, frameToCenter.size.width);
//    NSLog(@"Image View Center %f, %f", _imageView.center.x, _imageView.center.y);
//
//    NSLog(@"Zoomscale %f", self.zoomScale);

    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }

    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }

    // Center
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter))
        _imageView.frame = frameToCenter;

//    NSLog(@"Image View Frame Origin %f, %f", frameToCenter.origin.x, frameToCenter.origin.y);
//    NSLog(@"Image View Frame Size %f x %f", frameToCenter.size.width, frameToCenter.size.width);
//    NSLog(@"Image View Center %f, %f", _imageView.center.x, _imageView.center.y);
//    NSLog(@"Zoomscale %f", self.zoomScale);
//    NSLog(@"transform a %f", _imageView.transform.a);
//    NSLog(@"transform b %f", _imageView.transform.b);
//    NSLog(@"transform c %f", _imageView.transform.c);
//    NSLog(@"transform c %f", _imageView.transform.d);
//    NSLog(@"transform tx %f", _imageView.transform.tx);
//    NSLog(@"transform ty %f", _imageView.transform.ty);
//
//    NSLog(@"Scroll view content offset %f, %f", self.contentOffset.x, self.contentOffset.y);

}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //TODO:
    //[photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    //TODO:
    //[photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //TODO:
    //[photoBrowser hideControlsAfterDelay];
}

#pragma mark -
#pragma mark Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    [_photoViewDelegate photoViewDidReceiveSingleTap:touchPoint];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {

    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:_photoViewDelegate];

    // Zoom
    if (self.zoomScale == self.maximumZoomScale) {

        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];

    } else {

        // Zoom in
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }

    [_photoViewDelegate photoViewDidReceiveDoubleTap:touchPoint];
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}

- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view]];
}

- (void)displayEditMode {

    NSLog(@"Display edit mode.");

    self.zoomEnabled = YES;
}

- (void)saveChanges {
    _asset.cdAsset.transformation.offset_x = [NSNumber numberWithFloat:self.contentOffset.x];
    _asset.cdAsset.transformation.offset_y = [NSNumber numberWithFloat:self.contentOffset.y];
    _asset.cdAsset.transformation.zoomscale = [NSNumber numberWithFloat:self.zoomScale];

    NSError *error = nil;
    [_asset.cdAsset.managedObjectContext save:&error];

    if (error) {
        NSLog(@"Errdor saving photo transformations.");
    }


}
@end
