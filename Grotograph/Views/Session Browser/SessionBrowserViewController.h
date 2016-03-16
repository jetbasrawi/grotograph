//
//  ProjectMainView.h
//  Grotograph
//
//  Created by Jet Basrawi on 20/12/2011.
//  Copyright (c) 2011 Free for all products Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraOverlayView.h"
#import "ChooseKeyframeViewController.h"
#import "SessionBrowserPageView.h"
#import "ImportAssetsViewController.h"

@class Project;

@interface SessionBrowserViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewControllerDelegate, ChooseKeyframeViewControllerDelegate, SessionBrowserPageDelegate, ImportAssetsViewControllerDelegate>

- (void)logFrames:(NSString *)heading;

- (id)initWithProject:(Project *)project;

- (void)displayEditMode;

- (void)jumpToPageAtIndex:(int)index;

- (void)hideControlsAfterDelay;

- (void)toggleControls;

- (void)setNavBarForChoosingKeyframe;


@end
