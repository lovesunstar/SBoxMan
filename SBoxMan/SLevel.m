//
//  SLevel.m
//  SBoxMan
//
//  Created by SunJiangting on 12-12-7.
//
//

#import "SLevel.h"

@interface SLevel ()

@property (nonatomic, copy) NSString * mapString;
@property (nonatomic, copy) NSString * mapName;

@end

@implementation SLevel

+ (id) levelWithDictionary:(NSDictionary *) dictionary {
    return [[[SLevel alloc] initWithDictionary:dictionary] autorelease];
}

- (id) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        
        self.mapName = [dictionary objectForKey:@"map"];
        _level = [[dictionary objectForKey:@"level"] intValue];
        if ([dictionary objectForKey:@"backgroundMusic"]) {
            NSString * backgroundMusic = [dictionary objectForKey:@"backgroundMusic"];
            _backgroundMusic = [backgroundMusic copy];
        } else {
            _backgroundMusic = @"background.wav";
        }
        if ([dictionary objectForKey:@"backgroundThumb"]) {
            NSString * backgroundThumb = [dictionary objectForKey:@"backgroundThumb"];
            _backgroundThumb = [backgroundThumb copy];
        } else {
            _backgroundThumb = @"thumb_level.png";
        }
        if ([dictionary objectForKey:@"pushEffect"]) {
            NSString * pushEffect = [dictionary objectForKey:@"pushEffect"];
            _pushEffect = [pushEffect copy];
        } else {
            _pushEffect = @"push_box.wav";
        }
        if ([dictionary objectForKey:@"winEffect"]) {
            _winEffect = [[dictionary objectForKey:@"winEffect"] copy];
        } else {
            _winEffect = @"win.wav";
        }
        
        _mapElements = [[NSMutableArray arrayWithCapacity:10] retain];
        
        NSString * fileName = [[NSBundle mainBundle] pathForResource:self.mapName ofType:nil];
        self.mapString = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];
        
        [self resetMapElements];
        
    }
    return self;
}

- (void) dealloc {
    [_backgroundMusic release];
    [_backgroundThumb release];
    [_pushEffect release];
    [_winEffect release];
    [_mapName release];
    [_mapElements release];
    [_mapString release];
    _mapString = nil;
    [super dealloc];
}


- (void) resetMapElements {
    NSMutableArray * mapElements = (NSMutableArray *) _mapElements;
    [mapElements removeAllObjects];
    NSString * tempString = [self.mapString copy];
    if (tempString.length > 0) {
        NSArray * rows = [tempString componentsSeparatedByString:@"\n"];
        for (NSString * row in rows) {
            NSArray * array = [row componentsSeparatedByString:@","];
            NSMutableArray * columns = [NSMutableArray arrayWithCapacity:10];
            for (NSString * temp in array) {
                if (temp.length > 0) {
                    [columns addObject:@([temp intValue])];
                }
            }
            [mapElements addObject:columns];
        }
    }
    [tempString release];
    tempString = nil;
}

- (NSDictionary *) toDictionary {
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setValue:_backgroundMusic forKey:@"backgroundMusic"];
    [dict setValue:_pushEffect forKey:@"pushEffect"];
    [dict setValue:@(_level) forKey:@"level"];
    [dict setValue:_mapName forKey:@"map"];
    return dict;
}

- (NSString *) description {
    return [[self toDictionary] description];
}

@end
