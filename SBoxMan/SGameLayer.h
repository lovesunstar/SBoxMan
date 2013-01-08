//
//  SGameLayer.h
//  SBoxMan
//
//  Created by SunJiangting on 12-12-8.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "SMapLayer.h"

@interface SGameLayer : CCLayer <SGameDelegate>

+ (CCScene *) scene;

@property (nonatomic, assign) NSInteger level;

@end
