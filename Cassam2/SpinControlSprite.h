//
//  SpinControlSprite.h
//  Cassam2
//
//  Created by The Cowans on 17/01/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SpinControlSprite : SKSpriteNode
    


//@property CGFloat direction;
@property CGFloat target;
@property BOOL bTouch;
@property BOOL clockwise;


-(void)turn:(CFTimeInterval)interval;
-(void)processTouches:(NSSet *) touches withEvent:(UIEvent *)event;
-(void)clearReferences;
//-(void)spin:(CGPoint)p;
@end


