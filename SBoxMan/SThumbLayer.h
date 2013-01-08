//
//  SThumbLayer.h
//  SBoxMan
//
//  Created by SunJiangting on 13-1-5.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "SLevel.h"

@interface SThumbLayer : CCLayer

+ (id) thumbLayerWithLevel:(SLevel *) level;

- (id) initWithLevel:(SLevel *) level;

@end
