#import "MNGankCollectCell.h"
#import "GankModel.h"
@interface MNGankCollectCell ()
@property (weak, nonatomic) IBOutlet UILabel *lableTitle;
@property (weak, nonatomic) IBOutlet UILabel *lableType;
@property (weak, nonatomic) IBOutlet UILabel *lableTime;
@end
@implementation MNGankCollectCell
- (void)awakeFromNib {
}
-(void)setGankModel:(GankModel *)gankModel
{
    _gankModel = gankModel;
    _lableType.text = _gankModel.type;
    _lableTitle.text = _gankModel.desc;
    _lableTitle.textColor = GankMainColor;
    _lableTime.text = [_gankModel.publishedAt componentsSeparatedByString:@"T"][0];
}

- (void)sp_getMediaFailed {
    NSLog(@"Get Info Success");
}
@end
