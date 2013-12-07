//
//  APCard.m
//  
//
//  Created by Iain on 07/12/2013.
//
//

#import <MediaPlayer/MediaPlayer.h>

#import "APCard.h"

@implementation APCard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithImage:(UIImage*)image albumId:(int)albumId
{
    self = [self init];
    self.albumId = albumId;
    self.albumArtwork = image;
    self.back = [UIImage imageWithContentsOfFile:@"card-back.png"];

    UIColor *grey = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0f];
    self.layer.borderColor = grey.CGColor;
    self.layer.borderWidth = 3.0;

    [self hide];

    return self;
}

- (id)initWithLastFmAlbum:(NSDictionary*)album albumId:(int)albumId
{
    self = [self init];

    NSURL *url =[album valueForKey:@"image"];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    
    self.albumId = albumId;
    
    self.albumArtwork = image;
    self.back = [UIImage imageNamed:@"card-back.png"];
    
    NSLog(@"%@", self.back);
    
    UIColor *grey = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0f];
    self.layer.borderColor = grey.CGColor;
    self.layer.borderWidth = 3.0;

    [self hide];
    
    return self;
}

- (void)show
{
    self.layer.opacity = 1.0;
    self.shown = true;
    
    [self setImage:self.albumArtwork];
    
//    [UIView transitionWithView:containerView
//                      duration:0.2
//                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                    animations:^{ [fromView removeFromSuperview]; [containerView addSubview:toView]; }
//                    completion:NULL];
    
}

- (void)highlight
{
    self.layer.opacity = 1.0;
    self.shown = true;

    UIColor *green = [UIColor colorWithRed:0.2 green:1.0 blue:0.2 alpha:1.0f];

    self.layer.borderColor = green.CGColor;
}

- (void)hide
{
//    NSLog(@"hide");
    self.layer.opacity = 0.2;
    self.shown = false;
    
    [self setImage:self.back];
}

- (void)remove
{
    self.layer.opacity = 0.0;
    self.shown = false;
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
