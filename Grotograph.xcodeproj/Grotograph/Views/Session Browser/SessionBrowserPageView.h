//
//  GTGSessionBrowserPage.h
//  Grotograph
//
//  Created by Jet Basrawi on 01/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomingAssetView.h"

@class Session;
@class SessionBrowserViewController;
@protocol SessionBrowserPageDelegate;

@interface SessionBrowserPageView : UIView <PhotoViewDelegate>
@property(nonatomic) int pageIndex;

- (SessionBrowserPageView *)initWithFrame:(CGRect)rect andDelegate:(id <SessionBrowserPageDelegate>)delegate;
- (void)display:(Session *)session withPageIndex:(int)pageIndex withFrame:(CGRect)frame;
- (void)unload;

@end

@protocol SessionBrowserPageDelegate

- (void)gtgSessionBrowserPageDidDisplay:(SessionBrowserPageView *)page;

@end
