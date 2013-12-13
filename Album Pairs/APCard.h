//
//  APCard.h
//  
//
//  Created by Iain on 07/12/2013.
//
//

#import <UIKit/UIKit.h>
#import "PairsCard.h"

static const int CARD_SIZE = 100;
static const int CARD_MARGIN = 10;

@interface APCard : PairsCard

@property (nonatomic) int albumId;
- (id)initWithImage:(UIImage*)image albumId:(int)albumId title:(NSString*)title;

@end
