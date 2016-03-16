//
//  CameraOverlayView.h
//  Grotograph
//
//  Created by Jet Basrawi on 01/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraOverlayViewControllerDelegate

- (void)doneButtonPressed;
- (void)takePhotoButtonPressed;

@end


@interface CameraOverlayView : UIViewController

@property (nonatomic, unsafe_unretained) id<CameraOverlayViewControllerDelegate> delegate;

@end


