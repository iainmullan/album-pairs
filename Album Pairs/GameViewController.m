//
//  ViewController.m
//  Album Pairs
//
//  Created by Iain on 07/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

#import <MediaPlayer/MediaPlayer.h>

#include "TargetConditionals.h"

#import "GameViewController.h"
#import "LastFm.h"
#import "APCard.h"
#import "APGame.h"
#import "APMusicPlayer.h"
#import "PairsGameDelegate.h"

@interface GameViewController () <PairsGameDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIView *gridView;
@property (strong, nonatomic) NSMutableArray *foundCards;
@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) MPMediaItemCollection *playlist;
@property (strong, nonatomic) APMusicPlayer *player;
@property BOOL isBeingIncorrect;

@property (strong, nonatomic) APCard *pick1;
@property (strong, nonatomic) APCard *pick2;

@property (strong, nonatomic) IBOutlet UIButton *restartGameButton;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) UILabel *nowPlayingLabel;
@property (strong, nonatomic) IBOutlet UITableView *playlistView;

@property (strong, nonatomic) APGame *game;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.restartGameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.restartGameButton setTitle:@"New Game" forState:UIControlStateNormal];
    self.restartGameButton.frame = CGRectMake(910, 50, 100, 30);
    [self.restartGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.restartGameButton.layer.borderWidth=1.0f;
    self.restartGameButton.layer.borderColor=[[UIColor whiteColor] CGColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restartGameButtonWasTapped:)];
    self.restartGameButton.userInteractionEnabled = YES;
    [self.restartGameButton addGestureRecognizer:tapGesture];

    [self.view addSubview:self.restartGameButton];

//    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(710, 90, 300, 60)];
//    self.timerLabel.font=[UIFont boldSystemFontOfSize:60];
//    self.timerLabel.textAlignment = NSTextAlignmentRight;
//    self.timerLabel.textColor =[UIColor whiteColor];
//    [self.view addSubview:self.timerLabel];

    [self.view setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]];
    [self newGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) restartGameButtonWasTapped:(UITapGestureRecognizer*)recognizer
{
    [self newGame];
}

- (void)newGame
{
    self.game = [[APGame alloc ]init];
    self.game.delegate = self;

    self.foundCards = [[NSMutableArray alloc] init];

    [self drawGrid];

    [self loadAlbums];
    
    if (self.statusLabel) {
        [self.statusLabel removeFromSuperview];
    } else {
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
        self.statusLabel.font=[UIFont boldSystemFontOfSize:60];
    }
    
    /* PLAYER INTERFACE */
//    self.playlistView = [[UIView alloc] initWithFrame:CGRectMake(710, 160, 300, 450)];
//    [self.playlistView setBackgroundColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.9]];
//    [self.view addSubview:self.playlistView];

    [self.playlistView setDataSource:self];

    UIView *playerView = [[UIView alloc] initWithFrame:CGRectMake(30, 718, 964, 30)];
    
    self.nowPlayingLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 764, 30)];
    self.nowPlayingLabel.textAlignment = NSTextAlignmentCenter;
    [playerView addSubview:self.nowPlayingLabel];
    
    self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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

-(void)deal:(NSArray*)cards
{
    cards = (NSMutableArray*) [self shuffle:cards];
    cards = (NSMutableArray*) [self shuffle:cards];
    cards = (NSMutableArray*) [self shuffle:cards];
    cards = (NSMutableArray*) [self shuffle:cards];
    
    int x = 0;
    int y = 0;
    
    for (APCard *card in cards) {
        
        if (x == WIDTH) {
            // start a new line
            x = 0;
            y++;
        }
        
        
        CGRect frame = [GameViewController frameForPositionX:x y:y];
        card.frame = frame;

        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardWasTapped:)];
        
        card.userInteractionEnabled = YES;
        [card addGestureRecognizer:tapGesture];
        
        [self.gridView addSubview:card];
        
        x++;
    }
 
    [self.game startTimer];
}

- (void)loadAlbums
{

    #if (TARGET_IPHONE_SIMULATOR)
        self.artworkSource = APArtworkSourceLastFm;
    #endif

    if (self.artworkSource == APArtworkSourceLibrary) {
        [self loadAlbumsFromLibrary:self.game.pairCount];
    } else if (self.artworkSource == APArtworkSourceLastFm) {
        [self loadAlbumsFromLastFm:self.game.pairCount];
    } else {
        [self loadAlbumsFromDefault:self.game.pairCount];
    }

}

- (void)loadAlbumsFromDefault:(int)howMany
{
    NSLog(@"loadAlbumsFromLibrary");
}

- (void)loadAlbumsFromLibrary:(int)howMany
{

    NSLog(@"loadAlbumsFromLibrary");

    self.songs = [[NSMutableArray alloc] init];

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
            if ([self.game addCardFromImage:artworkImage withIndex:i title:title]) {
                [self.songs addObject:album];
                i++;
            }
        } else {

        }

        if (i == howMany) {
            break;
        }
        
    }

    [self deal:self.game.cards];
}


- (void)loadAlbumsFromLastFm:(int)howMany
{
    NSLog(@"loadAlbumsFromLastFm");

    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

    [LastFm sharedInstance].apiKey = [config objectForKey:@"LastFmApiKey"];
    [LastFm sharedInstance].username = [config objectForKey:@"LastFmUsername"];

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

            [self.game addCardFromImage:image withIndex:i title:title];
            i++;
        }
        
        [self deal:self.game.cards];

    } failureHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

}

- (void) cardWasTapped:(UITapGestureRecognizer*)recognizer
{
    if (self.game.isGameOver) {
        return;
    }

    APCard *card = (APCard *) recognizer.view;

    if (card.shown) {
        return;
    }

    if (self.isBeingIncorrect) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reset) object: nil];
        [self reset];
    }

    if ([self.game pickCard:card]) {
        [card show];
    }

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



-(void)initPlayer
{
    self.player = [[APMusicPlayer alloc] init];
}


//
//- (void) updateQueueWithCollection: (MPMediaItemCollection *) collection {
//    
//    // Add 'collection' to the music player's playback queue, but only if
//    //    the user chose at least one song to play.
//    if (collection) {
//        
//        // If there's no playback queue yet...
//        if (self.playlist == nil) {
//            self.playlist = collection;
//            [self.player setQueueWithItemCollection: self.playlist];
//            [self.player play];
//            
//            // Obtain the music player's state so it can be restored after
//            //    updating the playback queue.
//        } else {
//            BOOL wasPlaying = NO;
//            if (self.player.playbackState == MPMusicPlaybackStatePlaying) {
//                wasPlaying = YES;
//            }
//            
//            // Save the now-playing item and its current playback time.
//            MPMediaItem *nowPlayingItem        = self.player.nowPlayingItem;
//            NSTimeInterval currentPlaybackTime = self.player.currentPlaybackTime;
//            
//            // Combine the previously-existing media item collection with
//            //    the new one
//            NSMutableArray *combinedMediaItems = [[self.playlist items] mutableCopy];
//
//            NSArray *newMediaItems = [collection items];
//            [combinedMediaItems addObjectsFromArray: newMediaItems];
//            
//            self.playlist =
//             [MPMediaItemCollection collectionWithItems:
//              (NSArray *) combinedMediaItems];
//            
//            [self.player setQueueWithItemCollection: self.playlist];
//            
//            // Restore the now-playing item and its current playback time.
//            self.player.nowPlayingItem      = nowPlayingItem;
//            self.player.currentPlaybackTime = currentPlaybackTime;
//            
//            if (wasPlaying) {
//                [self.player play];
//            }
//        }
//    }
//}



-(void)queueSong:(MPMediaItem*)song
{
    if (!self.player) {
        NSLog(@"about to init player");
        [self initPlayer];
    }
    
    NSLog(@"about to send song to player");
    [self.player queueSong:song];
}

-(void)displaySong:(NSString*)title
{
    int y = (self.game.correctCount-1) * 25;
    
    UILabel *item = [[UILabel alloc] initWithFrame:CGRectMake(5, y, 300, 25)];
    
    [item setText:[NSString stringWithFormat:@"%d. %@", self.game.correctCount, title]];
    
    [self.playlistView addSubview:item];
}

- (void) skipButtonWasTapped:(UITapGestureRecognizer*)recognizer
{
    [self.player skip];
}

- (void) drawGrid
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

-(void)pairWasFoundWithPick1:(APCard*)pick1 pick2:(APCard*)pick2
{

    [pick1 highlight];
    [pick2 highlight];
    
    [self.foundCards addObject:pick1];
    [self.playlistView reloadData];

    if (self.artworkSource == APArtworkSourceLibrary) {
        MPMediaItem *song = [self.songs objectAtIndex:pick1.albumId];
        NSLog(@"about to queue song");
        [self queueSong:song];
    }
    
}

-(void)pairWasNotFoundWithPick1:(APCard*)pick1 pick2:(APCard*)pick2
{
    self.isBeingIncorrect = true;
    self.pick1 = pick1;
    self.pick2 = pick2;
    [self performSelector:@selector(reset) withObject:nil afterDelay:2.0];
}

// game over
-(void)gameDidEndWithResult:(BOOL)result
{
    
    if (result) {
        [self.statusLabel setText:@"YOU WIN!"];
        [self.statusLabel setTextColor:[UIColor greenColor]];
    } else {
        [self.statusLabel setText:@"GAME OVER"];
        [self.statusLabel setTextColor:[UIColor redColor]];
    }

    [self.view addSubview:self.statusLabel];
    [self.player stop];
}


// timer did update
-(void)timerDidUpdate:(int)seconds
{
    int m = (int) seconds / 60;
    seconds = seconds - (m*60);
    
    NSString *text = [NSString stringWithFormat:@"%d:%d", m,seconds];
    
    if (seconds < 10) {
        text = [NSString stringWithFormat:@"%d:0%d", m,seconds];
    }
    
    self.timerLabel.text = text;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.foundCards count];
    return count;
}

-(UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.playlistView dequeueReusableCellWithIdentifier:@"playlistItem" forIndexPath:indexPath];
    
    APCard *card = (APCard*)[self.foundCards objectAtIndex:indexPath.row];
    
    cell.textLabel.text = card.title;
    [cell.imageView setImage:card.front.image];
    
    return cell;
}

@end
