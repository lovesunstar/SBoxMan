//
//  SMapLayer.h
//  SBoxMan
//
//  Created by SunJiangting on 12-12-6.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "SLevel.h"
#import "SLevelManager.h"
#import "SBoxMan.h"
#import "SimpleAudioEngine.h"

#define kMoveDuration 0.3f

/**
 * @brief 该结构体用于存储行和列，都为int值，常用语二维数组
 */
typedef struct SIndexPath{
    int row;    // 第几行
    int column; // 第几列
} SIndexPath;

/// 行列为零 的SIndexPath
CG_EXTERN const SIndexPath SIndexPathZero;

/**
 * @brief 创建一个SIndexPath
 * 
 * @param row 该indexPath的行，第几行
 * @param column 该indexPath的列，第几列
 * @return 根据行，列创建的SIndexPath
 */
CG_INLINE SIndexPath SIndexPathMake(int row,int column) {
    SIndexPath indexPath;
    indexPath.row = row;
    indexPath.column = column;
    return indexPath;
}

/**
 * @brief 比较两个SIndexPath是否相等，如果两个SIndexPath的行，列均相等，则认为两个SIndexPath相等
 *
 * @param indexPath1 需要比较的indexPath
 * @param indexPath2 需要比较的indexPath
 * @return 返回两个indexPath的行列是否都相等
 */
CG_INLINE BOOL SIndexPathEqual(SIndexPath indexPath1,SIndexPath indexPath2) {
    return (indexPath1.row == indexPath2.row) && (indexPath1.column == indexPath2.column);
}

/**
 * @brief 将SIndexPath转换成字符串
 *
 * @param indexPath 参见SIndexPath 包含row，column
 * @return 返回根据indexPath的row，column生成的字符串 格式为[indexPath.row,indexPath.column]
 */
CG_INLINE NSString * NSStringFromIndexPath(SIndexPath indexPath) {
    return [NSString stringWithFormat:@"[%d,%d]",indexPath.row,indexPath.column];
}

/**
 * @brief 从字符串中获取SIndexPath
 *
 * @return 返回 字符串解析后的indexPath
 * @attention 字符串格式必须是[row,column] row,column必须是int类型
 */
CG_INLINE SIndexPath SIndexPathFromNSString(NSString * string) {
    SIndexPath indexPath = SIndexPathMake(0, 0);
    NSString * temp = [[string stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray * array = [temp componentsSeparatedByString:@","];
    if (array.count >=2) {
        int row = [[array objectAtIndex:0] intValue];
        int column = [[array objectAtIndex:1] intValue];
        indexPath.row = row;
        indexPath.column = column;
    }
    return indexPath;
}

/**
 * @brief 设置数组在某行某列的值
 *
 * @param array 需要设置的数组
 * @param indexPath 参见SIndexPath，表示行列
 * @param newValue 需要设置的值
 * @return 返回是否设置成功
 */
CG_INLINE BOOL SetArrayAtIndexPath(NSArray * array,SIndexPath indexPath,id newValue) {
    BOOL result = NO;
    if (array.count > indexPath.row) {
        NSMutableArray * tempArray = [array objectAtIndex:indexPath.row];
        if ([tempArray isKindOfClass:[NSMutableArray class]]) {
            if (tempArray.count > indexPath.column) {
                [tempArray replaceObjectAtIndex:indexPath.column withObject:newValue];
                result = YES;
            }
        }
    }
    return result;
}

/**
 * @brief 设置数组在某行某列的值
 *
 * @param array 需要设置的数组
 * @param row 需要设置的行
 * @param column 需要设置的列
 * @param newValue 需要设置的值
 * @return 返回是否设置成功
 */
CG_INLINE BOOL SetArrayAtRowAndColumn(NSArray * array,int row,int column,id newValue) {
    return SetArrayAtIndexPath(array, SIndexPathMake(row, column), newValue);
}

/**
 * @brief 得到该数组中某个indexPath下的值
 *
 * @param array 需要得到的数组
 * @param indexPath 参见SIndexPath，表示行列
 * @return 返回该行列下的值
 */
CG_INLINE id ValueFromArrayAtIndexPath(NSArray * array,SIndexPath indexPath) {
    id obj = nil;
    if (array.count > indexPath.row) {
        NSArray * tempArray = [array objectAtIndex:indexPath.row];
        if ([tempArray isKindOfClass:[NSArray class]]) {
            if (tempArray.count > indexPath.column) {
                obj = [tempArray objectAtIndex:indexPath.column];
            }
        }
    }
    return obj;
}

/**
 * @brief 得到该数组中某个indexPath下的Int值
 *
 * @param array 需要得到的数组
 * @param indexPath 参见SIndexPath，表示行列
 * @return 返回该行列下的int值
 */
CG_INLINE NSInteger IntValueFromArrayAtIndexPath(NSArray * array,SIndexPath indexPath) {
    id obj = nil;
    if (array.count > indexPath.row) {
        NSArray * tempArray = [array objectAtIndex:indexPath.row];
        if ([tempArray isKindOfClass:[NSArray class]]) {
            if (tempArray.count > indexPath.column) {
                obj = [tempArray objectAtIndex:indexPath.column];
            }
        }
    }
    return [obj intValue];
}


/**
 * @brief 得到该数组中某行某列的Int值
 *
 * @param array 需要得到的数组
 * @param row   需要得到的行
 * @param column 需要得到的列
 * @return 返回该行列下的int值
 */
CG_INLINE NSInteger IntValueFromArrayAtRowAndColumn(NSArray * array,int row, int column) {
    return IntValueFromArrayAtIndexPath(array, SIndexPathMake(row, column));
}

/**
 * @brief 地图中元素的类型，包括 障碍物，搬运工，目标，路线等
 */
typedef enum _ElementType {
    SMapElementRedHouse         = 10,    // 红色的房子
    SMapElementYellowHouse      = 11,    // 黄色的房子
    SMapElementBlueHouse        = 12,    // 蓝色的房子
    SMapElementBluePoolUp       = 13,    // 蓝色的纵向池塘上
    SMapElementBluePoolDown     = 14,    // 蓝色的纵向池塘下
    SMapElementBluePoolLeft     = 15,    // 蓝色的横向池塘左
    SMapElementBluePoolRight    = 16,    // 蓝色的横向池塘右
    
    SMapElementGreenTree        = 20,    // 绿色的树
    SMapElementScenryTree       = 21,    // 风景树
    SMapElementGreenShrub       = 22,    // 绿色的草垛
    SMapElementYellowFlower     = 23,    // 黄色的花
    SMapElementRedWall          = 30,    // 红色的墙
    SMapElementRedBarricade     = 40,    // 红色的路障
    SMapElementBox              = 60,    // 箱子
    SMapElementGreenRoad        = 70,    // 绿色的路
    SMapElementMan              = 80,    // 搬运工
    SMapElementDst              = 90     // 目标，暂用泡泡表示
}SMapElementType;

/// 可以移动的类型
typedef enum _MoveType {
    SMoveDisabled,          // 不能移动
    SMoveEnabledWithMan,    // 只能移动人
    SMoveEnabledWithBoxMan  // 可以移动人和箱子
} SMoveType;

@protocol SGameDelegate;

@interface SMapLayer : CCLayer
/// 游戏控制协议。可以收到 游戏开始，结束等通知
@property (nonatomic, assign) id<SGameDelegate> delegate;

/**
 * @brief 加载某一关卡
 *
 * @param level 需要加载的关卡，里面包含游戏地图，背景音效等等
 */
- (void) loadMapWithLevel:(SLevel *) level;

/**
 * @brief 重新加载该关卡
 */
- (void) reloadMap;

@end


@protocol SGameDelegate <NSObject>

@required

/**
 * @brief 游戏已经开始。
 */
- (void) gameDidStart;

/**
 * @brief 游戏结束。
 */
- (void) gameDidFinish;

@optional

/**
 * @brief 搬运工移动。
 * 
 * @param withBox 是否带着箱子移动
 */
- (void) boxManDidMovedWithBox:(BOOL) withBox;

@end