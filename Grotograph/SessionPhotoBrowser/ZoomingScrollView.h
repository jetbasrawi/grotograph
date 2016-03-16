//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageViewTap.h"
#import "UIViewTap.h"

@class SessionPhotoBrowser;

@interface ZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate> {
	
	// Browser
    SessionPhotoBrowser * photoBrowser;
	
	// State
	NSUInteger index;
	
	// Views
	UIViewTap *tapView; // for background taps
	UIImageViewTap *photoImageView;
	UIActivityIndicatorView *spinner;
	
}

// Properties
@property (nonatomic) NSUInteger index;

//TODO: This should be unsafe unretained
@property (nonatomic, strong) SessionPhotoBrowser *photoBrowser;

// Methods
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end
