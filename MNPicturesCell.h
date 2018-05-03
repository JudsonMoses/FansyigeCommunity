#import <UIKit/UIKit.h>
@class GankModel;
@interface MNPicturesCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lableTime;
@property(nonatomic,strong)GankModel *gankModel;
@property(nonatomic,strong)NSString *url;

- (void)sp_getMediaFailed;
@end
