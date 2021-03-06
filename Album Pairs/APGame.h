//
//  APGame.h
//  Album Pairs
//
//  Created by Iain on 09/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCard.h"
#import "PairsGameDelegate.h"

typedef enum {
    APArtworkSourceDefault,
    APArtworkSourceLibrary,
    APArtworkSourceLastFm,
} APArtworkSource;

static const int WIDTH = 6;
static const int TIME_LIMIT= 90;

@interface APGame : NSObject

@property (nonatomic) id<PairsGameDelegate> delegate;

+ (NSString*)gameTypeToString:(APArtworkSource)gameType;

- (void)startTimer;
- (void)stopTimer;
- (BOOL)addCardFromImage:(UIImage*)image withIndex:(int)index title:(NSString*)title;
- (BOOL)pickCard:(APCard*)card;

@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) APCard *pick1;
@property (strong, nonatomic) APCard *pick2;
@property (strong, nonatomic) NSTimer *timer;
@property BOOL isGameOver;
@property int turnCount;
@property int errorCount;
@property int correctCount;
@property int timerCount;
@property int pairCount;
@property int cardSize;

@property NSMutableArray *hashes;

@end
