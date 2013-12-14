//
//  APMusicPlayer.m
//  Album Pairs
//
//  Created by Iain on 14/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import "APMusicPlayer.h"

@interface APMusicPlayer ()

@property (strong, nonatomic) MPMusicPlayerController *player;
@property (strong, nonatomic) NSMutableArray *playlist;
@property (nonatomic) NSInteger currentItem;

@end

@implementation APMusicPlayer

-(APMusicPlayer*)init
{
    self.currentItem = -1;
    self.playlist = [[NSMutableArray alloc] init];
    self.player = [MPMusicPlayerController applicationMusicPlayer];

    return self;
}

-(void)queueSong:(MPMediaItem *)song
{
    NSLog(@"player received song");

    [self.playlist addObject:song];

    NSLog(@"playlist: %@", self.playlist);

    if (self.currentItem == -1) {
        NSLog(@"start the player for the first time");
        self.currentItem = 0;
        MPMediaItem *nextSong = (MPMediaItem *)[self.playlist objectAtIndex:self.currentItem];
        NSLog(@"nextSong: %@", nextSong);
        [self playSong:nextSong];
    }

}

-(void)playSong:(MPMediaItem*)song
{
    [self.player pause];

    [self.player setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:song]]];

    self.player.nowPlayingItem = song;
    NSLog(@"nowPlayingItem: %@", self.player.nowPlayingItem);
    [self.player play];
}

-(void)skip
{
    
    NSInteger nextItem = self.currentItem + 1;
    
    if (nextItem >= self.playlist.count) {
        return;
    }
    
    self.currentItem = nextItem;
    
    MPMediaItem *nextSong = (MPMediaItem *)[self.playlist objectAtIndex:self.currentItem];
    [self playSong:nextSong];
}

-(void)playOrPause
{

    if (self.player.playbackState == MPMusicPlaybackStatePlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }

}

-(void)stop
{
    [self.player stop];
}

@end
