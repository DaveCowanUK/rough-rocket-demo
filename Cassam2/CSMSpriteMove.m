//
//  CSMSpriteMove.m
//  Cassam2
//
//  Created by The Cowans on 05/11/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMSpriteMove.h"
#import "Tools.h"

@implementation CSMSpriteMove{
    CGPoint startPt;
    CGPoint endPt;
    CGPoint centrePt;
    CGFloat startVal;
    CGFloat endVal;
    CGFloat startAngle;
    CGFloat endAngle;
    CGFloat radius;
    CFTimeInterval duration, startTime;
    
    BOOL circularMove;
}

-(id)initFrom:(CGPoint)startPos to:(CGPoint)endPos duration:(CFTimeInterval)time{
    if(self = [super init]){
        startPt = startPos;
        endPt = endPos;
        duration = time;
        startTime = 0.0;
        self.complete = NO;
        circularMove = NO;
    }
    return self;
}

-(id)initCircularMoveFrom:(CGPoint)startPos toAngle:(CGFloat)angle around:(CGPoint)centrePos duration:(CFTimeInterval)time{
    if(self = [super init]){
        centrePt = centrePos;
        duration = time;
        startTime = 0.0;
        self.complete = NO;
        circularMove = YES;
        
        startAngle = [Tools getAngleFrom:centrePos to:startPos];
        endAngle = angle;
        radius = [Tools getDistanceBetween:startPos and:centrePos];
    }
    return self;
}

-(id)initCircularMoveForNode:(SKNode*)node toAngle:(CGFloat)angle around:(CGPoint)centrePos duration:(CFTimeInterval)time{
    if(self = [super init]){
        self.nde = node;
        centrePt = centrePos;
        duration = time;
        startTime = 0.0;
        self.complete = NO;
        circularMove = YES;
        
        startAngle = [Tools getAngleFrom:centrePos to:node.position];
        endAngle = angle;
        radius = [Tools getDistanceBetween:node.position and:centrePos];
    }
    return self;
}

/*
-(id)initFromVal:(CGFloat)startNo to:(CGFloat)endNo duration:(CFTimeInterval)time{
    if(self = [super init]){
        startVal = startNo;
        endVal = endNo;
        duration = time;
        startTime = 0.0;
        self.complete = NO;
    }
    return self;
}
 */

-(id)initNode:(SKNode *)node to:(CGPoint)endPos duration:(CFTimeInterval)time{
    if(self = [super init]){
        self.nde = node;
        endPt = endPos;
        duration = time;
        startTime = 0.0;
        self.complete = NO;
    }
    return self;
}

-(CGPoint)currentPointPos:(NSTimeInterval)currentTime{
    if(startTime == 0.0){
        startTime = currentTime;
        startPt = self.nde.position;
    }
    
    //CGFloat elapsedTime = currentTime - startTime;
    CGFloat timeProgress = (currentTime - startTime) /  duration;
    
    if(timeProgress > 1.0){
        self.complete = YES;
        return endPt;
    }
    
    
    CGFloat dPos = 0.0;
    dPos = (timeProgress * timeProgress) / ( (timeProgress * timeProgress) + ( (1-timeProgress) * (1-timeProgress)) );
    CGPoint currentPos;
    
    if(circularMove){
        
        CGFloat currentAngle = startAngle + ((endAngle - startAngle) * dPos);
        currentPos = CGPointMake(
                                 centrePt.x + sinf(currentAngle) * radius,
                                 centrePt.y + cosf(currentAngle) * radius
                                 );
    }
    
    else{
        currentPos = CGPointMake(
                                 startPt.x + ((endPt.x - startPt.x) * dPos),
                                 startPt.y + ((endPt.y - startPt.y) * dPos)
                                 );
    }
    
    return currentPos;
    
}

-(CGFloat)currentVal:(NSTimeInterval)currentTime{
    if(startTime == 0.0){
        startTime = currentTime;
    }
    
    CGFloat timeProgress = (currentTime - startTime) /  duration;
    
    if(timeProgress > 1.0){
        self.complete = YES;
        return endVal;
    }
    
    return  (timeProgress * timeProgress) / ( (timeProgress * timeProgress) + ( (1-timeProgress) * (1-timeProgress)) );
}



@end

/*
 percentComplete: (0.0 to 1.0).
 elaspedTime: The number of milliseconds the animation has been running
 startValue: the value to start at (or the value when the percent complete is 0%)
 endValue: the value to end at (or the value when the percent complete is 100%)
 totalDuration: The total desired length of the animation in milliseconds
 
 function (x, t, b, c, d) {
 if ((t/=d/2) < 1) return c/2*t*t + b;
 return -c/2 * ((--t)*(t-2) - 1) + b;
 */
