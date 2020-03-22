//
//  APGame.m
//  Album Pairs
//
//  Created by Iain on 09/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "APGame.h"

@implementation APGame

-(APGame*)init
{
    self = [super init];
    
    self.isGameOver = false;
    self.cards = [[NSMutableArray alloc] init];

    self.hashes = [[NSMutableArray alloc] init];
    
    self.turnCount = 0;
    self.errorCount = 0;
    self.correctCount = 0;
    
    self.pairCount = (WIDTH*WIDTH)/2;

    return self;
}

- (void)timerTick
{
    
    int s = self.timerCount--;
    if (s == 0) {
        [self gameOver];
    }

    [self.delegate timerDidUpdate:s];
}

- (void)startTimer
{
    [self.timer invalidate];
    self.timerCount = TIME_LIMIT;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

-(BOOL)pickCard:(APCard*)card
{
    if (self.pick1 == nil) {
        self.pick1 = card;
        return YES;
    } else if (self.pick2 == nil) {
        self.pick2 = card;
        
        if (self.pick1.albumId == self.pick2.albumId) {
            [self correct];
        } else {
            [self incorrect];
        }
        
        return YES;
    }

    return NO;
}

-(void)correct
{
    //    AudioServicesPlaySystemSound (1025);
    
    self.turnCount++;
    self.correctCount++;
    
    self.timerCount += 5;
    [self.delegate pairWasFoundWithPick1:self.pick1 pick2:self.pick2];
    [self reset];
    
    if (self.correctCount == self.pairCount) {
        [self complete];
    }
    
}

-(void)incorrect
{
    //    AudioServicesPlaySystemSound(1000);
    
    self.turnCount++;
    self.errorCount++;
    
    [self.delegate pairWasNotFoundWithPick1:self.pick1 pick2:self.pick2];
    [self reset];
}

-(void)complete
{
    [self.timer invalidate];
    [self.delegate gameDidEndWithResult:YES];
}

-(void)gameOver
{
    self.isGameOver = true;
    [self.timer invalidate];
    [self.delegate gameDidEndWithResult:NO];
}

-(void)stopTimer
{
    [self.timer invalidate];
}

-(void)reset
{
    self.pick1 = nil;
    self.pick2 = nil;
}


-(BOOL)addCardFromImage:(UIImage*)image withIndex:(int)index title:(NSString*)title
{
    
    NSString *hash = [self imageHash:image];
    if ([self.hashes containsObject:hash]) {
        NSLog(@"found duplicate image");
        return false;
    }
    
    [self.hashes addObject:hash];
    
    [self.cards addObject:[[APCard alloc] initWithImage:image size:self.cardSize albumId:index title:title]];
    [self.cards addObject:[[APCard alloc] initWithImage:image size:self.cardSize albumId:index title:title]];
    
    return true;
}

-(NSString*)imageHash:(UIImage*)image
{
    unsigned char result[16];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    CC_MD5([imageData bytes], [imageData length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return imageHash;
}


+ (NSString*)gameTypeToString:(APArtworkSource)gameType {
    NSString *result = nil;
    
    switch(gameType) {
        case APArtworkSourceDefault:
            result = @"Classic";
            break;
        case APArtworkSourceLastFm:
            result = @"LastFm";
            break;
        case APArtworkSourceLibrary:
            result = @"Library";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected gameType"];
    }
    
    return result;
}

@end
