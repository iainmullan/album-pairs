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

-(void)setArtwork:(UIImage*)image
{
    
    CGRect frame = CGRectMake(0, 0, CARD_SIZE, CARD_SIZE);
    
    self.albumArtwork = [[UIImageView alloc] initWithImage:image];
    self.albumArtwork.frame = frame;

    self.back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card-back.png"]];
    self.back.frame = frame;
}

- (id)initWithImage:(UIImage*)image albumId:(int)albumId title:(NSString*)title
{
    self = [self init];
    self.albumId = albumId;
    self.title = title;

    [self setArtwork:image];

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
    
    [UIView transitionWithView:self
                      duration:0.6
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ [self.back removeFromSuperview]; [self addSubview:self.albumArtwork]; }
                    completion:NULL];
    
}

- (void)highlight
{
    self.shown = true;

    UIColor *green = [UIColor colorWithRed:0.2 green:1.0 blue:0.2 alpha:1.0f];
    self.layer.borderColor = green.CGColor;
}

- (void)hide
{
    self.layer.opacity = 0.3;
    self.shown = false;
//    return;
    
    [UIView transitionWithView:self
                      duration:0.6
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ [self.albumArtwork removeFromSuperview]; [self addSubview:self.back]; }
                    completion:NULL];
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
