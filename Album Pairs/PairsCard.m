//
//  PairsCard.m
//  Album Pairs
//
//  Created by Iain on 10/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import "PairsCard.h"

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
    self.layer.opacity = 1.0;
    self.shown = true;
    
    [UIView transitionWithView:self
                      duration:0.6
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ [self.back removeFromSuperview]; [self addSubview:self.front]; }
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
