//
//  APMusicPlayer.h
//  Album Pairs
//
//  Created by Iain on 14/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface APMusicPlayer : NSObject

-(void)queueSong:(MPMediaItem *)song;
-(void)skip;
-(void)back;
-(void)stop;
-(void)playOrPause;
-(void)skipToTrack:(NSInteger)index;

-(void)clear;

@end
