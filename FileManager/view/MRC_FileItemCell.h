//
//  MRC_FileItemCell.h
//  FileManager
//
//  Created by 李沛 on 2020/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRC_FileItemCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgv_Preview;
@property (strong, nonatomic) IBOutlet UILabel *lab_Name;
@property (strong, nonatomic) IBOutlet UILabel *lab_Size;
@property (strong, nonatomic) IBOutlet UILabel *lab_CrateTime;

@end

NS_ASSUME_NONNULL_END
