#import <UIKit/UIKit.h>
@class GankModel;
@interface MNGankCollectCell : UITableViewCell
@property(nonatomic,strong)GankModel *gankModel;

- (void)sp_getMediaFailed;
@end
