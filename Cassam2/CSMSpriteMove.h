//
//  CSMSpriteMove.h
//  Cassam2
//
//  Created by The Cowans on 05/11/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface CSMSpriteMove : NSObject

@property BOOL complete;
@property SKNode* nde;

-(id)initFrom:(CGPoint)startPos to:(CGPoint)endPos duration:(CFTimeInterval)time;
-(id)initNode:(SKNode*)node to:(CGPoint)endPos duration:(CFTimeInterval)time;
-(id)initCircularMoveFrom:(CGPoint)startPos toAngle:(CGFloat)angle around:(CGPoint)centrePos duration:(CFTimeInterval)time;
-(id)initCircularMoveForNode:(SKNode*)node toAngle:(CGFloat)angle around:(CGPoint)centrePos duration:(CFTimeInterval)time;

-(CGPoint)currentPointPos:(NSTimeInterval)currentTime;
-(CGFloat)currentVal:(NSTimeInterval)currentTime;

@end
