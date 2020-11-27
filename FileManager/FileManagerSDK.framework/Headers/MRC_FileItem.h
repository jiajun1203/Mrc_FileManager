//
//  MRC_FileItem.h
//  FileManagerSDK
//
//  Created by 陈征征 on 2020/11/25.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN



typedef enum {
    FILE_MRC_MUSIC = 0,
    FILE_MRC_VIDEO = 1,
    FILE_MRC_PICTURE =2,
    FILE_MRC_TEXT = 3,
    FILE_MRC_ZIP = 4,
    FILE_MRC_DIR = 5,
    FILE_MRC_LINK = 6,
    FILE_MRC_UNKNOW = 7,
} MRC_FileType;

@interface MRC_FileItem : NSObject


//文件类型
@property (nonatomic,assign) MRC_FileType fileType;

//文件名
@property (nonatomic ,copy) NSString *fileName;

//文件创建日期
@property (nonatomic,copy)NSString *crateDate;

//文件修改日期
@property (nonatomic,copy)NSString *modifyDate;

//文件总大小
@property (nonatomic ,assign) long long totalSize;
//文件大小字符串 按照1024计算
@property (nonatomic, copy) NSString * totalSizeString;

//当前文件类型所对应的图片，  图片类型会对应处理后显示原图。
//@property (nonatomic ,strong)UIImage *image;

//当前文件路径
@property (nonatomic ,copy) NSString *path;

//是否为文件夹  YES 为文件夹   NO 为文件
@property (nonatomic ,assign) BOOL isDir;

//父层
@property (nonatomic) MRC_FileItem *parent;

@property (nonatomic, assign )  NSInteger  subItemCount;    //子文件数量

//当前文件列表(缓存)
@property (nonatomic) NSMutableArray  *listFiles;


-(instancetype) initWithPath:(NSString*) path;

//清除文件缓存(内存中文件)
- (void)clearCache;
//获取文件列表
-(void) listFiles:(void(^)(id fileArr))block;
//获取目录下所有同类型文件
-(void) getFileListOffset:(int)offset AndCount:(int)count andType:(MRC_FileType)fileType And:(void (^)(id result))block;
//获取当前目录 所有同类型文件
- (void)listFiles:(void(^)(id fileArr))block FileType:(MRC_FileType)fileType;
//获取数组内所有相同类型的文件(和 调取的item同类型)
-(NSArray *)listSameTypeItemFilesWith:(NSArray *)itemArr;

//拷贝文件
- (void)copyTo:(MRC_FileItem*)dest success:(void (^)(BOOL success))block failed:(void (^)(NSError *error))failedblock;

//剪贴
- (void)cutTo:(MRC_FileItem*)dest success:(void (^)(BOOL success))block failed:(void (^)(NSError *error))failedblock;

//重命名
- (void)renameToName:(NSString *)name success:(void (^)(BOOL success))block failed:(void (^)(NSError *error))failedblock;

//删除文件
- (void)del:(void (^)(BOOL success))block failed:(void (^)(NSError *error))failedblock;

//创建文件夹
- (BOOL)mkDirWithName:(NSString *)name success:(void (^)(BOOL success ,NSString *path))block failed:(void (^)(NSError *error))failedblock;

//创建文件
- (BOOL)mkFileWithName:(NSString *)name success:(void (^)(BOOL success ,NSString *path))block failed:(void (^)(NSError *error))failedblock;

@end

NS_ASSUME_NONNULL_END
