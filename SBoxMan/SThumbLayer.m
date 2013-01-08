//
//  SThumbLayer.m
//  SBoxMan
//
//  Created by SunJiangting on 13-1-5.
//
//

#import "SThumbLayer.h"

@interface SThumbLayer ()

@end

@implementation SThumbLayer

+ (id) thumbLayerWithLevel:(SLevel *) level {
    return [[[self alloc] initWithLevel:level] autorelease];
}


- (void) dealloc {
    [super dealloc];
}


- (id) initWithLevel:(SLevel *) level {
    self = [super init];
    if (self) {
        /// 466  *  316
        self.anchorPoint = ccp(0, 0);
        self.contentSize = CGSizeMake(233, 158);
        CCSprite * thumb = [CCSprite spriteWithFile:level.backgroundThumb];
        thumb.anchorPoint = ccp(0, 0);
        thumb.position = CGPointMake(3, 7);
        [self addChild:thumb];
        
        CCSprite * border = [CCSprite spriteWithFile:@"level_border.png"];
        border.anchorPoint = ccp(0, 0);
        border.position = ccp(0, 0);
        [self addChild:border z:1];
        
        CCSprite * levelBkg = [CCSprite spriteWithFile:@"level_bkg.png"];
        levelBkg.anchorPoint = ccp(0, 0);
        levelBkg.position = ccp(15, 127);
        [self addChild:levelBkg z:2];
        
        CCTexture2D * levelText = [[CCTexture2D alloc] initWithString:[NSString stringWithFormat:@"%02d",level.level] fontName:@"AmericanTypewriter-Bold" fontSize:24];
        
        CCSprite * level = [CCSprite spriteWithTexture:levelText];
        [levelText release];
        level.anchorPoint = ccp(0, 0);
        level.position = ccp(22, 136);
        [self addChild:level z:3];
        
    }
    return self;
}



@end
