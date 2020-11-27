//
//  ViewController.h
//  FileManager
//
//  Created by 陈征征 on 2020/11/25.
//

#import <UIKit/UIKit.h>
#import <FileManagerSDK/FileManagerSDK.h>
@interface ViewController : UIViewController
@property (nonatomic, strong) MRC_LocalFileItem * c_Item;
//@property (nonatomic, assign )  BOOL  isMoved;
@property (nonatomic, assign )  NSInteger  optType; // 1 拷贝 2剪贴

@property (nonatomic, copy) void(^selectBlock)(MRC_LocalFileItem *selectItem);

@end

