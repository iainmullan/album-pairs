//
//  PairsCard.m
//  Album Pairs
//
//  Created by Iain on 10/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import "PairsCard.h"

static const float FLIP_SPEED = 0.6;

@interface PairsCard ()

@end

@implementation PairsCard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)show
{
    self.shown = true;

    self.layer.opacity = 1.0;
    
    [UIView transitionWithView:self
                      duration:FLIP_SPEED
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.back removeFromSuperview];
                        [self addSubview:self.front];
                    }
                    completion:^(BOOL finished){
                    }];
    
}
- (void)doHighlight
{
    self.front.layer.opacity = 0.5;
    
    UIImageView *tick = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
    
    int tickSize = 40;
    int pos = (self.size / 2) - (tickSize / 2);
    tick.frame = CGRectMake(pos, pos, tickSize, tickSize);
    
    [self insertSubview:tick
           aboveSubview:self.front];
   
}

- (void)highlight
{
    [NSTimer scheduledTimerWithTimeInterval:FLIP_SPEED target:self selector:@selector(doHighlight) userInfo:Nil repeats:NO];

}

- (void)hide
{

    self.shown = false;
    
    [UIView transitionWithView:self
                      duration:FLIP_SPEED
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ [self.front removeFromSuperview]; [self addSubview:self.back]; }
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
