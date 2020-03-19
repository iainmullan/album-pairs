//
//  ViewController.m
//  Album Pairs
//
//  Created by Iain on 07/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

#include "TargetConditionals.h"

#import "GameViewController.h"
#import "LastFm.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "APCard.h"
#import "APGame.h"
#import "APMusicPlayerDelegate.h"
#import "APMusicPlayer.h"
#import "PairsGameDelegate.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface GameViewController () <PairsGameDelegate, UITableViewDataSource, UITableViewDelegate, APMusicPlayerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *gridView;
@property (strong, nonatomic) NSMutableArray *foundCards;
@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) MPMediaItemCollection *playlist;
@property (strong, nonatomic) APMusicPlayer *player;
@property BOOL isBeingIncorrect;

@property (strong, nonatomic) APCard *pick1;
@property (strong, nonatomic) APCard *pick2;

@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UITableView *playlistView;
@property (strong, nonatomic) IBOutlet UIView *playerControls;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;

@property (strong, nonatomic) APGame *game;

@property (strong, nonatomic) id<GAITracker> tracker;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Game Screen";
    
    self.tracker = [[GAI sharedInstance] defaultTracker];
    
    if (self.artworkSource == APArtworkSourceLibrary) {
        self.player = [[APMusicPlayer alloc] init];
        self.player.delegate = self;
    }

    /* PLAYER INTERFACE */
    [self.playlistView setDataSource:self];
    [self.playlistView setDelegate:self];

    [self newGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)restartGameButtonWasTapped:(id)sender {

    if (self.player) {
        [self.player clearPlayer];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderWasDragged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    [self.player seekTo:slider.value];
}

- (void)newGame
{

    NSString *gameType = [APGame gameTypeToString:self.artworkSource];
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"New Game"     // Event category (required)
                                                          action:@"Game Type"  // Event action (required)
                                                           label:gameType       // Event label
                                                           value:nil] build]];    // Event value
    

    if (self.game) {
        // cancel the previous game's timer
        [self.game stopTimer];
    }

    if (self.player) {
        [self.player initPlayer];
    }

    self.game = [[APGame alloc ]init];
    self.game.delegate = self;

    self.foundCards = [[NSMutableArray alloc] init];
    [self.playlistView reloadData];

    [self drawGrid];

    [self loadAlbums];
    
    [self.statusLabel setTextColor:UIColorFromRGB(0x49b85b)];
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

    self.playerControls.hidden = YES;
    
    if (self.artworkSource == APArtworkSourceLibrary) {
        [self loadAlbumsFromLibrary:self.game.pairCount];
        self.playerControls.hidden = NO;
    } else if (self.artworkSource == APArtworkSourceLastFm) {
        [self loadAlbumsFromLastFm:self.game.pairCount];
    } else {
        [self loadAlbumsFromDefault:self.game.pairCount];
    }

}

- (void)loadAlbumsFromDefault:(int)howMany
{

    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"names.txt"];
    
    NSArray *filesList = [[NSString stringWithContentsOfFile:documentsPath
                                       encoding:NSUTF8StringEncoding
                                          error:nil]
             componentsSeparatedByString:@"\n"];
    
    filesList = [self shuffle:filesList];
    
    int i = 0;
    for(NSString* f in filesList) {

        NSString *filePath = [NSString stringWithFormat:@"ClassicAlbums/%@.jpg", [f stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
        UIImage *artworkImage = [UIImage imageNamed:filePath];

        NSString *title = f;

        if ([self.game addCardFromImage:artworkImage withIndex:i title:title]) {
            i++;
        }

        if (i == howMany) {
            break;
        }
    }

    [self deal:self.game.cards];
    
}

- (void)loadAlbumsFromLibrary:(int)howMany
{

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
    
    if (i < howMany) {
        [self gameErrorWithMessage:@"Sorry, there isn't enough artwork in your Library. Try the Classic Albums mode!"];
    } else {
        [self deal:self.game.cards];
    }

}


- (void)loadAlbumsFromLastFm:(int)howMany
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [LastFm sharedInstance].apiKey = [config objectForKey:@"LastFmApiKey"];
    [LastFm sharedInstance].apiSecret = [config objectForKey:@"LastFmApiSecret"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"LastFmUsername"];
    if (!username) {
        username = [config objectForKey:@"LastFmUsername"];
    }
    [LastFm sharedInstance].username = username;

    [[LastFm sharedInstance] getTopAlbumsForUserOrNil:nil period:kLastFmPeriodQuarter limit:36 successHandler:^(NSArray *result) {
        
        NSArray *albums = [self shuffle:result];
        
        if ([albums count] < howMany) {
            [self gameErrorWithMessage:@"Sorry, there isn't enough artwork in your Last FM Library. Try the Classic Albums mode!"];
            return;
        }
        
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

        [self gameErrorWithMessage:@"Sorry, there was a problem connecting to your Last FM account. Try the Classic Albums mode!"];

        NSLog(@"LastFM error: %@", error);
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

-(void)queueSong:(MPMediaItem*)song
{
    [self.player queueSong:song];
}

-(void)displaySong:(NSString*)title
{
    int y = (self.game.correctCount-1) * 25;
    
    UILabel *item = [[UILabel alloc] initWithFrame:CGRectMake(5, y, 300, 25)];
    
    [item setText:[NSString stringWithFormat:@"%d. %@", self.game.correctCount, title]];
    
    [self.playlistView addSubview:item];
}

- (IBAction)playerButtonWasTapped:(id)sender {
    UIButton *button = (UIButton*) sender;
    
    if (button.tag == 0) {

        if ([self.player isPlaying]) {
            [button setTitle:@"Play" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"Pause" forState:UIControlStateNormal];
        }

        [self.player playOrPause];

    } else if (button.tag == 1) {
        [self.player skip];
    } else if (button.tag == 2) {
        [self.player back];
    }
    

    NSString *buttonName = button.titleLabel.text;

    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Player"     // Event category (required)
                                                               action:@"Button Pressed"  // Event action (required)
                                                                label:buttonName       // Event label
                                                                value:nil] build]];    // Event value
}

- (void) drawGrid
{
    self.statusLabel.hidden = YES;

    // remove all current cards
    [[self.gridView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
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

    NSString *resultString = nil;
    
    if (result) {
        [self.statusLabel setText:@"YOU WIN!"];
        [self.statusLabel setTextColor:UIColorFromRGB(0x49b85b)];
        resultString = @"WIN";
    } else {
        [self.statusLabel setText:@"GAME OVER"];
        [self.statusLabel setTextColor:UIColorFromRGB(0xd22727)];
        [self.player stop];
        resultString = @"LOSE";
    }

    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"     // Event category (required)
                                                               action:@"Game Over"  // Event action (required)
                                                                label:resultString       // Event label
                                                                value:nil] build]];    // Event value

    self.statusLabel.hidden = NO;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Player"     // Event category (required)
                                                               action:@"Track Selected"  // Event action (required)
                                                                label:[NSString stringWithFormat:@"%d", indexPath.row+1]       // Event label
                                                                value:nil] build]];    // Event value

    [self.player skipToTrack:indexPath.row];
}

-(void)playbackPositionDidChange:(float)position
{
    // dont update if the user is currently interacting
    if (![self.playbackSlider isTouchInside]) {
        self.playbackSlider.value = position;
    }
}

-(void)gameErrorWithMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 2;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


@end
