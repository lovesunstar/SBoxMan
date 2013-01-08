//
//  IntroLayer.m
//  SBoxMan
//
//  Created by SunJiangting on 12-12-6.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "SGameLayer.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}

- (id) init {
    self = [super init];
    if (self) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.contentSize = winSize;
        
        NSMutableArray * layers = [NSMutableArray arrayWithCapacity:5];
        NSArray * levels = [SLevelManager standardLevelManager].levelArray;
        for (SLevel * level in levels) {
            SThumbLayer * layer = [SThumbLayer thumbLayerWithLevel:level];
            [layers addObject:layer];
        }
        
        __block CCScrollLayer * scrollLayer = [CCScrollLayer nodeWithLayers:layers layerWidth:233 widthOffset:40];
        scrollLayer.anchorPoint = ccp(0, 0);
        scrollLayer.position = ccp(0, 90);
        [scrollLayer selectPage:0];
        
        [self addChild:scrollLayer z:5];
        
        CCSprite * background = [CCSprite spriteWithFile:@"background.png"];
        background.contentSize = winSize;
        background.anchorPoint = ccp(0, 0);
        background.position = CGPointMake(0, 0);
        [self addChild:background z:0 tag:1];
        
        CCMenuItemImage * startItem = [CCMenuItemImage itemWithNormalImage:@"start.png" selectedImage:@"start.png" block:^(id sender) {
            [SLevelManager standardLevelManager].currentLevel = scrollLayer.currentScreen;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SGameLayer scene] withColor:ccWHITE]];
        }];
        startItem.position = CGPointMake(0, 0);

        CCMenu * menu = [CCMenu menuWithItems:startItem, nil];
        menu.position = CGPointMake(240, 40);
        [self addChild:menu];
    }
    return self;
}

// 
-(void) onEnter
{
	[super onEnter];
}

@end
