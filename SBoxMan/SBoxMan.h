//
//  SBoxMan.h
//  SBoxMan
//
//  Created by SunJiangting on 12-12-6.
//
//

#import "cocos2d.h"

#define kBoxManLength   30.0f
#define kBoxManLength_2 15.0f
#define kBoxManLength_3 10.0f
#define kBoxManLength_4 7.5f
#define kBoxManLength_5 6.0f

typedef enum SDirection {
    SDirectionUp,
    SDirectionDown,
    SDirectionLeft,
    SDirectionRight,
    SDirectionUnknown,
} SDirection;

@interface SBoxMan : CCSprite
/// 当前方向
@property (nonatomic, assign) SDirection direction;

- (id) initWithPosition:(CGPoint) position;

//- (void) moveWithDirection:(SDirection) direction destination:(CGPoint) destination;

@end
