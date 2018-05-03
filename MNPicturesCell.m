#import "MNPicturesCell.h"
#import "GankModel.h"
@implementation MNPicturesCell
- (void)awakeFromNib {
    [super awakeFromNib];
}
-(void)setGankModel:(GankModel *)gankModel
{
    _gankModel = gankModel;
    _lableTime.text = [gankModel.publishedAt componentsSeparatedByString:@"T"][0];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:gankModel.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _imageView.image = image;
    }];
}

- (void)sp_getMediaFailed {
    NSLog(@"Continue");
}
@end
