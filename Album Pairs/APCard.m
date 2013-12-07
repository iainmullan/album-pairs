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
    
    [self setImage:image];
    
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
    
    [self setImage:image];// = image;
    
    [self hide];
    
    return self;
}

- (void)show
{
    self.layer.opacity = 1.0;
    self.shown = true;
}

- (void)hide
{
//    NSLog(@"hide");
    self.layer.opacity = 0.2;
    self.shown = false;
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
