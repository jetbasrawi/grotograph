//
//  Created by jet_basrawi on 22/12/2011.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "UIViewTap.h"
#import "UIImageViewTap.h"
#import "GTGAsset.h"
#import "Session.h"

@class SessionBrowserViewController;
@protocol PhotoViewDelegate;

@interface ZoomingAssetView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate, GTGAssetDelegate> {
}

@property(nonatomic) BOOL zoomEnabled;

- (id)initWithFrame:(CGRect)frame andDelegate:(id <PhotoViewDelegate>)delegate;

- (void) display:(GTGAsset *)photo;
- (void) unload;

- (void)displayEditMode;
//- (Photo *)getPhoto;
//
//- (void)saveChanges;
@end


@protocol PhotoViewDelegate

@optional
- (void) photoViewDidDisplay;
@optional
- (void) photoViewDidReceiveSingleTap:(CGPoint)touchPoint;
- (void) photoViewDidReceiveDoubleTap:(CGPoint)touchPoint;

@end