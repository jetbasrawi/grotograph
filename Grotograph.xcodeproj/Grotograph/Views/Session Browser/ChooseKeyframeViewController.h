//
//  ChooseKeyframeViewController.h
//  Grotograph
//
//  Created by Jet Basrawi on 01/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//




@class Session;
@class Asset;
@protocol ChooseKeyframeViewControllerDelegate;

@interface ChooseKeyframeViewController : UIViewController <UITabBarControllerDelegate>
- (id)initWithSession:(Session *)session withDelegate:(id <ChooseKeyframeViewControllerDelegate>)delegate;
@end


@protocol ChooseKeyframeViewControllerDelegate

- (void) chooseKeyframeViewControllerDidFinishChoosingKeyframeWithPhoto:(Asset *)photo;

@end