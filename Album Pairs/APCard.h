//
//  APCard.h
//  
//
//  Created by Iain on 07/12/2013.
//
//

#import <UIKit/UIKit.h>

static const int CARD_SIZE = 100;
static const int CARD_MARGIN = 10;

@interface APCard : UIView

- (id)initWithImage:(UIImage*)image albumId:(int)albumId title:(NSString*)title;

- (void)highlight;
- (void)show;
- (void)hide;
- (void)remove;

@property (nonatomic) int albumId;
@property (nonatomic) NSString *title;
@property (nonatomic) UIImageView* back;
@property (nonatomic) UIImageView* albumArtwork;
@property (nonatomic) BOOL shown;

@end
