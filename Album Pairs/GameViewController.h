//
//  ViewController.h
//  Album Pairs
//
//  Created by Iain on 07/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APGame.h"
#import "GAITrackedViewController.h"

@interface GameViewController : GAITrackedViewController

@property (nonatomic) APArtworkSource artworkSource;

- (NSArray*) shuffle:(NSArray*)input;
+ (CGRect) frameForPositionX:(int) x y:(int)y;

@end
