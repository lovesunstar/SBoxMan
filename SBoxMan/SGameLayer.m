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
        self.mapLayer.delegate = self;
        [self.mapLayer loadMapWithLevel:[SLevelManager standardLevelManager].level];
        self.mapLayer.position = CGPointMake(20, -15);
        
        [self addChild:self.mapLayer z:1];
        
        
        CCMenuItemImage * bkgItemImage = [CCMenuItemImage itemWithNormalImage:@"menu.png" selectedImage:@"menu.png"];
        bkgItemImage.position = CGPointMake(0, 0);
        CCMenu * bkgMenu = [CCMenu menuWithItems:bkgItemImage, nil];
        bkgMenu.position = CGPointMake(winSize.width/2, winSize.height - 15);
        [self addChild:bkgMenu z:5];
        
        
        self.levelItemFont = [CCMenuItemFont itemWithString:@"正在加载"];
        self.levelItemFont.position = CGPointMake(40, 0);
        self.levelItemFont.scale = 0.6f;
        self.levelItemFont.color = ccYELLOW;
        self.levelCount = [SLevelManager standardLevelManager].currentLevel;
        
        self.stepItemFont = [CCMenuItemFont itemWithString:@"正在加载"];
        self.stepItemFont.scale = 0.6f;
        self.stepItemFont.color = ccYELLOW;
        self.stepItemFont.position = CGPointMake(200, 0);
        self.stepCount = 0;
        
        CCMenu * upperMenu = [CCMenu menuWithItems:self.levelItemFont, self.stepItemFont, nil];
        upperMenu.position = CGPointMake(30, winSize.height-15);
        [self addChild:upperMenu z:5 tag:1];
        
        CCMenuItemImage * prevLevel = [CCMenuItemImage itemWithNormalImage:@"previous.png" selectedImage:@"previous.png" block:^(id sender) {
            if ([[SLevelManager standardLevelManager] hasPrevLevel]) {
                [self.mapLayer loadMapWithLevel:[[SLevelManager standardLevelManager] prevLevel]];
                self.levelCount = [SLevelManager standardLevelManager].currentLevel;
            }
        }];
        prevLevel.position = CGPointMake(0, 0);
        
        CCMenuItemImage * nextLevel = [CCMenuItemImage itemWithNormalImage:@"next.png" selectedImage:@"next.png" block:^(id sender) {
            [self nextLevel];
        }];
        nextLevel.position = CGPointMake(40, 0);
        
        CCMenuItemImage * resetLevel = [CCMenuItemImage itemWithNormalImage:@"reset.png" selectedImage:@"reset.png" block:^(id sender) {
            [self.mapLayer reloadMap];
        }];
        resetLevel.position = CGPointMake(80, 0);
        
        CCMenu * menu = [CCMenu menuWithItems:prevLevel,nextLevel,resetLevel, nil];
        menu.position = CGPointMake(winSize.width - 140, winSize.height-15);
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
    NSString * string = [NSString stringWithFormat:@"%03d",stepCount];
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
