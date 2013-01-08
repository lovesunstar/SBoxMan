//
//  SLevel.h
//  SBoxMan
//
//  Created by SunJiangting on 12-12-7.
//
//

@interface SLevel : NSObject

@property (nonatomic, readonly) NSString * backgroundMusic;
@property (nonatomic, readonly) NSString * pushEffect;
@property (nonatomic, readonly) NSString * winEffect;
@property (nonatomic, readonly) NSInteger  level;
@property (nonatomic, readonly) NSString * backgroundThumb;
@property (nonatomic, readonly) NSArray * mapElements;

+ (id) levelWithDictionary:(NSDictionary *) dictionary;

- (id) initWithDictionary:(NSDictionary *) dictionary;

- (void) resetMapElements;

- (NSDictionary *) toDictionary;

@end