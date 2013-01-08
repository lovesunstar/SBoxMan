/*
 * CCScrollLayer
 *
 * Cocos2D-iPhone-Extensions v0.2.1
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright 2010 DK101
 * http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/
 *
 * Copyright 2010 Giv Parvaneh.
 * http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/
 *
 * Copyright 2011-2012 Stepan Generalov
 * Copyright 2011 Brian Feller
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CCScrollLayer.h"
#import "CCGL.h"

enum
{
	kCCScrollLayerStateIdle,
	kCCScrollLayerStateSliding,
};

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers;

@end

@implementation CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers
{
	return targetedHandlers;
}

@end
#endif

@interface CCScrollLayer ()

- (int) pageNumberAtOrigin:(CGPoint) origin;

- (CGPoint) originFromPageNumber:(NSUInteger) pageNumber;

@end

@implementation CCScrollLayer

@synthesize delegate = delegate_;
@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize minimumTouchLengthToChangePage = minimumTouchLengthToChangePage_;
@synthesize marginOffset = marginOffset_;
@synthesize currentScreen = currentScreen_;
@synthesize showPagesIndicator = showPagesIndicator_;
@synthesize pagesIndicatorPosition = pagesIndicatorPosition_;
@synthesize pagesIndicatorNormalColor = pagesIndicatorNormalColor_;
@synthesize pagesIndicatorSelectedColor = pagesIndicatorSelectedColor_;
@synthesize pagesWidthOffset = pagesWidthOffset_;
@synthesize pages = layers_;
@synthesize stealTouches = stealTouches_;

@dynamic totalScreens;
- (int) totalScreens
{
	return [layers_ count];
}

+(id) nodeWithLayers:(NSArray *)layers layerWidth:(CGFloat) width widthOffset: (int) widthOffset
{
	return [[[self alloc] initWithLayers: layers layerWidth:(CGFloat) width  widthOffset:widthOffset] autorelease];
}

-(id) initWithLayers:(NSArray *)layers layerWidth:(CGFloat) width widthOffset: (int) widthOffset
{
	if ( (self = [super init]) )
	{
		NSAssert([layers count], @"CCScrollLayer#initWithLayers:widthOffset: you must provide at least one layer!");
		
		self.isTouchEnabled = YES;
        
		self.stealTouches = YES;
        _layerWidth = width;
		// Set default minimum touch length to scroll.
		self.minimumTouchLengthToSlide = 20.0f;
		self.minimumTouchLengthToChangePage = 50.0f;
        
		self.marginOffset = [[CCDirector sharedDirector] winSize].width;
        
		// Show indicator by default.
		self.showPagesIndicator = YES;
		self.pagesIndicatorPosition = ccp(0.5f * self.contentSize.width, ceilf ( self.contentSize.height / 8.0f ));
		self.pagesIndicatorNormalColor = ccc4(0x96,0x96,0x96,0xFF);
        self.pagesIndicatorSelectedColor = ccc4(0xFF,0xFF,0xFF,0xFF);
        
		// Set up the starting variables
		currentScreen_ = 0;
        
		// Save offset.
		self.pagesWidthOffset = widthOffset;
        
		// Save array of layers.
		layers_ = [[NSMutableArray alloc] initWithArray:layers copyItems:NO];
        
		[self updatePages];
        
	}
	return self;
}

- (void) dealloc
{
	self.delegate = nil;
    
	[layers_ release];
	layers_ = nil;
    
	[super dealloc];
}

- (void) updatePages {
	// Loop through the array and add the screens if needed.
	int i = 0;
    CGFloat width = 0.0f;
	for (CCLayer *l in layers_) {
		l.anchorPoint = ccp(0,0);
		l.position = ccp((_layerWidth + self.pagesWidthOffset) * i, 0);
		if (!l.parent)
			[self addChild:l];
		i++;
	}
    self.contentSize = CGSizeMake(width, self.contentSize.height);
    CGFloat margin = ([CCDirector sharedDirector].winSize.width - _layerWidth) / 2;
    self.position = ccp(margin, self.position.y);
}

- (int) pageNumberAtOrigin:(CGPoint) origin {
    
    CGFloat winWidth = [CCDirector sharedDirector].winSize.width;
    CGFloat margin = (winWidth - _layerWidth) / 2;
    
	CGFloat pageFloat = - (origin.x - margin) / (_layerWidth + self.pagesWidthOffset);
	int pageNumber = ceilf(pageFloat);
	if ( (CGFloat)pageNumber - pageFloat  >= 0.5f)
		pageNumber--;
    
    
	pageNumber = MAX(0, pageNumber);
	pageNumber = MIN([layers_ count] - 1, pageNumber);
    
	return pageNumber;
}

- (CGPoint) originFromPageNumber:(NSUInteger) pageNumber {
    
    CGFloat winWidth = [CCDirector sharedDirector].winSize.width;
    CGFloat left = pageNumber * (_layerWidth + self.pagesWidthOffset);
    CGFloat margin = (winWidth - _layerWidth) / 2;
    
    return ccp(margin - left, self.position.y);
    
}

-(void) selectPage:(int)page {
    if (page < 0 || page >= [layers_ count]) {
        CCLOGERROR(@"CCScrollLayer#selectPage: %d - wrong page number, out of bounds. ", page);
		return;
    }
    
    self.position = [self originFromPageNumber: page];
    prevScreen_ = currentScreen_;
    currentScreen_ = page;
    
}

-(void) moveToPage:(int)page {
    if (page < 0 || page >= [layers_ count]) {
        CCLOGERROR(@"CCScrollLayer#moveToPage: %d - wrong page number, out of bounds. ", page);
		return;
    }
    
	id changePage = [CCMoveTo actionWithDuration:0.3 position: [self originFromPageNumber: page]];
	changePage = [CCSequence actions: changePage,[CCCallFunc actionWithTarget:self selector:@selector(moveToPageEnded)], nil];
    [self runAction:changePage];
    currentScreen_ = page;
    
}


#pragma mark Moving To / Selecting Pages

- (void) moveToPageEnded {
    if (prevScreen_ != currentScreen_)
    {
        if ([self.delegate respondsToSelector:@selector(scrollLayer:scrolledToPageNumber:)])
            [self.delegate scrollLayer: self scrolledToPageNumber: currentScreen_];
    }
    
    prevScreen_ = currentScreen_ = [self pageNumberAtOrigin:self.position];
}

#pragma mark Touches
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** Register with more priority than CCMenu's but don't swallow touches. */
-(void) registerWithTouchDispatcher
{
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = kCCMenuHandlerPriority - 1;
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
    int priority = kCCMenuTouchPriority - 1;
#endif
    
	[dispatcher addTargetedDelegate:self priority: priority swallowsTouches:NO];
}
/** Hackish stuff - stole touches from other CCTouchDispatcher targeted delegates.
 Used to claim touch without receiving ccTouchBegan. */
- (void) claimTouch: (UITouch *) aTouch
{
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
#endif
    
	// Enumerate through all targeted handlers.
	for ( CCTargetedTouchHandler *handler in [dispatcher targetedHandlers] )
	{
		// Only our handler should claim the touch.
		if (handler.delegate == self)
		{
			if (![handler.claimedTouches containsObject: aTouch])
			{
				[handler.claimedTouches addObject: aTouch];
			}
		}
        else
        {
            // Steal touch from other targeted delegates, if they claimed it.
            if ([handler.claimedTouches containsObject: aTouch])
            {
                if ([handler.delegate respondsToSelector:@selector(ccTouchCancelled:withEvent:)])
                {
                    [handler.delegate ccTouchCancelled: aTouch withEvent: nil];
                }
                [handler.claimedTouches removeObject: aTouch];
            }
        }
	}
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if( scrollTouch_ == touch ) {
        scrollTouch_ = nil;
        [self selectPage: currentScreen_];
    }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ == nil ) {
		scrollTouch_ = touch;
	} else {
		return NO;
	}
    
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
	startSwipe_ = touchPoint.x;
	state_ = kCCScrollLayerStateIdle;
    _lastPosition = self.position;
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch ) {
		return;
	}
    
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    
	// If finger is dragged for more distance then minimum - start sliding and cancel pressed buttons.
	// Of course only if we not already in sliding mode
	if ( (state_ != kCCScrollLayerStateSliding)
		&& (fabsf(touchPoint.x-startSwipe_) >= self.minimumTouchLengthToSlide) )
	{
		state_ = kCCScrollLayerStateSliding;
        
		// Avoid jerk after state change.
		startSwipe_ = touchPoint.x;
        _lastPosition = self.position;
		if (self.stealTouches)
        {
			[self claimTouch: touch];
        }
        
		if ([self.delegate respondsToSelector:@selector(scrollLayerScrollingStarted:)])
		{
			[self.delegate scrollLayerScrollingStarted: self];
		}
	}
    if (state_ == kCCScrollLayerStateSliding) {
		self.position = ccp(_lastPosition.x + (touchPoint.x - startSwipe_), self.position.y);
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch )
		return;
	scrollTouch_ = nil;
	int selectedPage = [self pageNumberAtOrigin:self.position];
    
	[self moveToPage:selectedPage];
}

#endif
@end