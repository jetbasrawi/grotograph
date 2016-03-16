//
//  ImportImagesView.h
//  Grotograph
//
//  Created by Jet Basrawi on 16/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface ImportImagesView : UIViewController
{
    Project *project;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
-(void) importImages:(NSArray *)fromArray;

@end
