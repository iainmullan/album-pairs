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

-(void)setArtwork:(UIImage*)image size:(int)size
{
    
    CGRect frame = CGRectMake(0, 0, size, size);
    
    self.front = [[UIImageView alloc] initWithImage:image];
    self.front.frame = frame;

    self.back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card-back.png"]];
    self.back.frame = frame;    
}

- (id)initWithImage:(UIImage*)image size:(int)size albumId:(int)albumId title:(NSString*)title
{
    self = [self init];
    self.albumId = albumId;
    self.title = title;
    self.size = size;

    [self setArtwork:image size:size];

    UIColor *grey = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0f];
    self.layer.borderColor = grey.CGColor;
    self.layer.borderWidth = 3.0;

    [self hide];

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
