//
//  ViewController.m
//  FileManager
//
//  Created by 陈征征 on 2020/11/25.
//

#import "ViewController.h"
#import "UIAlertController+Blocks.h"
#import "FileVc.h"
#import "MRC_FileItemCell.h"

#define IS_IPHONEX_ALL \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT    [UIScreen mainScreen].bounds.size.height

#define tabBarItemHeight            ((IS_IPHONEX_ALL) ? 83.0 : 49.0)

@interface ViewController ()<UITableViewDelegate ,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *height_BottomView;
@property (strong ,nonatomic) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray * selectArr;
@property (nonatomic, assign )  BOOL  isSelect;
@property (nonatomic, strong) UILabel * lab_Progress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.c_Item) {
        self.c_Item = [[MRC_LocalFileItem alloc]initWithPath:@"/Users/lipei/Desktop/testFile"];
    }
    [self.view addSubview:self.lab_Progress];
    self.lab_Progress.text = [NSString stringWithFormat:@"%ld/%ld",[MRC_FileManager shareManager].finishCount,[MRC_FileManager shareManager].allTaskCount];
    [[MRC_FileManager shareManager] setListenBlock:^(NSInteger failCount, NSInteger finishedCount, NSInteger totalCount) {
        NSLog(@"manager---->fail  %d   suc---%d   isEnd----%d",failCount,finishedCount,totalCount);
    }];
    
    [self loadData];
}
- (void)loadData{
    if (self.optType > 0) {
//        [self.c_Item listFiles:^(id  _Nonnull fileArr) {
//            if ([fileArr isKindOfClass:[NSArray class]]) {
//                [self.dataArr removeAllObjects];
//                [self.dataArr addObjectsFromArray:fileArr];
//                [self.tableView reloadData];
//            }
//        } FileType:FILE_MRC_DIR];
        [self.c_Item getFileListOffset:0 AndCount:100 andType:FILE_MRC_DIR And:^(id  _Nonnull result) {
            if ([result isKindOfClass:[NSArray class]]) {
                [self.dataArr removeAllObjects];
                [self.dataArr addObjectsFromArray:result];
                [self.tableView reloadData];
            }
        }];
    }else{
        [self.c_Item listFiles:^(id  _Nonnull fileArr) {
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:fileArr];
            [self.tableView reloadData];
        }];
    }
}
//重命名
- (IBAction)renameMthod:(id)sender {
    if (self.selectArr.count > 1) {
        [UIAlertController showAlertInViewController:self withTitle:@"只允许单个文件重命名" message:nil cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
        return;
    }
    __block UITextField *tf;
    __weak typeof(self) weak = self;
    UIAlertController *alert = [UIAlertController showAlertInViewController:self withTitle:nil message:@"请输入文件名" cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        if (buttonIndex == 2) {
           MRC_LocalFileItem *item = weak.selectArr[0];
            
            //manager操作命名
            [[MRC_FileManager shareManager] renameItem:item newName:tf.text finish:^(BOOL success) {
                [weak loadData];
            } failed:^(NSError * _Nonnull error) {
                
            }];
            
            //item操作命名
//            [item renameToName:tf.text success:^(BOOL success) {
//                [weak loadData];
//            } failed:^(NSError * _Nonnull error) {
//
//            }];
            weak.isSelect = NO;
        }
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入新名称";
        tf = textField;
    }];
}
//拷贝
- (IBAction)copyMehtod:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    ViewController *vc = [story instantiateViewControllerWithIdentifier:@"viewController"];
    vc.c_Item = self.c_Item;
    vc.optType = 1;
    [self.navigationController pushViewController:vc animated:YES];
    __weak typeof(self) weak = self;
    [vc setSelectBlock:^(MRC_LocalFileItem *selectItem) {
        [[MRC_FileManager shareManager]copyItems:self.selectArr toItem:selectItem block:^(NSInteger failCount, NSInteger finishedCount, NSInteger totalCount) {
            NSLog(@"progress --->  %d , finish---> %d , total---%d",failCount,finishedCount,totalCount);
            self.lab_Progress.text = [NSString stringWithFormat:@"%ld/%ld",[MRC_FileManager shareManager].finishCount,[MRC_FileManager shareManager].allTaskCount];
        } finish:^(BOOL isSuccess, NSArray * _Nonnull failedArray, NSArray * _Nonnull finishedArray, NSError * _Nullable error) {
            NSLog(@"over suc --> %d \n fail -> %d \n finish-> %d \n error-> %@",isSuccess,failedArray.count,finishedArray.count,error);
        }];
        weak.isSelect = NO;
    }];
    //item操作拷贝,无进度
//    for (MRC_LocalFileItem *item in self.selectArr) {
//        [item copyTo:copyToItem success:^(BOOL success) {
//
//        } failed:^(NSError * _Nonnull error) {
//
//        }];
//    }
    
    
}
//剪贴
- (IBAction)cutMehtod:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    ViewController *vc = [story instantiateViewControllerWithIdentifier:@"viewController"];
    vc.c_Item = self.c_Item;
    vc.optType = 2;
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak typeof(self) weak = self;
    [vc setSelectBlock:^(MRC_LocalFileItem *selectItem) {
        [[MRC_FileManager shareManager]cutItems:self.selectArr toItem:selectItem block:^(NSInteger failCount, NSInteger finishedCount, NSInteger totalCount) {
            NSLog(@"progress --->  %d , finish---> %d , total---%d",failCount,finishedCount,totalCount);
            self.lab_Progress.text = [NSString stringWithFormat:@"%ld/%ld",[MRC_FileManager shareManager].finishCount,[MRC_FileManager shareManager].allTaskCount];
        } finish:^(BOOL isSuccess, NSArray * _Nonnull failedArray, NSArray * _Nonnull finishedArray, NSError * _Nullable error) {
            [weak.c_Item clearCache];
            [weak loadData];
            
            NSLog(@"over suc --> %d \n fail -> %d \n finish-> %d \n error-> %@",isSuccess,failedArray.count,finishedArray.count,error);
        }];
        weak.isSelect = NO;
    }];
    //item剪贴,无进度
//    for (MRC_LocalFileItem *item in self.selectArr) {
//        [item cutTo:copyToItem success:^(BOOL success) {
//            NSLog(@"111");
//            [weak loadData];
//        } failed:^(NSError * _Nonnull error) {
//            NSLog(@"111");
//        }];
//    }
}
//删除
- (IBAction)delMethod:(id)sender {
    __weak typeof(self) weak = self;
    
    [[MRC_FileManager shareManager]deleteItems:self.selectArr block:^(NSInteger failCount, NSInteger finishedCount, NSInteger totalCount) {
        NSLog(@"progress --->  %d , finish---> %d , total---%d",failCount,finishedCount,totalCount);
    } finish:^(BOOL isSuccess, NSArray * _Nonnull failedArray, NSArray * _Nonnull finishedArray, NSError * _Nullable error) {
        [weak loadData];
        NSLog(@"over suc --> %d \n fail -> %d \n finish-> %d \n error-> %@",isSuccess,failedArray.count,finishedArray.count,error);
    }];
    
    //item删除,无进度
//    for (MRC_LocalFileItem *item in self.selectArr) {
//        [item del:^(BOOL success) {
//            [weak loadData];
//        } failed:^(NSError * _Nonnull error) {
//
//        }];
//    }
    self.isSelect = NO;
}
- (IBAction)cancelMethod:(id)sender {
    self.isSelect = NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MRC_LocalFileItem *item = self.dataArr[indexPath.row];
    if (self.optType > 0) {
        if (self.selectBlock) {
            self.selectBlock(item);
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (self.isSelect) {
        if ([self.selectArr containsObject:item]) {
            [self.selectArr removeObject:item];
        }else
            [self.selectArr addObject:item];
        
        [self.tableView reloadData];
    }else if (item.isDir){
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        ViewController *vc = [story instantiateViewControllerWithIdentifier:@"viewController"];
        vc.c_Item = item;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MRC_FileItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tbv_Cell"];
    MRC_LocalFileItem *item = self.dataArr[indexPath.row];
    cell.lab_Name.text = item.fileName;
    NSInteger subCount = item.subItemCount;
    cell.lab_Size.text = [NSString stringWithFormat:@"%lld",subCount];
    cell.lab_Size.hidden = subCount < 0;
    cell.lab_CrateTime.text = item.crateDate;
    NSString *imageStr;
    switch (item.fileType) {
        case FILE_MRC_MUSIC:
        {
            imageStr = @"yinyue";
        }
            break;
        case FILE_MRC_VIDEO:
        {
            imageStr = @"shipin";
        }
            break;
        case FILE_MRC_PICTURE:
        {
            imageStr = @"tupian";
        }
            break;
        case FILE_MRC_TEXT:
        {
            imageStr = @"wendang";
        }
            break;
        case FILE_MRC_LINK:
        {
            imageStr = @"lianjie";
        }
            break;
        case FILE_MRC_ZIP:
        {
            imageStr = @"yasuo";
        }
            break;
        case FILE_MRC_DIR:{
            imageStr = @"wenjianjia";
        }
            break;;
        case FILE_MRC_UNKNOW:
        {
            imageStr = @"weizhi";
        }
            break;
            
        default:
            break;
    }
    cell.imgv_Preview.image = [UIImage imageNamed:imageStr];
    
    if ([self.selectArr containsObject:item]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}
- (NSMutableArray *)selectArr{
    if (!_selectArr) {
        _selectArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectArr;
}
- (IBAction)selectMethod:(id)sender {
    self.isSelect = YES;
}
- (void)setIsSelect:(BOOL)isSelect{
    _isSelect = isSelect;
    self.height_BottomView.constant = isSelect ? 50 : 0;
    if (!isSelect) {
        [self.selectArr removeAllObjects];
        [self.tableView reloadData];
    }
    [self.view layoutSubviews];
}

- (UILabel *)lab_Progress{
    if (!_lab_Progress) {
        _lab_Progress = [[UILabel alloc]init];
        _lab_Progress.textAlignment = NSTextAlignmentCenter;
        _lab_Progress.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - tabBarItemHeight - 60, 50, 50) ;
        _lab_Progress.font = [UIFont boldSystemFontOfSize:17];
        _lab_Progress.layer.cornerRadius = 25;
        _lab_Progress.layer.masksToBounds = YES;
        _lab_Progress.backgroundColor = [UIColor whiteColor];
    }
    return _lab_Progress;
}
@end
