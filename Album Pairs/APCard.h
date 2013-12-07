//
//  APCard.h
//  
//
//  Created by Iain on 07/12/2013.
//
//

#import <UIKit/UIKit.h>

@interface APCard : UIView

- (id)initWithImage:(UIImage*)image albumId:(int)albumId;

- (void)highlight;
- (void)show;
- (void)hide;
- (void)remove;

@property (nonatomic) int albumId;
@property (nonatomic) UIImageView* back;
@property (nonatomic) UIImageView* albumArtwork;
@property (nonatomic) BOOL shown;

@end
