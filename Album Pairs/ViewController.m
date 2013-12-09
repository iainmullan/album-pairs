//
//  ViewController.m
//  Album Pairs
//
//  Created by Iain on 07/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import <CommonCrypto/CommonDigest.h>

#import <MediaPlayer/MediaPlayer.h>

#include "TargetConditionals.h"

#import "ViewController.h"
#import "LastFm.h"
#import "APCard.h"

static const int WIDTH = 6;
static const int TIME_LIMIT= 60;

@interface ViewController ()

@property (strong, nonatomic) UIView *gridView;
@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) MPMediaItemCollection *playlist;
@property (strong, nonatomic) MPMusicPlayerController *player;

@property (strong, nonatomic) APCard *pick1;
@property (strong, nonatomic) APCard *pick2;
@property (strong, nonatomic) UIButton *restartGameButton;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) UILabel *nowPlayingLabel;

@property (strong, nonatomic) UIView *playlistView;

@property BOOL isBeingIncorrect;
@property BOOL isGameOver;
@property int turnCount;
@property int errorCount;
@property int correctCount;
@property int timerCount;
@property int pairCount;

@property NSMutableArray *hashes;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.restartGameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.restartGameButton setTitle:@"New Game" forState:UIControlStateNormal];
    self.restartGameButton.frame = CGRectMake(894, 50, 100, 30);
    [self.restartGameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.restartGameButton.layer.borderWidth=1.0f;
    self.restartGameButton.layer.borderColor=[[UIColor blackColor] CGColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restartGameButtonWasTapped:)];
    self.restartGameButton.userInteractionEnabled = YES;
    [self.restartGameButton addGestureRecognizer:tapGesture];

    [self.view addSubview:self.restartGameButton];

    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(794, 670, 200, 30)];
    self.scoreLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.scoreLabel];
    
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(894, 590, 100, 30)];
    self.timerLabel.font=[UIFont boldSystemFontOfSize:30];
    self.timerLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.timerLabel];

    [self newGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timerTick
{

    int s = self.timerCount--;
    if (s == 0) {
        [self gameOver];
    }
    
    int m = (int) s / 60;
    s = s - (m*60);

    NSString *text = [NSString stringWithFormat:@"%d:%d", m,s];

    if (s < 10) {
        text = [NSString stringWithFormat:@"%d:0%d", m,s];
    }

    self.timerLabel.text = text;
}

- (IBAction)startTimer
{
    [self.timer invalidate];
    self.timerCount = TIME_LIMIT;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void) restartGameButtonWasTapped:(UITapGestureRecognizer*)recognizer
{
    [self newGame];
}

- (void)newGame
{
    self.isGameOver = false;

    [self createGrid];
    
    if (self.statusLabel) {
        [self.statusLabel removeFromSuperview];
    } else {
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
        self.statusLabel.font=[UIFont boldSystemFontOfSize:60];
    }


    self.hashes = [[NSMutableArray alloc] init];
    
    self.turnCount = 0;
    self.errorCount = 0;
    self.correctCount = 0;

    [self updateScore];
    
    self.pairCount = (WIDTH*WIDTH)/2;

    #if (TARGET_IPHONE_SIMULATOR)
        [self loadAlbumsFromLastFm:self.pairCount];
    #else
        [self loadAlbumsFromLibrary:self.pairCount];
    #endif
    
    
    
    /* PLAYER INTERFACE */
    self.playlistView = [[UIView alloc] initWithFrame:CGRectMake(710, 100, 300, 450)];
    [self.playlistView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    [self.view addSubview:self.playlistView];
    
    UIView *playerView = [[UIView alloc] initWithFrame:CGRectMake(30, 718, 964, 30)];
    
    self.nowPlayingLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 764, 30)];
    self.nowPlayingLabel.textAlignment = NSTextAlignmentCenter;
    [playerView addSubview:self.nowPlayingLabel];
    
    self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [self.skipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.skipButton.contentHorizontalAlignment = NSTextAlignmentLeft;
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(skipButtonWasTapped:)];
    self.skipButton.userInteractionEnabled = YES;
    [self.skipButton addGestureRecognizer:tapGesture2];
    
    [playerView addSubview:self.skipButton];
    
    [self.view addSubview:playerView];

}

- (NSArray*)shuffle:(NSArray*)input
{

    NSMutableArray *items = [NSMutableArray arrayWithArray:input];
    
    NSUInteger count = [items count];
    
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [items exchangeObjectAtIndex:i withObjectAtIndex:n];
    }

    return items;
}

-(void)deal
{
    
    self.cards = (NSMutableArray*) [self shuffle:self.cards];
    self.cards = (NSMutableArray*) [self shuffle:self.cards];
    self.cards = (NSMutableArray*) [self shuffle:self.cards];
    
    int x = 0;
    int y = 0;
    
    for (APCard *card in self.cards) {
        
        if (x == WIDTH) {
            // start a new line
            x = 0;
            y++;
        }
        
        CGRect frame = [ViewController frameForPositionX:x y:y];
        card.frame = frame;
        
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardWasTapped:)];
        
        card.userInteractionEnabled = YES;
        [card addGestureRecognizer:tapGesture];
        
        [self.gridView addSubview:card];
        
        x++;
    }
 
    [self startTimer];
}

-(BOOL)addCardFromImage:(UIImage*)image withIndex:(int)index title:(NSString*)title
{

    NSString *hash = [self imageHash:image];
    if ([self.hashes containsObject:hash]) {
        NSLog(@"found duplicate image");
        return false;
    }

    [self.hashes addObject:hash];

    [self.cards addObject:[[APCard alloc] initWithImage:image albumId:index title:title]];
    [self.cards addObject:[[APCard alloc] initWithImage:image albumId:index title:title]];

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

- (void)loadAlbumsFromLibrary:(int)howMany
{
    self.songs = [[NSMutableArray alloc] init];
    self.cards = [[NSMutableArray alloc] init];

    MPMediaQuery *query = [MPMediaQuery songsQuery];

    NSArray *albums = [query items];

    albums = [self shuffle:albums];

    int i = 0;
    for(NSDictionary *album in albums) {

        MPMediaItemArtwork *artwork = [album valueForKey:MPMediaItemPropertyArtwork];
        UIImage *artworkImage = [artwork imageWithSize: CGSizeMake (CARD_SIZE, CARD_SIZE)];
        NSString *title = [album valueForKey:MPMediaItemPropertyTitle];

        if (artworkImage) {
            // make two cards for each album
            if ([self addCardFromImage:artworkImage withIndex:i title:title]) {
                [self.songs addObject:album];
                i++;
            }
        } else {

        }

        if (i == howMany) {
            break;
        }
        
    }

    [self deal];
}


- (void)loadAlbumsFromLastFm:(int)howMany
{
    
    self.cards = [[NSMutableArray alloc] init];

    [LastFm sharedInstance].apiKey = @"79de4922efbb54e68613e47d36de1b9f";
    [LastFm sharedInstance].username = @"ebotunes";

    [[LastFm sharedInstance] getTopAlbumsForUserOrNil:nil period:kLastFmPeriodOverall limit:50 successHandler:^(NSArray *result) {
        
        NSArray *albums = [self shuffle:result];
        
        NSRange theRange;
        theRange.location = 0;
        theRange.length = howMany;
        albums = [albums subarrayWithRange:theRange];

        // make two cards for each album
        int i = 0;
        for (NSDictionary *album in albums) {

            NSString *title = [album valueForKey:@"name"];

            NSURL *url = [album valueForKey:@"image"];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];

            [self addCardFromImage:image withIndex:i title:title];
            i++;
        }
        
        [self deal];

    } failureHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

}

- (void) cardWasTapped:(UITapGestureRecognizer*)recognizer
{
    if (self.isGameOver) {
        return;
    }

    APCard *piece = (APCard *) recognizer.view;

    if (piece.shown) {
        return;
    }
    
    if (self.isBeingIncorrect) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reset) object: nil];
        [self reset];
    }

    if (self.pick1 == nil) {
        self.pick1 = piece;
        [piece show];
    } else if (self.pick2 == nil) {
        self.pick2 = piece;
        [piece show];
        
        if (self.pick1.albumId == self.pick2.albumId) {
            [self correct];
        } else {
            [self incorrect];
        }

    }

}
-(void)initPlayer
{
    self.player = [MPMusicPlayerController applicationMusicPlayer];
}




- (void) updateQueueWithCollection: (MPMediaItemCollection *) collection {
    
    // Add 'collection' to the music player's playback queue, but only if
    //    the user chose at least one song to play.
    if (collection) {
        
        // If there's no playback queue yet...
        if (self.playlist == nil) {
            self.playlist = collection;
            [self.player setQueueWithItemCollection: self.playlist];
            [self.player play];
            
            // Obtain the music player's state so it can be restored after
            //    updating the playback queue.
        } else {
            BOOL wasPlaying = NO;
            if (self.player.playbackState == MPMusicPlaybackStatePlaying) {
                wasPlaying = YES;
            }
            
            // Save the now-playing item and its current playback time.
            MPMediaItem *nowPlayingItem        = self.player.nowPlayingItem;
            NSTimeInterval currentPlaybackTime = self.player.currentPlaybackTime;
            
            // Combine the previously-existing media item collection with
            //    the new one
            NSMutableArray *combinedMediaItems = [[self.playlist items] mutableCopy];

            NSArray *newMediaItems = [collection items];
            [combinedMediaItems addObjectsFromArray: newMediaItems];
            
            self.playlist =
             [MPMediaItemCollection collectionWithItems:
              (NSArray *) combinedMediaItems];
            
            [self.player setQueueWithItemCollection: self.playlist];
            
            // Restore the now-playing item and its current playback time.
            self.player.nowPlayingItem      = nowPlayingItem;
            self.player.currentPlaybackTime = currentPlaybackTime;
            
            if (wasPlaying) {
                [self.player play];
            }
        }
    }
}



-(void)queueSong:(MPMediaItem*)song
{
    if (!self.player) {
        [self initPlayer];
    }
    
    MPMediaItemCollection *playlist = [MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:song]];
    [self updateQueueWithCollection:playlist];
}

-(void)displaySong:(NSString*)title
{
    int y = (self.correctCount-1) * 25;
    
    UILabel *item = [[UILabel alloc] initWithFrame:CGRectMake(5, y, 300, 25)];
    [item setText:[NSString stringWithFormat:@"%d. %@", self.correctCount, title]];
    
    [self.playlistView addSubview:item];
}

- (void) skipButtonWasTapped:(UITapGestureRecognizer*)recognizer
{
    [self.player skipToNextItem];
}

-(void)correct
{
//    AudioServicesPlaySystemSound (1025);

    self.turnCount++;
    self.correctCount++;

    self.timerCount += 5;
    
    if (self.songs) {
        MPMediaItem *song = [self.songs objectAtIndex:self.pick1.albumId];
        [self queueSong:song];
    }

    [self displaySong:self.pick1.title];

    [self.pick1 highlight];
    [self.pick2 highlight];

    self.pick1 = nil;
    self.pick2 = nil;
    
    [self updateScore];
    
    if (self.correctCount == self.pairCount) {
        [self complete];
    }

}

-(void)incorrect
{
//    AudioServicesPlaySystemSound(1000);

    self.turnCount++;
    self.errorCount++;
    [self updateScore];

    self.isBeingIncorrect = true;
    [self performSelector:@selector(reset) withObject:nil afterDelay:2.0];
}

-(void)complete
{
    [self.timer invalidate];
    
    [self.statusLabel setText:@"YOU WIN!"];
    [self.statusLabel setTextColor:[UIColor greenColor]];
    
    [self.view addSubview:self.statusLabel];
}

-(void)gameOver
{
    self.isGameOver = true;

    [self.timer invalidate];

    [self.statusLabel setText:@"GAME OVER"];
    [self.statusLabel setTextColor:[UIColor redColor]];

    [self.view addSubview:self.statusLabel];
    
    [self.player stop];
    
}



-(void)updateScore
{
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", self.errorCount]];
}

-(void)reset
{
    if (self.isBeingIncorrect) {
        [self.pick1 hide];
        [self.pick2 hide];
        self.pick1 = nil;
        self.pick2 = nil;
        
        self.isBeingIncorrect = false;
    }
}

- (void) createGrid
{

    if (self.gridView) {
        [self.gridView removeFromSuperview];
    }
    
    int gridArea = (CARD_SIZE * WIDTH) + (CARD_MARGIN * WIDTH-1);
    CGRect gridFrame = CGRectMake(30, 50, gridArea, gridArea);

    self.gridView = [[UIView alloc] initWithFrame:gridFrame];
    
    [self.view addSubview:self.gridView];
}

+ (CGRect) frameForPositionX:(int) x y:(int)y
{

    int xpos = x * (CARD_SIZE + CARD_MARGIN);
    int ypos = y * (CARD_SIZE + CARD_MARGIN);

    return CGRectMake(xpos, ypos, CARD_SIZE, CARD_SIZE);
}

@end
