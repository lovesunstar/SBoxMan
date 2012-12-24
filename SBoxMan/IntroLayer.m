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
        
        CCSprite * background = [CCSprite spriteWithFile:@"welcome.png"];
        background.contentSize = winSize;
        background.position = CGPointMake(winSize.width/2, winSize.height/2);
        [self addChild:background z:0 tag:1];
        
        CCMenuItemImage * startItem = [CCMenuItemImage itemWithNormalImage:@"start.png" selectedImage:@"start.png" block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SGameLayer scene] withColor:ccWHITE]];
        }];
        startItem.position = CGPointMake(0, 0);
    
        CCMenuItemImage * introduceItem = [CCMenuItemImage itemWithNormalImage:@"introduce.png" selectedImage:@"introduce.png" block:^(id sender) {
            // TODO:介绍
        }];
        introduceItem.position = CGPointMake(190, 0);
        CCMenu * menu = [CCMenu menuWithItems:startItem, introduceItem, nil];
        menu.position = CGPointMake(140, 80);
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
