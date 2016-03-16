//
//  ImportImagesView.m
//  Grotograph
//
//  Created by Jet Basrawi on 16/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import "ImportImagesView.h"
#import "ImportImagesTableView.h"

@implementation ImportImagesView

@synthesize project, activityIndicatorView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [activityIndicatorView release];
    [project release];
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"%@/import", [project name]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        NSArray *imagesToImport = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if([imagesToImport count] > 0)
        {
            ImportImagesTableView *table = [[ImportImagesTableView alloc] init];
            table.imagesToImport = imagesToImport; 
            [self.view addSubview:table.view];
        }
        //[imagesToImport release];
    }
    
    [activityIndicatorView stopAnimating];
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

-(void) importImages:(NSArray *)fromArray
{
    for (NSString *s in fromArray) {
        NSLog(@"Image :%@", s);
    }
}

@end
