//
//  SpinControlSprite.m
//  Cassam2
//
//  Created by The Cowans on 17/01/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "SpinControlSprite.h"
#import "CSMGamePlayScene.h"

@implementation SpinControlSprite{
#ifdef highlightTouches
    SKSpriteNode* highlight;
#endif
}

-(void)turn:(CFTimeInterval)interval{
    
    CGFloat spinAmount = interval * spinStep;
    
    //check if need to turn at all
    if(self.target == self.zRotation){
        return;
    }
    
    //if target is less than one step different just set zRotation
    if( fabs(self.target - self.zRotation) < (spinAmount) ){
        self.zRotation = self.target;
        //NSLog(@"setting zRotation");
        return;
    }
    
    //decide on clockwise or anticlockwise turn
    CGFloat spinVal;
    CGFloat theta = self.target > self.zRotation ? (self.target - self.zRotation) : (self.zRotation - self.target);
    if(theta < M_PI)
        spinVal = self.target > self.zRotation ? (spinAmount) : (-spinAmount);
    else
        spinVal = self.target < self.zRotation ? (spinAmount) : (-spinAmount);
    
    //move the zRotation one step on
    self.zRotation += spinVal;
    
    //correct zRotation if its over 2PI or less than 0
    if(self.zRotation > (2 * M_PI))
        self.zRotation -= (2 * M_PI);
    if(self.zRotation < 0)
        self.zRotation += (2*M_PI);
    //NSLog(@"zRotation: %f, headgin: %f, adding %f", self.zRotation, target, (spinVal / M_PI));
    
    self.zRotation = self.zRotation;
    //self.zRotation = target;
    //NSLog(@"%f", (self.zRotation / M_PI) );
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
#ifdef highlightTouches
    if(!highlight){
        highlight = [SKSpriteNode spriteNodeWithImageNamed:@"smallHighlight.png"];
    }
#endif
    self.bTouch = YES;
    [self processTouches:touches withEvent:event];

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //isolate touch on control
    //[self.spaceFieldView setMultipleTouchEnabled:YES];
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in [allTouches allObjects]){
        CGPoint p = [touch locationInNode:self];
        if(( ((p.x * p.x) + (p.y * p.y)) <= controlRadius * controlRadius)){
            NSSet *touchSet = [[NSSet alloc]initWithObjects:touch, nil];
            [self processTouches:touchSet withEvent:event];
        }
    }
}


- (void)processTouches:(NSSet *) touches withEvent:(UIEvent *)event{
    

    
    self.target  = 0.0;
    //NSLog(@"%i touches", [touches count]);
    //NSLog(@"count %lui", (unsigned long)[touches count]);
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInNode:self];
    
#ifdef highlightTouches
    highlight.position = p;
    if(![highlight parent]){
        [self addChild:highlight];
    }
#endif
        
    //angle = atan ( opp / adj )
    CGFloat touchAngle = 0.0;
    
    /*
    if(p.y > 0 && p.x > 0){
        touchAngle = (2 * M_PI) - atanf( (p.x) / (p.y));
        //NSLog(@"1");
    }
    else if(p.y == 0){
        touchAngle = p.x > 0 ? (M_PI * 1.5) : (M_PI * 0.5);
        //NSLog(@"2");
    }
    else if(p.y < 0 && p.x > 0){
        touchAngle = M_PI - atanf( p.x / p.y);
        //NSLog(@"3");
    }
    else if(p.y < 0 && p.x < 0){
        touchAngle = M_PI - atanf( (p.x) / (p.y));
        //NSLog(@"4");
    }
    else if(p.y > 0 && p.x < 0){
        touchAngle = - atanf( (p.x) / (p.y));
        //NSLog(@"5");
    }
    */
    
    touchAngle = -atan2f(p.x, p.y);
    
     
    self.target = touchAngle + self.zRotation;
    if(self.target > (2*M_PI))
        self.target -= 2*M_PI;
    //NSLog(@"%f, %f, target=%f*M_PI", p.x, p.y, self.target/M_PI);
     
    
    
    
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.bTouch = NO;
#ifdef highlightTouches
    if([highlight parent]){
        [highlight removeFromParent];
    }
#endif
}

-(void)clearReferences{
#ifdef highlightTouches
    highlight = nil;
#endif
}

@end
