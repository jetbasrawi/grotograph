//
//  EmptyProjectView.m
//  Grotograph
//
//  Created by Jet Basrawi on 01/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActionRequiredView.h"

@implementation ActionRequiredView

- (CGRect)getFrameForTextView {
    return CGRectMake(100, 100, 100, 100);
}

- (id)initWithFrame:(CGRect)frame withHeading:(NSString *)heading withMessage:(NSString *)message {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];

        UIImage *emptyProjectImage = [UIImage imageNamed:@"emptyprojectimage.png"];
        CGFloat imgX = CGRectGetMidX(self.bounds) - (emptyProjectImage.size.width / 2);

        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, 40, emptyProjectImage.size.width, emptyProjectImage.size.height)];
        [imgView setImage:emptyProjectImage];
        [self addSubview:imgView];


        UITextView *headingTextView = [[UITextView alloc] initWithFrame:CGRectMake(imgX, imgView.frame.origin.y + imgView.frame.size.height + 10, imgView.frame.size.width, 100)];
        UIFont *headingFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize] + 4];
        headingTextView.font = headingFont;
        headingTextView.textAlignment = UITextAlignmentCenter;
        headingTextView.textColor = [UIColor grayColor];
        headingTextView.text = heading;

        [self addSubview:headingTextView];

        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(imgX, imgView.frame.origin.y + imgView.frame.size.height + 40, imgView.frame.size.width, 100)];
                textView.text = message;
                textView.textColor = [UIColor grayColor];
        UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];

        textView.font = boldFont;
        textView.textAlignment = UITextAlignmentCenter;
        [self addSubview:textView];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
