//
//  APMusicPlayer.h
//  Album Pairs
//
//  Created by Iain on 14/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "APMusicPlayerDelegate.h"

@interface APMusicPlayer : NSObject

@property (nonatomic) id<APMusicPlayerDelegate> delegate;

-(void)queueSong:(MPMediaItem *)song;
-(void)skip;
-(void)back;
-(void)stop;
-(void)playOrPause;
-(void)skipToTrack:(NSInteger)index;
-(void)seekTo:(float)position;

-(void)clearPlayer;
-(void)initPlayer;
-(BOOL)isPlaying;

@end
