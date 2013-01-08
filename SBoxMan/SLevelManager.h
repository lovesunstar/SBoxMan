//
//  SLevelManager.h
//  SBoxMan
//
//  Created by SunJiangting on 12-12-7.
//
//

#import "SLevel.h"

@interface SLevelManager : NSObject
/// 当前关的int值，比如第几关第几关
@property (nonatomic, assign) int currentLevel;
/// 当前关数的数据信息
@property (nonatomic, readonly) SLevel * level;


@property (nonatomic, readonly) NSMutableArray * levelArray;

+ (SLevelManager *) standardLevelManager;

/**
 * @brief 是否存在上一关
 *
 * @return 是否存在上一关
 */
- (BOOL) hasPrevLevel;

/**
 * @brief 是否存在下一关
 *
 * @return 是否存在下一关
 */
- (BOOL) hasNextLevel;

/**
 * @brief 得到上一关
 *
 * @return 上一关的数据，会根据 boxman.plist 读取的信息和当前关数确定上一关
 * @note 如果不存在上一关，则返回nil。最好配合hasPrevLevel 使用
 */
- (SLevel *) prevLevel;

/**
 * @brief 得到下一关
 *
 * @return 下一关的数据，会根据 boxman.plist 读取的信息和当前关数确定下一关
 * @note 如果不存在下一关，则返回nil。最好配合hasNextLevel 使用
 */
- (SLevel *) nextLevel;

@end
