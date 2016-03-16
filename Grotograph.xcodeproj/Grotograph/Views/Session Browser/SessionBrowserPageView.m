
#import "SessionBrowserPageView.h"
#import "Asset.h"
#import "ActionRequiredView.h"

@implementation SessionBrowserPageView {
@private

    __unsafe_unretained id <SessionBrowserPageDelegate> __delegate;
    __unsafe_unretained Session *_session;

    int _pageIndex;
    UITextView *_textView;
    ZoomingAssetView *_zoomingAssetView;
    ActionRequiredView *_noKeyframeView;
}

@synthesize pageIndex = _pageIndex;

- (SessionBrowserPageView *)initWithFrame:(CGRect)rect andDelegate:(id <SessionBrowserPageDelegate>)delegate {
    self = [super initWithFrame:rect];
    if (self) {
        __delegate = delegate;
    }
    return self;
}

#pragma mark - loading and unloading public methods

- (CGRect)getFrameForActionRequiredView {

    CGRect rect = self.bounds;
    rect.origin.y += 64;
    rect.size.height -= 108;
    return rect;

}

- (void)display:(Session *)session withPageIndex:(int)pageIndex withFrame:(CGRect)frame {

    NSLog(@"Display");

    [self setFrame:frame];

    _session = session;
    self.pageIndex = pageIndex;

    if (_textView)
        _textView.text = [NSString stringWithFormat:@"PageIndex = %d", self.pageIndex];

    if (!session.keyFrame) {

        if (_zoomingAssetView) {
            _zoomingAssetView.hidden = YES;
        }

        _noKeyframeView = [[ActionRequiredView alloc] initWithFrame:[self getFrameForActionRequiredView] withHeading:@"No Keframe" withMessage:@"Choose your favourite image from this day."];
        [self addSubview:_noKeyframeView];

    } else {

        if (!_zoomingAssetView) {
            _zoomingAssetView = [[ZoomingAssetView alloc] initWithFrame:frame andDelegate:self];
        }

        _zoomingAssetView.hidden = NO;

        if (_zoomingAssetView.superview == nil) {
            [self addSubview:_zoomingAssetView];
        }
        _zoomingAssetView.frame = self.bounds;
        [_zoomingAssetView display:[GTGAsset gtgAssetWithAsset:session.keyFrame]];
    }

    [self setNeedsDisplay];

}

- (void)unload {

    if (_zoomingAssetView) {
        [_zoomingAssetView removeFromSuperview];
        [_zoomingAssetView unload];

    }
}

#pragma mark - photoview delegate methods
- (void)photoViewDidDisplay {
    [__delegate gtgSessionBrowserPageDidDisplay:self];
}

- (void)photoViewDidReceiveDoubleTap:(CGPoint)touchPoint {
    //To change the template use AppCode | Preferences | File Templates.

}

- (void)photoViewDidReceiveSingleTap:(CGPoint)touchPoint {
    //To change the template use AppCode | Preferences | File Templates.

}


@end
