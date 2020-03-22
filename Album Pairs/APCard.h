//
//  APCard.h
//  
//
//  Created by Iain on 07/12/2013.
//
//

#import <UIKit/UIKit.h>
#import "PairsCard.h"

@interface APCard : PairsCard

@property (nonatomic) int albumId;

- (id)initWithImage:(UIImage*)image size:(int)size albumId:(int)albumId title:(NSString*)title;

@end
