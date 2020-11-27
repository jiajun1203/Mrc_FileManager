//
//  MRC_FileManager.h
//  FileManagerSDK
//
//  Created by 陈征征 on 2020/11/25.
//


#import <Foundation/Foundation.h>
#import "MRC_LocalFileItem.h"

/**
    failCount  失败数量
    finishedCount   完成数量
    totalCount      操作文件总数
 */
typedef void(^fileOptBlock)(NSInteger failCount,NSInteger finishedCount,NSInteger totalCount);

/**
    isSuccess   是否成功,无error即成功,即使操作过程中有失败
    finishedArray   成功数组
    failedArray     失败数组
    error           错误
 */
typedef void(^finishBlock)(BOOL isSuccess,NSArray * _Nonnull failedArray,NSArray * _Nonnull finishedArray,NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface MRC_FileManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, copy) NSString *destPath;   //文件移动目的地路径,文件移动或剪贴时使用:toPath或toItem 优先使用,
@property (nonatomic, copy) fileOptBlock listenBlock;   //操作中文件监听block,任意位置唯一监听

//进行中任务数量
- (NSInteger)taskCount;
//完成数量
- (NSInteger)finishCount;
//所有任务数量(完成和失败和进行中)
- (NSInteger)allTaskCount;

//判断文件或文件夹是否存在
- (BOOL)fileExistsAtPath:(NSString *)path;
- (BOOL)fileExistsAtItem:(MRC_LocalFileItem *)item;

//创建文件夹 path包涵文件夹名
- (BOOL)mkDirWithPath:(NSString *)path success:(void (^)(BOOL success ,NSString *path))block failed:(void (^)(NSError *error))failedblock;

//创建文件  path包涵文件名
- (BOOL)mkFileWithPath:(NSString *)path success:(void (^)(BOOL success ,NSString *path))block failed:(void (^)(NSError *error))failedblock;

- (void)copyItems:(NSArray <MRC_LocalFileItem *>*)itemArray toPath:(NSString *)destPath block:(fileOptBlock)block finish:(finishBlock)finishB;
- (void)copyItems:(NSArray <MRC_LocalFileItem *>*)itemArray toItem:(MRC_LocalFileItem *)item block:(fileOptBlock)block finish:(finishBlock)finishB;

- (void)cutItems:(NSArray <MRC_LocalFileItem *>*)itemArray toPath:(NSString *)destPath block:(fileOptBlock)block finish:(finishBlock)finishB;
- (void)cutItems:(NSArray <MRC_LocalFileItem *>*)itemArray toItem:(MRC_LocalFileItem *)item block:(fileOptBlock)block finish:(finishBlock)finishB;

- (void)deleteItems:(NSArray <MRC_LocalFileItem *>*)itemArray block:(fileOptBlock)block finish:(finishBlock)finishB;

- (void)renameItem:(MRC_LocalFileItem *)item newName:(NSString *)name finish:(void (^)(BOOL success))block failed:(void (^)(NSError *error))failedblock;

@end

NS_ASSUME_NONNULL_END
