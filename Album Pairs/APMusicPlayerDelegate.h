//
//  APMusicPlayerDelegate.h
//  Album Pairs
//
//  Created by Iain on 14/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APMusicPlayerDelegate <NSObject>

-(void)playbackPositionDidChange:(float)position;

@end
