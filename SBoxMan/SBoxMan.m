//
//  SMan.m
//  SBoxMan
//
//  Created by SunJiangting on 12-12-6.
//
//

#import "SBoxMan.h"

@implementation SBoxMan

- (id) initWithPosition:(CGPoint) position {
    self = [super initWithFile:@"man_baby.png"];
    if (self) {
        self.position = position;
        self.direction = SDirectionDown;
    }
    return self;
}

- (void) setDirection:(SDirection)direction {
    if (direction != _direction ) {
        // TODO:设置方向
        NSString * imageName = @"man_baby.png";
        switch (direction) {
            case SDirectionUp:
                imageName = @"man_baby_up.png";
                break;
            case SDirectionDown:
                imageName = @"man_baby_down.png";
                break;
            case SDirectionLeft:
                imageName = @"man_baby_left.png";
                break;
            case SDirectionRight:
                imageName = @"man_baby_right.png";
                break;
            default:
                break;
        }
        CCSprite * sprite = [CCSprite spriteWithFile:imageName];
        self.texture = sprite.texture;
        _direction = direction;
    }
    
}


@end
