
#import "ScanLibrariesViewController.h"
#import "ActionRequiredView.h"

@implementation ScanLibrariesViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frame = [[[UIApplication sharedApplication] keyWindow] frame];
    self.view = [[ActionRequiredView alloc]
            initWithFrame:frame
              withHeading:@"Scan libraries"
              withMessage:@"Please grant access to location data"];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *scanButton = [[UIBarButtonItem alloc] initWithTitle:@"Scan"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(scanLibraries)];
    self.navigationItem.rightBarButtonItem = scanButton;
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

@end
