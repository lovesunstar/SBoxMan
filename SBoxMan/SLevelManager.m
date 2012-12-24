//
//  SLevelManager.m
//  SBoxMan
//
//  Created by SunJiangting on 12-12-7.
//
//

#import "SLevelManager.h"

@interface SLevelManager ()

@property (nonatomic, strong) NSMutableArray * levelArray;

@end

@implementation SLevelManager

static SLevelManager * _levelManager;

+ (SLevelManager *) standardLevelManager {
    @synchronized(self) {
        if (!_levelManager) {
            _levelManager = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return _levelManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self.levelArray = [NSMutableArray arrayWithCapacity:5];
        NSString * path = [[NSBundle mainBundle] pathForResource:@"boxman" ofType:@"plist"];
        NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray * levels = [dictionary objectForKey:@"Levels"];
        for (NSDictionary * dict in levels) {
            SLevel * level = [SLevel levelWithDictionary:dict];
            [self.levelArray addObject:level];
        }
        NSNumber * levelNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"level"];
        if ([levelNumber isKindOfClass:[NSNumber class]]) {
            _currentLevel = [levelNumber intValue];
        } else {
            _currentLevel = 0;
        }
        _level = [[self.levelArray objectAtIndex:_currentLevel] retain];
    }
    return self;
}


/**
 * @brief 是否存在上一关
 *
 * @return 是否存在上一关
 */
- (BOOL) hasPrevLevel {
    return _currentLevel > 0;
}

/**
 * @brief 是否存在下一关
 *
 * @return 是否存在下一关
 */
- (BOOL) hasNextLevel {
    return _currentLevel < self.levelArray.count -1;
}

/**
 * @brief 得到上一关
 *
 * @return 上一关的数据，会根据 boxman.plist 读取的信息和当前关数确定上一关
 * @note 如果不存在上一关，则返回nil。最好配合hasPrevLevel 使用
 */
- (SLevel *) prevLevel {
    int prevLevel = _currentLevel - 1;
    if (prevLevel >= 0) {
        _currentLevel -= 1;
        [_level release];
        _level = [[self.levelArray objectAtIndex:prevLevel] retain];
        return [self.levelArray objectAtIndex:prevLevel];
    } else {
        SLog(@"没有上一关了~~~~");
        return nil;
    }
}

/**
 * @brief 得到下一关
 *
 * @return 下一关的数据，会根据 boxman.plist 读取的信息和当前关数确定下一关
 * @note 如果不存在下一关，则返回nil。最好配合hasNextLevel 使用
 */
- (SLevel *) nextLevel {
    int nextLevel = _currentLevel + 1;
    if (nextLevel < self.levelArray.count) {
        _currentLevel += 1;
        [_level release];
        _level = [[self.levelArray objectAtIndex:nextLevel] retain];
        return [self.levelArray objectAtIndex:nextLevel];
    } else {
        SLog(@"没有下一关了~~~~");
        return nil;
    }
}

+ (id) allocWithZone:(NSZone *)zone {
    return [[self standardLevelManager] retain];
}

- (id) copyWithZone:(NSZone*)zone {
    return self;
}

- (void) dealloc {
    [_level release];
    [_levelArray release];
    [super dealloc];
}

- (id) retain {
    return self;
}


- (NSUInteger) retainCount {
    return NSUIntegerMax;
}

- (id) autorelease {
    return self;
}

@end
