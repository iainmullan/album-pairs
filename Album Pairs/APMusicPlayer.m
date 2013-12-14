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
    self.player = [MPMusicPlayerController applicationMusicPlayer];
    [self clear];
    [self initPlayer];
    return self;
}

-(void)initPlayer
{

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.player];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.player];
    
    
    [self.player beginGeneratingPlaybackNotifications];
}


-(void)handle_PlaybackStateChanged:(NSNotification*)notification
{

    NSLog(@"playbackstate changed");

    if (self.player.playbackState == MPMusicPlaybackStateStopped) {
        [self skip];
    }

}

-(void)handle_NowPlayingItemChanged:(NSNotification*)notification
{
    NSLog(@"nowplaying item changed: %@", [self.player.nowPlayingItem valueForKey:@"title" ]);
}

-(void)queueSong:(MPMediaItem *)song
{
    [self.playlist addObject:song];

    if (self.currentItem == -1) {
        self.currentItem = 0;
        MPMediaItem *nextSong = (MPMediaItem *)[self.playlist objectAtIndex:self.currentItem];
        [self playSong:nextSong];
    }

}

-(void)skipToTrack:(NSInteger)index
{
    
    if (index >= self.playlist.count || index < 0) {
        return;
    }

    self.currentItem = index;
    MPMediaItem *nextSong = (MPMediaItem *)[self.playlist objectAtIndex:self.currentItem];
    [self playSong:nextSong];
}

-(void)playSong:(MPMediaItem*)song
{
    [self.player pause];

    [self.player setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:song]]];

    self.player.nowPlayingItem = song;
    [self.player play];
}

-(void)stop
{
    [self.player stop];
}
-(void)back
{
    [self skipToTrack:self.currentItem - 1];
}

-(void)skip
{
    [self skipToTrack:self.currentItem + 1];
}

-(void)playOrPause
{

    if (self.player.playbackState == MPMusicPlaybackStatePlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }

}

-(void)clear
{
    self.currentItem = -1;
    self.playlist = [[NSMutableArray alloc] init];
    [self.player endGeneratingPlaybackNotifications];
    [self.player stop];
    [self.player setQueueWithItemCollection:nil];
}

@end
