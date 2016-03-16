#import "GTGAssetThumbnailView.h"
#import "Asset.h"
#import "GTGAssetLibraryManager.h"

@implementation GTGAssetThumbnailView {
    ALAsset *_asset;
    UIImageView *_overlayImageView;
    UIImageView *_thumbImageView;
    BOOL _enabled;
    id <GTGAssetThumbnailViewDelegate> __delegate;
}

@synthesize asset = _asset;
@synthesize enabled = _enabled;

- (id)initWithFrame:(CGRect)frame withDelegate:(id <GTGAssetThumbnailViewDelegate>)delegate {
    if ((self = [super initWithFrame:frame])) {
        _enabled = YES;
        __delegate = delegate;
        CGRect thumbFrame = CGRectMake(0, 0, 75, 75);

        _thumbImageView = [[UIImageView alloc] initWithFrame:thumbFrame];
        [_thumbImageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:_thumbImageView];

        _overlayImageView = [[UIImageView alloc] initWithFrame:thumbFrame];
        _overlayImageView.image = [UIImage imageNamed:@"Overlay.png"];
        _overlayImageView.hidden = YES;
        [self addSubview:_overlayImageView];
    }

    return self;
}

- (void)displayWithAsset:(ALAsset *)asset {

    self.asset = asset;

    [__delegate thumbnailWillDisplay:self];

    //TODO:Make this asynchronous

    _thumbImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];

    if (!_enabled) {
        _overlayImageView.hidden = YES;
        _thumbImageView.alpha = 0.5;
    }
    else {
        _thumbImageView.alpha = 1.0;
    }
}

- (void)displayWithImageSource:(id)imageSource {


    if ([imageSource isKindOfClass:[ALAsset class]]) {
        [self displayWithAsset:imageSource];
    }
    else if ([imageSource isKindOfClass:[NSURL class]]) {
        [self displayWithURL:imageSource];
    }
    else if ([imageSource isKindOfClass:[Asset class]]) {
        [self displayWithURL:[NSURL URLWithString:[(Asset *) imageSource url]]];
    }
    else {
        NSLog(@"Unknown imageSource type");
    }
}

- (void)displayWithURL:(NSURL *)url {

    ALAssetsLibrary *library = [GTGAssetLibraryManager defaultAssetsLibrary];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
                 if (asset) {
                     [self performSelectorOnMainThread:@selector(displayWithAsset:) withObject:asset waitUntilDone:NO];
                 } else {
                     NSLog(@"Asset not found");
                 }
             }
            failureBlock:^(NSError *error) {
                NSLog(@"Error loading asset");
            }];

}


- (void)toggleSelection {
    if (!_enabled)
        return;

    _overlayImageView.hidden = !_overlayImageView.hidden;

    [__delegate thumbnailDidToggleSelection:self];
}

- (BOOL)isSelected {
    return !_overlayImageView.hidden;
}

- (void)setIsSelected:(BOOL)selected {
    if ([self isSelected] != selected)
        [self toggleSelection];
}

- (void)unloadImage {
       _thumbImageView.image = nil;
}

@end

