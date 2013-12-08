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

static const int CARD_SIZE = 100;
static const int CARD_MARGIN = 10;
static const int WIDTH = 6;

@interface ViewController ()

@property (strong, nonatomic) UIView *gridView;
@property (strong, nonatomic) NSMutableArray *cards;

@property (strong, nonatomic) APCard *pick1;
@property (strong, nonatomic) APCard *pick2;
@property (strong, nonatomic) UIButton *restartGameButton;
@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) NSTimer *timer;

@property BOOL isBeingIncorrect;
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
    self.scoreLabel.font=[UIFont boldSystemFontOfSize:30];
    self.scoreLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.scoreLabel];
    
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(894, 590, 100, 30)];
    self.timerLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.timerLabel];
    
    [self newGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)increaseTimerCount
{
    int s = self.timerCount++;
    
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
    self.timerCount = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
}

- (void) restartGameButtonWasTapped:(UITapGestureRecognizer*)recognizer
{
    [self newGame];
}

- (void)newGame
{

    [self createGrid];
    
    self.hashes = [[NSMutableArray alloc] init];
    
    self.turnCount = 0;
    self.errorCount = 0;

    [self updateScore];
    
    self.pairCount = (WIDTH*WIDTH)/2;

    #if (TARGET_IPHONE_SIMULATOR)
        [self loadAlbumsFromLastFm:self.pairCount];
    #else
        [self loadAlbumsFromLibrary:self.pairCount];
    #endif
    
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

-(BOOL)addCardFromImage:(UIImage*)image withIndex:(int)index
{
    
    NSString *hash = [self imageHash:image];
    if ([self.hashes containsObject:hash]) {
        NSLog(@"found duplicate image");
        return false;
    }
    
    [self.hashes addObject:hash];
    
    [self.cards addObject:[[APCard alloc] initWithImage:image albumId:index]];
    [self.cards addObject:[[APCard alloc] initWithImage:image albumId:index]];
    
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
    self.cards = [[NSMutableArray alloc] init];

    MPMediaQuery *query = [MPMediaQuery songsQuery];

    NSArray *albums = [query items];

    albums = [self shuffle:albums];

    int i = 0;
    for(NSDictionary *album in albums) {

        MPMediaItemArtwork *artwork = [album valueForKey:MPMediaItemPropertyArtwork];
        UIImage *artworkImage = [artwork imageWithSize: CGSizeMake (CARD_SIZE, CARD_SIZE)];

        if (artworkImage) {
            // make two cards for each album
            if ([self addCardFromImage:artworkImage withIndex:i]) {
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
            
            NSURL *url = [album valueForKey:@"image"];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];

            [self addCardFromImage:image withIndex:i];
            i++;
        }
        
        [self deal];

    } failureHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

}

- (void) cardWasTapped:(UITapGestureRecognizer*)recognizer
{
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

-(void)correct
{
    AudioServicesPlaySystemSound (1025);

    [self.pick1 highlight];
    [self.pick2 highlight];

    self.pick1 = nil;
    self.pick2 = nil;
    
    self.turnCount++;
    self.correctCount++;
    [self updateScore];

    if (self.correctCount == self.pairCount) {
        [self complete];
    }

}

-(void)incorrect
{
    AudioServicesPlaySystemSound(1000);

    self.turnCount++;
    self.errorCount++;
    [self updateScore];

    self.isBeingIncorrect = true;
    [self performSelector:@selector(reset) withObject:nil afterDelay:2.0];
}

-(void)complete
{
    [self.timer invalidate];
}
-(void)gameOver
{
    [self.timer invalidate];
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
