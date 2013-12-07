//
//  APCard.h
//  
//
//  Created by Iain on 07/12/2013.
//
//

#import <UIKit/UIKit.h>

@interface APCard : UIImageView

- (id)initWithImage:(UIImage*)image albumId:(int)albumId;
- (id)initWithLastFmAlbum:(NSDictionary*)album albumId:(int)albumId;

- (void)highlight;
- (void)show;
- (void)hide;
- (void)remove;

@property (nonatomic) int albumId;
@property (nonatomic) UIImage* back;
@property (nonatomic) UIImage* albumArtwork;
@property (nonatomic) BOOL shown;

@end
