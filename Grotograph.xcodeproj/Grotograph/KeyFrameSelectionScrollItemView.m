
#import "KeyFrameSelectionScrollItemView.h"
#import <ImageIO/CGImageSource.h>
#import "FileSaver.h"
#import "ExifDataExtractor.h"

@interface KeyFrameSelectionScrollItemView()

@property (nonatomic, strong) Session *currentSession;
@property (nonatomic, strong) NSArray *photosInSession;

- (void)loadThumb:(NSString*)imageURL withNumberOfAttemptsToLoadImageSoFar:(int)numberOfAttempts;

@end

@implementation KeyFrameSelectionScrollItemView

@synthesize imageView;
@synthesize currentSession;
@synthesize activityIndicator;
@synthesize photosInSession;

- (id)initWithPageNumber:(int)page andSession:(Session *)session andPhotos:(NSArray *)photos
{
    if (self = [super initWithNibName:@"KeyFrameSelectionScrollViewItemView" bundle:nil])
    {
        pageNumber = page;
        self.currentSession = session;
        self.photosInSession = photos;
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"Scroll item did load Pagenumber = %d", pageNumber);
    
    Photo *photo = (Photo *)[self.photosInSession objectAtIndex:pageNumber];
    NSString *imageURL = photo.url; 
    [self loadThumb:imageURL withNumberOfAttemptsToLoadImageSoFar:0];
}

- (void)loadThumb:(NSString*)imageURL withNumberOfAttemptsToLoadImageSoFar:(int)numberOfAttempts
{
    NSLog(@"MyViewController.loadThumb - url: %@", imageURL);
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        
        NSLog(@"Image %d is not nil. Setting imageView", pageNumber);
           
        CGFloat width;
        CGFloat height;
        float angleInDegrees = 0.0;
        CGRect rect = self.imageView.frame;
        
        switch (rep.orientation) {
            case ALAssetOrientationUp:
                angleInDegrees = 90.0; 
                width = self.imageView.frame.size.height;
                height = self.imageView.frame.size.width;
                rect = CGRectMake(-70, 70.0, width, height);
                break;
            case ALAssetOrientationDown:
                angleInDegrees = -90.0; 
                width = self.imageView.frame.size.height;
                height = self.imageView.frame.size.width;
                rect = CGRectMake(-70, 70.0, width, height);
                break;
            case ALAssetOrientationLeft:
                angleInDegrees = 180.0;      
                
            default:
                break;
        }
        
        CGImageRef iref = [rep fullScreenImage];
        if (iref) {  
            
            if (angleInDegrees != 0) {
                [self.imageView setFrame:rect];
                CGFloat angleInRadians = (angleInDegrees / 57.2958);
                CGAffineTransform rotate = CGAffineTransformMakeRotation( angleInRadians );
                [self.imageView setTransform:rotate];
            }
            
            UIImage *image = [UIImage imageWithCGImage:iref];
            [self.imageView setImage:image];
        
            [self.activityIndicator stopAnimating];
        }
    };
    
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Cant get image - %@",[myerror localizedDescription]);
        sleep(1);
        NSLog(@"Attempting load again");
        [self loadThumb:imageURL withNumberOfAttemptsToLoadImageSoFar:numberOfAttempts + 1];
    };
    
    if(imageURL && [imageURL length] && ![[imageURL pathExtension] isEqualToString:@"someextensionwedontwant"])
    {
        NSURL *assetURL = [NSURL URLWithString:imageURL];
        ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary assetForURL:assetURL
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
}



@end
