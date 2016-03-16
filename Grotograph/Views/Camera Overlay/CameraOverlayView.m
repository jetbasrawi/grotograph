//
//  CameraOverlayView.m
//  Grotograph
//
//  Created by Jet Basrawi on 01/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import "CameraOverlayView.h"

@interface CameraOverlayView()

- (IBAction)takePicture;
- (IBAction)finishPicking;

@end

@implementation CameraOverlayView

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private methods

- (IBAction)takePicture
{
    [self.delegate takePhotoButtonPressed];
}

- (IBAction)finishPicking
{
    [self.delegate doneButtonPressed];
}

@end
