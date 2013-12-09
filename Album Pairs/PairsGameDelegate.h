//
//  PairsGameDelegate.h
//  Album Pairs
//
//  Created by Iain on 09/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PairsGameDelegate <NSObject>

// correct
-(void)pairWasFoundWIthPick1:(APCard*)pick1 pick2:(APCard*)pick2;

// incorrect
-(void)pairWasNotFoundWIthPick1:(APCard*)pick1 pick2:(APCard*)pick2;

// game over
-(void)gameDidEndWithResult:(BOOL)result;

// timer did update
-(void)timerDidUpdate:(int)seconds;

@end
