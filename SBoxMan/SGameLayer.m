//
//  SGameLayer.m
//  SBoxMan
//
//  Created by SunJiangting on 12-12-8.
//
//

#import "SGameLayer.h"

@interface SGameLayer ()

@property (nonatomic, strong) SMapLayer * mapLayer;

@property (nonatomic, strong) CCMenuItemFont * levelItemFont;
@property (nonatomic, assign) NSInteger levelCount;
@property (nonatomic, strong) CCMenuItemFont * stepItemFont;
@property (nonatomic, assign) NSInteger stepCount;

@end

@implementation SGameLayer

+ (CCScene *) scene {
    CCScene * scene = [CCScene node];
    SGameLayer * gameLayer = [SGameLayer node];
    gameLayer.contentSize = [CCDirector sharedDirector].winSize;
    [scene addChild:gameLayer];
    return scene;
}

- (void) dealloc {
    [_stepItemFont release];
    [_mapLayer release];
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite * sprite = [CCSprite spriteWithFile:@"background.png"];
        sprite.position = CGPointMake(winSize.width/2, winSize.height/2);
        [self addChild:sprite];
        
        self.mapLayer = [SMapLayer node];
        self.mapLayer.position = CGPointMake(20, -5);
        self.mapLayer.delegate = self;
        [self addChild:self.mapLayer z:1];
        [self.mapLayer loadMapWithLevel:[SLevelManager standardLevelManager].level];
        
        self.levelItemFont = [CCMenuItemFont itemWithString:@"正在加载"];
        self.levelItemFont.position = CGPointMake(0, 40);
        self.levelItemFont.color = ccYELLOW;
        self.levelCount = [SLevelManager standardLevelManager].currentLevel;
        
        self.stepItemFont = [CCMenuItemFont itemWithString:@"正在加载"];
        self.stepItemFont.color = ccYELLOW;
        self.stepItemFont.position = CGPointMake(0, 0);
        self.stepCount = 0;
        CCMenu * upperMenu = [CCMenu menuWithItems:self.levelItemFont, self.stepItemFont, nil];
        upperMenu.position = CGPointMake(winSize.width-80, 240);
        [self addChild:upperMenu z:5 tag:1];
        
        
        CCMenuItemFont * resetLevelFont = [CCMenuItemFont itemWithString:@"Restart" block:^(id sender) {
            [self.mapLayer reloadMap];
            
        }];
        resetLevelFont.position = CGPointMake(0, 80);
        
        CCMenuItemFont * prevLevelFont = [CCMenuItemFont itemWithString:@"Previois" block:^(id sender) {
            if ([[SLevelManager standardLevelManager] hasPrevLevel]) {
                [self.mapLayer loadMapWithLevel:[[SLevelManager standardLevelManager] prevLevel]];
                self.levelCount = [SLevelManager standardLevelManager].currentLevel;
            }
        }];
        prevLevelFont.position = CGPointMake(0, 40);
        
        CCMenuItemFont * nextLevelFont = [CCMenuItemFont itemWithString:@"Next" block:^(id sender) {
            [self nextLevel];
        }];
        nextLevelFont.position = CGPointMake(0, 0);
        CCMenu * menu = [CCMenu menuWithItems:resetLevelFont,prevLevelFont,nextLevelFont, nil];
        menu.position = CGPointMake(winSize.width-80, 40);
        [self addChild:menu z:5 tag:1];
    }
    return self;
}

- (void) nextLevel {
    if ([[SLevelManager standardLevelManager] hasNextLevel]) {
        SLevel * level = [[SLevelManager standardLevelManager] nextLevel];
        [self.mapLayer loadMapWithLevel:level];
        self.levelCount = [SLevelManager standardLevelManager].currentLevel;
    }
}

- (void) setLevelCount:(NSInteger)levelCount {
    NSString * string = [NSString stringWithFormat:@"Level : %d",levelCount+1];
    [self.levelItemFont setString:string];
    _levelCount = levelCount;
}

- (void) setStepCount:(NSInteger)stepCount {
    NSString * string = [NSString stringWithFormat:@"Step : %d",stepCount];
    [self.stepItemFont setString:string];
    _stepCount = stepCount;
}

- (void) gameDidStart {
    
    self.stepCount = 0;
    SLog(@"这一关开始啦~~~~");
}

- (void) gameDidFinish {
    SLog(@"这一关结束啦~~恭喜过关");
    [self performSelector:@selector(nextLevel) withObject:nil afterDelay:1.0f];
}

- (void) boxManDidMovedWithBox:(BOOL)withBox {
    self.stepCount ++;
    if (withBox) {
        SLog(@"我是推着箱子动的哦~~");
    } else {
        SLog(@"哼~~没有箱子我也可以动");
    }
}
@end
