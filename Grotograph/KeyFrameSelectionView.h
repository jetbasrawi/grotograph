//
//  KeyFrameSelectionView.h
//  Grotograph
//
//  Created by Jet Basrawi on 12/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Session.h"

@interface KeyFrameSelectionView : UIViewController <UIScrollViewDelegate>
{
    
}

@property (nonatomic, strong) NSArray *photosInSession;
@property (nonatomic, unsafe_unretained) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) Session *currentSession;
@property int currentPage;

- (void) selectKeyFrameImage;

- (void) setDoneBarButton;

@end