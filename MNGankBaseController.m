#import "MNGankBaseController.h"
#import "GankModel.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import "MNGankBaseCell.h"
#import "MNWebViewController.h"
#import "MNGankDao.h"
#import "MNUtils.h"
static const NSInteger pageSize = 20;
static NSInteger flag = 0;
static NSString * MNGankBaseCellID = @"GankBaseCellID";
@interface MNGankBaseController ()
@property(nonatomic,strong)NSMutableArray *gankDatas;
@property(nonatomic,assign)NSInteger pageIndex;
@end
@implementation MNGankBaseController
-(NSMutableArray *)gankDatas
{
    if(!_gankDatas){
        _gankDatas = [NSMutableArray array];
    }
    return _gankDatas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initRefresh];
}
-(void)initViews
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MNGankBaseCell class]) bundle:nil] forCellReuseIdentifier:MNGankBaseCellID];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
-(void)initRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDatas)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDatas)];
    self.tableView.mj_header.automaticallyChangeAlpha = NO;
    [self.tableView.mj_footer setHidden:YES];
    NSArray *cacheDatas = [MNGankDao queryCacheWithType:_gankDataType];
    if(cacheDatas!=nil && cacheDatas.count>0){
         _pageIndex = 1;
        _gankDatas = (NSMutableArray *)cacheDatas;
        [self updateCollectState];
        [self.tableView.mj_footer setHidden:NO];
    }else{
        [self.tableView.mj_header beginRefreshing];
    }
}
-(void)loadNewDatas
{
    if(![MNUtils isExistenceNetwork]){
        [MyProgressHUD showToast:@"检查你的网络设置"];
        [self.tableView.mj_header endRefreshing];
        return;
    }
    [MNUtils showNetWorkActivityIndicator:YES];
    _pageIndex = 1;
    flag = 0;
    [GankNetApi getGankDataWithType:_gankDataType pageSize:pageSize pageIndex:_pageIndex success:^(NSDictionary *dict) {
        if(flag == 1){
            return;
        }
        _pageIndex ++;
        self.gankDatas = [GankModel mj_objectArrayWithKeyValuesArray:dict[@"results"]];
        [self updateCollectState];
        if(self.gankDatas.count > 0){
            [self.tableView.mj_footer setHidden:NO];
        }
        [MNGankDao saveCache:self.gankDatas type:_gankDataType];
        [self.tableView.mj_header endRefreshing];
        [MNUtils showNetWorkActivityIndicator:NO];
    } failure:^(NSString *text) {
        [self.tableView.mj_header endRefreshing];
        [MNUtils showNetWorkActivityIndicator:NO];
    }];
}
-(void)loadMoreDatas
{
    if(![MNUtils isExistenceNetwork]){
        [MyProgressHUD showToast:@"检查你的网络设置"];
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    [MNUtils showNetWorkActivityIndicator:YES];
    flag = 1;
    [GankNetApi getGankDataWithType:_gankDataType pageSize:pageSize pageIndex:_pageIndex success:^(NSDictionary *dict) {
        if(flag == 0){
            return;
        }
        _pageIndex ++;
        NSMutableArray *newDatas = [GankModel mj_objectArrayWithKeyValuesArray:dict[@"results"]];
        GankModel *gankModel;
        GankModel *gankModelNew;
        for (int i=0; i<self.gankDatas.count; i++) {
            gankModel = self.gankDatas[i];
            for (int j= 0; j<newDatas.count; j++) {
                gankModelNew = newDatas[j];
                if([gankModelNew._id isEqualToString:gankModel._id]){
                    [newDatas removeObjectAtIndex:j];
                }
            }
        }
        if(newDatas!=nil && newDatas.count>0){
            [self.gankDatas addObjectsFromArray:newDatas];
        }
        [self updateCollectState];
        [self.tableView.mj_footer endRefreshing];
        [MNUtils showNetWorkActivityIndicator:NO];
    } failure:^(NSString *text) {
        [self.tableView.mj_footer endRefreshing];
        [MNUtils showNetWorkActivityIndicator:NO];
    }];
}
-(void)updateCollectState
{
    for (int i=0; i<self.gankDatas.count; i++) {
        GankModel *gankModel = self.gankDatas[i];
        if([MNGankDao queryIsExist:gankModel._id]){
            gankModel.collect = YES;
        }else{
            gankModel.collect = NO;
        }
    }
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gankDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNGankBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:MNGankBaseCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.gankModel = self.gankDatas[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNWebViewController *webViewVc = [[MNWebViewController alloc] init];
    GankModel *gankModel = self.gankDatas[indexPath.row];
    webViewVc.gankModel = gankModel;
    [self.navigationController pushViewController:webViewVc animated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self updateCollectState];
}

- (void)sp_didGetInfoSuccess {
    NSLog(@"Check your Network");
}
@end
