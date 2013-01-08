//
//  SMapLayer.m
//  SBoxMan
//
//  Created by SunJiangting on 12-12-6.
//
//

#import "SMapLayer.h"

@interface SMapLayer ()
/// 当前关数
@property (nonatomic, strong) SLevel * level;
/// 地图中的数据
@property (nonatomic, strong) NSArray * mapElements;
/// 共有几行
@property (nonatomic, assign) NSInteger rowCount;
/// 共有多少列
@property (nonatomic, assign) NSInteger columnCount;
/// 搬运工，保证地图中只有一个
@property (nonatomic, strong) SBoxMan * boxMan;
/// 所有的箱子
@property (nonatomic, strong) NSMutableArray * boxes;
/// 箱子所在的位置
@property (nonatomic, strong) NSMutableArray * boxArray;
/// 目的地所在的位置
@property (nonatomic, strong) NSMutableArray * destArray;
// 移动的起点，终点
@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint finish;

/**
 * @brief 得到该坐标对应数组中的行列
 *
 * @param point 需要获得的点
 * @return 返回改点对应的行列
 */
- (SIndexPath) indexPathAtPoint:(CGPoint) point;

/**
 * @brief 得到该行列下对应的坐标
 *
 * @param indexPath 二维数组的行列，第几行第几列
 * @return 该行列下对应的坐标
 */
- (CGPoint) pointAtIndexPath:(SIndexPath) indexPath;

/**
 * @brief 根据起点和终点 计算方向(上下左右)
 *
 * @param start 起点坐标
 * @param finish 终点坐标
 * @return 返回两点的方向
 */
- (SDirection) directionFromPoint:(CGPoint) start toPoint:(CGPoint) finish;

/**
 * @brief 某个方向上是否可以移动
 * 
 * @param direction 方向
 * @return 返回可以移动的类型 SMoveTypeDisabled 无法移动
 * @note 该方法不做移动，只是判断下一位置的坐标以及可不可以移动等等，由 pushManWithDirection:indexPath 和 pushBoxWithDirection:indexPath 负责移动动画以及音效
 */
- (SMoveType) canMoveWithDirection:(SDirection) direction;

/**
 * @brief 根据方向和当前的行列位置将搬运工移动到下一位置
 *
 * @param direction 方向
 * @param indexPath 当前位置在数组中的第几行第几列
 */
- (void) pushManWithDirection:(SDirection) direction indexPath:(SIndexPath) indexPath;

/**
 * @brief 根据方向和当前的行列位置将搬运工和箱子移动到下一位置
 *
 * @param direction 方向
 * @param indexPath 当前位置在数组中的第几行第几列
 */
- (void) pushBoxWithDirection:(SDirection) direction indexPath:(SIndexPath) indexPath;

/**
 * @brief 重新接受触摸事件
 */
- (void) enabledTouch;

/**
 * @brief 成功过关~
 */
- (void) win;

@end

@implementation SMapLayer

- (void) dealloc {
    [_boxMan release];
    [_boxArray release];
    [_level release];
    [_mapElements release];
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        self.boxes = [NSMutableArray arrayWithCapacity:5];
        self.boxArray = [NSMutableArray arrayWithCapacity:5];
        self.destArray = [NSMutableArray arrayWithCapacity:5];
        self.start = CGPointZero;
        self.finish = CGPointZero;
    }
    return self;
}

/**
 * @brief 加载某一关卡
 *
 * @param level 需要加载的关卡，里面包含游戏地图，背景音效等等
 */
- (void) loadMapWithLevel:(SLevel *) level {
    self.level = level;
    [self reloadMap];
}

/**
 * @brief 重新加载该关卡
 */
- (void) reloadMap {
    [self.boxes removeAllObjects];
    [self.boxArray removeAllObjects];
    [self.destArray removeAllObjects];
    [self.boxMan removeFromParentAndCleanup:YES];
    self.boxMan = nil;
    while ([self getChildByTag:2]) {
        [self removeChildByTag:2 cleanup:YES];
    }
    [_level resetMapElements];
    self.mapElements = self.level.mapElements;
    self.rowCount = self.mapElements.count;
    if (self.rowCount > 0) {
        self.columnCount = [[self.mapElements objectAtIndex:0] count];
    }
    [self loadMap];
}

/**
 * @brief 加载地图
 */
- (void) loadMap {
    int width = kBoxManLength  * self.columnCount;
    int height = kBoxManLength * self.rowCount;
    self.contentSize = CGSizeMake(width, height);
    [self.mapElements enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
        NSArray * rows = (NSArray *) obj1;
        [rows enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
            int type = [obj2 intValue];
            CGPoint position = [self pointAtIndexPath:SIndexPathMake(idx1, idx2)];
            CCSprite * sprite = [CCSprite spriteWithFile:@"green_road.png"];
            sprite.position = position;
            [self addChild:sprite z:99 tag:2];
            if (type == SMapElementRedHouse) {
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"house_red.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_5);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementBlueHouse) {
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"house_blue.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_5);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementYellowHouse) {
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"house_yellow.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_5);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementBluePoolUp) {
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"pool_up.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_5);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementBluePoolDown) {
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"pool_down.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_5);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementBluePoolLeft) {
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"pool_left.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_5);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementBluePoolRight) {
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"pool_right.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_5);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementGreenTree) {
                // 种树 . 如果是树的话 稍微往上 种一点
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"green_tree.png"];
                treeSprite.position = CGPointMake(position.x, position.y + kBoxManLength_4);
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementScenryTree) {
                // 风景树
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"scenery_tree.png"];
                treeSprite.position = position;
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementGreenShrub) {
               // 绿色草垛
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"green_shrub.png"];
                treeSprite.position = position;
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementYellowFlower) {
                // 绿色草垛
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"yellow_flower.png"];
                treeSprite.position = position;
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementRedWall) {
                // 种 障碍物
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"red_wall.png"];
                treeSprite.position = position;
                [self addChild:treeSprite z:990 tag:2];
            } else if (type == SMapElementRedBarricade) {
                // 绿色草垛
                CCSprite * treeSprite = [CCSprite spriteWithFile:@"red_barricade.png"];
                treeSprite.position = position;
                [self addChild:treeSprite z:991 tag:2];
            } else if (type == SMapElementBox){
                CCSprite * boxSprite = [CCSprite spriteWithFile:@"box.png"];
                boxSprite.position = position;
                [self addChild:boxSprite z:992 tag:2];
                [self.boxes addObject:boxSprite];
                [self.boxArray addObject:NSStringFromIndexPath(SIndexPathMake(idx1, idx1))];
            } else if (type == SMapElementDst) {
                CCSprite * boxSprite = [CCSprite spriteWithFile:@"balloon.png"];
                boxSprite.position = position;
                [self addChild:boxSprite z:990 tag:2];
                [self.destArray addObject:NSStringFromIndexPath(SIndexPathMake(idx1,idx2))];
            } else if (type == SMapElementMan) {
                // 搬运工 只有一个
                if (!self.boxMan) {
                    self.boxMan = [[[SBoxMan alloc] initWithPosition:position] autorelease];
                    [self addChild:self.boxMan z:993 tag:2];
                }
            }
        }];
    }];
    
    
    /// 预先加载箱子推动和胜利的声音
    
    if ([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
    [[SimpleAudioEngine sharedEngine] preloadEffect:self.level.pushEffect];
    [[SimpleAudioEngine sharedEngine] preloadEffect:self.level.winEffect];
    [[SimpleAudioEngine sharedEngine] playEffect:@"start.wav"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:self.level.backgroundMusic];
    
    if ([self.delegate respondsToSelector:@selector(gameDidStart)]) {
        [self.delegate performSelector:@selector(gameDidStart)];
    }
    self.isTouchEnabled = YES;
}

/**
 * @brief 得到该坐标对应数组中的行列
 *
 * @param point 需要获得的点
 * @return 返回改点对应的行列
 */
- (SIndexPath) indexPathAtPoint:(CGPoint) point {
    int x = point.x;
    int y = self.contentSize.height - point.y;
    int length = (int) kBoxManLength;
    return SIndexPathMake(y/length, x/length);
}

/**
 * @brief 得到该行列下对应的坐标
 *
 * @param indexPath 二维数组的行列，第几行第几列
 * @return 该行列下对应的坐标
 */
- (CGPoint) pointAtIndexPath:(SIndexPath) indexPath {
    CGFloat x = indexPath.column * kBoxManLength;
    CGFloat y = (self.rowCount - indexPath.row) * kBoxManLength;
    return CGPointMake(x, y);
}

/**
 * @brief 根据起点和终点 计算方向(上下左右)
 *
 * @param start 起点坐标
 * @param finish 终点坐标
 * @return 返回两点的方向
 */
- (SDirection) directionFromPoint:(CGPoint) start toPoint:(CGPoint) finish {
    SDirection direction = SDirectionUnknown;
    if (!CGPointEqualToPoint(start, finish)) {
        CGFloat offsetX = finish.x - start.x;
        CGFloat offsetY = finish.y - start.y;
        if (fabsf(offsetX) >= fabsf(offsetY)) {
            // 以X移动为准
            if (offsetX > kBoxManLength) {
                direction =  SDirectionRight;
            } else if(offsetX < -kBoxManLength){
                direction = SDirectionLeft;
            }
        } else {
            if (offsetY > kBoxManLength) {
                direction =  SDirectionDown;
            } else if (offsetY < -kBoxManLength){
                direction = SDirectionUp;
            }
        }
    }
    return direction;
}

#pragma mark === 推箱子 ===

/**
 * @brief 移动搬运工
 *
 * @param direction 方向
 * @note 该方法不做移动，只是判断下一位置的坐标以及可不可以移动等等，由 moveManWithDirection:indexPath 和 pushBoxWithDirection:indexPath 负责移动动画以及音效
 */
- (SMoveType) canMoveWithDirection:(SDirection) direction {
    /// 默认不可以移动
    SMoveType type = SMoveDisabled;
    SIndexPath indexPath = [self indexPathAtPoint:self.boxMan.position];
    NSArray * array = self.mapElements;
    
    switch (direction) {
        case SDirectionUp:
            // 如果向上移动，则必须保证[i-1][j]] > 0 || ([i-1][j]==0 && [i-2][j] > 0)
            if (indexPath.row >= 1) {
                // 如果 上一个节点 > 0 则为 road，man，dst,则肯定可以移动
                if (IntValueFromArrayAtRowAndColumn(array, indexPath.row-1, indexPath.column) > SMapElementBox) {
                    // 移动至下一个节点
                    type = SMoveEnabledWithMan;
                } else if (indexPath.row >= 2 && IntValueFromArrayAtRowAndColumn(array, indexPath.row-1, indexPath.column) == SMapElementBox && IntValueFromArrayAtRowAndColumn(array, indexPath.row-2, indexPath.column) > SMapElementBox){
                    // 连着箱子一起移动
                    type = SMoveEnabledWithBoxMan;
                }
            }
            break;
        case SDirectionDown:
            // 如果向下移动，则必须保证[i+1][j] > 0 || ([i+1][j]==0 && [i+2][j] > 0)
            if (indexPath.row <= self.rowCount-2) {
                // 如果 上一个节点 > 0 则为 road，man，dst,则肯定可以移动
                if (IntValueFromArrayAtRowAndColumn(array, indexPath.row+1, indexPath.column) > SMapElementBox) {
                    // 移动至下一个节点
                    type = SMoveEnabledWithMan;
                } else if (indexPath.row <= self.rowCount-3 && IntValueFromArrayAtRowAndColumn(array, indexPath.row +1, indexPath.column) == SMapElementBox && IntValueFromArrayAtRowAndColumn(array, indexPath.row +2, indexPath.column) > SMapElementBox){
                    // 连着箱子一起移动
                    type = SMoveEnabledWithBoxMan;
                }
            } 
            break;
        case SDirectionLeft:
            // 如果向下移动，则必须保证[i][j-1] > 0 || ([i][j-1]==0 && [i][j-2] > 0)
            if (indexPath.column >= 1) {
                // 如果 上一个节点 > 0 则为 road，man，dst,则肯定可以移动
                if (IntValueFromArrayAtRowAndColumn(array, indexPath.row, indexPath.column-1) > SMapElementBox) {
                    type = SMoveEnabledWithMan;
                    // 移动至下一个节点
                } else if (indexPath.column >= 2 && IntValueFromArrayAtRowAndColumn(array, indexPath.row, indexPath.column-1) == SMapElementBox && IntValueFromArrayAtRowAndColumn(array, indexPath.row, indexPath.column-2) > SMapElementBox){
                    // 连着箱子一起移动
                    type = SMoveEnabledWithBoxMan;
                }
            }
            break;
        case SDirectionRight:
            // 如果向下移动，则必须保证[i][j+1] > 0 || ([i][j+1]==0 && [i][j+2] > 0)
            if (indexPath.column <= self.columnCount-2) {
                // 如果 上一个节点 > 0 则为 road，man，dst,则肯定可以移动
                if (IntValueFromArrayAtRowAndColumn(array, indexPath.row, indexPath.column+1) > SMapElementBox) {
                    type = SMoveEnabledWithMan;
                } else if (indexPath.column <= self.columnCount-3 && IntValueFromArrayAtRowAndColumn(array, indexPath.row, indexPath.column+1) == SMapElementBox && IntValueFromArrayAtRowAndColumn(array, indexPath.row, indexPath.column+2) > SMapElementBox){
                    // 连着箱子一起移动
                    type = SMoveEnabledWithBoxMan;
                }
            }
            break;
        default:
            break;
    }
    return type;
}


/**
 * @brief 根据方向和当前的行列位置将搬运工移动到下一位置
 *
 * @param direction 方向
 * @param indexPath 当前位置在数组中的第几行第几列
 */
- (void) pushManWithDirection:(SDirection) direction indexPath:(SIndexPath) indexPath {

    SIndexPath indexPath1;
    // 根据方向和当前位置，计算出下一个到的地方
    switch (direction) {
        case SDirectionUp:
            // 向上推箱子
            indexPath1 = SIndexPathMake(indexPath.row - 1, indexPath.column);
            break;
        case SDirectionDown:
            // 向下推箱子
            indexPath1 = SIndexPathMake(indexPath.row + 1, indexPath.column);
            break;
        case SDirectionLeft:
            // TODO:向左推箱子
            indexPath1 = SIndexPathMake(indexPath.row, indexPath.column - 1);
            break;
        case SDirectionRight:
            // TODO:向右推箱子
            indexPath1 = SIndexPathMake(indexPath.row, indexPath.column + 1);
            break;
        default:
            return;
    }
    // 移动人物
    CGPoint position = [self pointAtIndexPath:indexPath1];
    CCMoveTo * moveTo = [CCMoveTo actionWithDuration:kMoveDuration position:position];
    [self.boxMan runAction:moveTo];
    // 将当前位置标记为可走，下一位置标记为人
    SetArrayAtIndexPath(self.mapElements, indexPath, @(SMapElementGreenRoad));
    SetArrayAtIndexPath(self.mapElements, indexPath1, @(SMapElementMan));
    if ([self.delegate respondsToSelector:@selector(boxManDidMovedWithBox:)]) {
        [self.delegate boxManDidMovedWithBox:NO];
    }
}

/**
 * @brief 根据方向和当前的行列位置将搬运工和箱子移动到下一位置
 *
 * @param direction 方向
 * @param indexPath 当前位置在数组中的第几行第几列
 */
- (void) pushBoxWithDirection:(SDirection) direction indexPath:(SIndexPath) indexPath {
    // 播放推箱子音效
    [[SimpleAudioEngine sharedEngine] playEffect:self.level.pushEffect];
    // 下一个箱子和下下一个箱子的位置
    SIndexPath indexPath1, indexPath2;
    // 根据方向和当前的位置，算出 现在箱子的位置和箱子即将要去的位置
    switch (direction) {
        case SDirectionUp:
            // 向上推箱子
            indexPath1 = SIndexPathMake(indexPath.row - 1, indexPath.column);
            indexPath2 = SIndexPathMake(indexPath.row - 2, indexPath.column);
            break;
        case SDirectionDown:
            // 向下推箱子
            indexPath1 = SIndexPathMake(indexPath.row + 1, indexPath.column);
            indexPath2 = SIndexPathMake(indexPath.row + 2, indexPath.column);
            break;
        case SDirectionLeft:
            // TODO:向左推箱子
            indexPath1 = SIndexPathMake(indexPath.row, indexPath.column - 1);
            indexPath2 = SIndexPathMake(indexPath.row, indexPath.column - 2);
            break;
        case SDirectionRight:
            // TODO:向右推箱子
            indexPath1 = SIndexPathMake(indexPath.row, indexPath.column + 1);
            indexPath2 = SIndexPathMake(indexPath.row, indexPath.column + 2);
            break;
        default:
            return;
    }
    /// 从箱子的数组中选出当前推动的箱子，然后移动箱子到下一个位置，人则站在箱子的位置
    for (CCSprite * sprite in self.boxes) {
        SIndexPath idxPath = [self indexPathAtPoint:sprite.position];
        if (SIndexPathEqual(indexPath1, idxPath)) {
            // 下一个箱子
            CGPoint manPosition = [self pointAtIndexPath:indexPath1];
            CCMoveTo * moveTo1 = [CCMoveTo actionWithDuration:kMoveDuration position:manPosition];
            [self.boxMan runAction:moveTo1];
            CGPoint boxPosition = [self pointAtIndexPath:indexPath2];
            CCMoveTo * moveTo2 = [CCMoveTo actionWithDuration:kMoveDuration position:boxPosition];
            [sprite runAction:moveTo2];
            int index = [self.boxes indexOfObject:sprite];
            [self.boxArray replaceObjectAtIndex:index withObject:NSStringFromIndexPath(indexPath2)];
            break;
        }
    }
    /// 将当前位置标记为 可以走过
    SetArrayAtIndexPath(self.mapElements, indexPath, @(SMapElementGreenRoad));
    /// 将当前箱子的位置标记为人
    SetArrayAtIndexPath(self.mapElements, indexPath1, @(SMapElementMan));
    /// 将下一个位置标记成箱子
    SetArrayAtIndexPath(self.mapElements, indexPath2, @(SMapElementBox));
    if ([self.delegate respondsToSelector:@selector(boxManDidMovedWithBox:)]) {
        [self.delegate boxManDidMovedWithBox:YES];
    }
    
    BOOL finish;
    for (NSString * string in self.boxArray) {
        SIndexPath idxp1 = SIndexPathFromNSString(string);
        BOOL contains = NO;
        for (NSString * string in self.destArray) {
            SIndexPath idxp2 = SIndexPathFromNSString(string);
            contains = SIndexPathEqual(idxp1, idxp2);
            if (contains) {
                break;
            }
        }
        if (!contains) {
            finish = NO;
            break;
        } else {
            finish = YES;
        }
    }
    if (finish) {
        self.isTouchEnabled = NO;
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [self performSelector:@selector(win) withObject:nil afterDelay:kMoveDuration];
    }
}

#pragma mark === 通过游戏 === 
/**
 * @brief 成功过关~
 */
- (void) win {
    [[SimpleAudioEngine sharedEngine] playEffect:self.level.winEffect];
    if ([self.delegate respondsToSelector:@selector(gameDidFinish)]) {
        [self.delegate performSelector:@selector(gameDidFinish)];
    }
}

/**
 * @brief 重新接受触摸事件
 */
- (void) enabledTouch {
    self.isTouchEnabled = YES;
}


#pragma mark === 手势 ===

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch=[touches anyObject];
    self.start = [touch locationInView:touch.view];
    
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    self.finish = [touch locationInView:touch.view];
    SDirection direction = [self directionFromPoint:self.start toPoint:self.finish];
    if (direction != SDirectionUnknown) {
        self.isTouchEnabled = NO;
        [self.boxMan stopAllActions];
        self.boxMan.direction = direction;
        SIndexPath indexPath = [self indexPathAtPoint:self.boxMan.position];
        SMoveType moveType = [self canMoveWithDirection:direction];
        if (moveType == SMoveEnabledWithMan) {
            [self pushManWithDirection:direction indexPath:indexPath];
        } else if (moveType == SMoveEnabledWithBoxMan) {
            [self pushBoxWithDirection:direction indexPath:indexPath];
        }
        [self performSelector:@selector(enabledTouch) withObject:nil afterDelay:kMoveDuration];
    }
}

- (void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.start = CGPointZero;
    self.finish = CGPointZero;
}
@end
