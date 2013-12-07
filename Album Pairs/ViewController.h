//
//  ViewController.h
//  Album Pairs
//
//  Created by Iain on 07/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


- (NSArray*) shuffle:(NSArray*)input;
+ (CGRect) frameForPositionX:(int) x y:(int)y;

@end
