//
//  PairsCard.h
//  Album Pairs
//
//  Created by Iain on 10/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PairsCard : UIView

- (void)highlight;
- (void)show;
- (void)hide;
- (void)remove;
@property (nonatomic) NSString *title;
@property (nonatomic) UIImageView* back;
@property (nonatomic) UIImageView* front;
@property (nonatomic) BOOL shown;
@property (nonatomic) int size;

@end
