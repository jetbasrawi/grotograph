
#import "SessionInfoOverlayViewController.h"
#import "Session.h"
#import "Asset.h"

@implementation SessionInfoOverlayViewController {
    Session *_session;
    NSUInteger _pageIndex;
}
- (id)initWithSession:(Session *)session withPageIndex:(NSUInteger)pageIndex {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _session = session;
        _pageIndex = pageIndex;
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

    self.view.backgroundColor = [UIColor clearColor];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 68.0, self.view.bounds.size.width - 40, self.view.bounds.size.height - 100)];
    textView.text = [NSString stringWithFormat:@"PageIndex = %d Keyframe url = %@", _pageIndex, _session.keyFrame.url];

    [self.view addSubview:textView];

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
