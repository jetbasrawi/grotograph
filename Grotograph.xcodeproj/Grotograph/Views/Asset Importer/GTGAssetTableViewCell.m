#import "GTGAssetTableViewCell.h"
#import "GTGAssetThumbnailView.h"

#define PADDING 4
#define THUMB_COUNT 4
#define FRAME_WIDTH 75
#define FRAME_HEIGHT 75

@implementation GTGAssetTableViewCell {
    NSArray *_imageSources;
    BOOL _isLaidOut;
    NSMutableArray *_thumbnails;
}

- (id)initWithImageSources:(NSArray *)imageSources withThumbnailDelegate:(id <GTGAssetThumbnailViewDelegate>)thumbnailDelegate reuseIdentifier:(NSString *)identifier {

    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        _imageSources = imageSources;
        _isLaidOut = NO;

        CGRect frame = CGRectMake(PADDING, PADDING, FRAME_WIDTH, FRAME_HEIGHT);
        _thumbnails = [[NSMutableArray alloc] init];

        for (int i = 0; i < THUMB_COUNT; i++) {

            GTGAssetThumbnailView *thumb = [[GTGAssetThumbnailView alloc] initWithFrame:frame withDelegate:thumbnailDelegate];
            [thumb addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:thumb action:@selector(toggleSelection)]];
            [_thumbnails addObject:thumb];
            [self addSubview:thumb];

            frame.origin.x = frame.origin.x + frame.size.width + PADDING;
        }
    }

    return self;
}

- (void)setImageSources:(NSArray *)imageSources {
    _isLaidOut = NO;
    _imageSources = imageSources;
}

- (void)layoutSubviews {

    if (_isLaidOut) return;

    int count = 0;
    for (id object in _imageSources) {
        GTGAssetThumbnailView *thumb = [_thumbnails objectAtIndex:count];
        [thumb displayWithImageSource:object];
        count++;
    }
    _isLaidOut = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    //NSLog(@"Prepare for reuse %@", self);

    for(int i=0; i< THUMB_COUNT; i++){
        GTGAssetThumbnailView *thumb = [_thumbnails objectAtIndex:i];
        [thumb unloadImage];
    }
    
}


@end
