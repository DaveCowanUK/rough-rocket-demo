//
//  CSMThumbPlayScene.m
//  Cassam
//
//  Created by The Cowans on 07/02/2015.
//  Copyright (c) 2015 RNC. All rights reserved.
//

#import "CSMThumbPlayScene.h"
#import "CSMRocketSprite.h"
#import "SpinControlSprite.h"

@interface CSMThumbPlayScene ()
@property SKSpriteNode* rightThumb;
@property SKSpriteNode* leftThumb;

@end

@implementation CSMThumbPlayScene{
    NSArray* touchThumbTextures;
    NSArray* thumbTextures;
    SKAction* touchAnimation;
    SKAction* thumbDownAnimation;
    SKAction* thumbUpAnimation;
    
    BOOL bZoomTouch;
}

+(id)sceneWithSize:(CGSize)size level:(CSMLevel *)level gameData:(CSMGameData *)gData{
    CSMThumbPlayScene* scene = [[CSMThumbPlayScene alloc]initWithSize:size level:level gameData:gData];
    return scene;
}

-(id)initWithSize:(CGSize)size level:(CSMLevel *)level gameData:(CSMGameData *)gData{
    if(self = [super initWithSize:size level:level gameData:gData]){
        NSLog(@"[CSMThumbPaly Scene initWithSize...]");
    }
    return self;
}

-(id)initWithSize:(CGSize)size{
    NSLog(@"thumbPlayScene");
    if([super initWithSize:size]){
        [self loadThumbs];
    }
    return self;
}


-(void)loadThumbs{
    
    NSLog(@"loadThumbs");
    bZoomTouch = NO;
    
    thumbTextures = [self getSprites:@"thumbStraightAnimation.png" frames:5];
    thumbDownAnimation = [SKAction animateWithTextures:thumbTextures timePerFrame:0.02];
    thumbUpAnimation = [thumbDownAnimation reversedAction];
    
    
    touchThumbTextures = [self getSprites:@"touchPoint.png" frames:6];
    touchAnimation = [SKAction animateWithTextures:touchThumbTextures timePerFrame:0.02];
    
    
    
    
    self.rightThumb = [SKSpriteNode spriteNodeWithTexture:thumbTextures[0]];
    self.rightThumb.anchorPoint = CGPointMake(0.5, 0.65);
    self.rightThumb.zRotation = M_PI/4;
    self.rightThumb.zPosition = kIcon2zPos;
    self.rightThumb.alpha = 0.3;
    self.rightThumb.userInteractionEnabled = NO;
    
    self.leftThumb = [SKSpriteNode spriteNodeWithTexture:thumbTextures[0]];
    self.leftThumb.anchorPoint = CGPointMake(0.5, 0.65);
    self.leftThumb.zRotation = -M_PI/4;
    self.leftThumb.zPosition = kIcon2zPos;
    self.leftThumb.alpha = 0.3;
    self.leftThumb.userInteractionEnabled = NO;
    
    
    //self.leftThumb.position = self.thrustForwardControl.position;// CGPointMake(-130, 0);
    //self.rightThumb.position = self.spinControl.position; //CGPointMake(130, 0);
    //[self addChild:self.leftThumb];
    //[self addChild:self.rightThumb];
    
    
}

-(void)update:(NSTimeInterval)currentTime{
    
    static BOOL leftTouching = NO;
    static BOOL rightTouching = NO;
    
    
    
    if (self.rocket.bFire){
        self.leftThumb.position = self.fireControl.position;
        if(![self.leftThumb parent]){
            leftTouching = YES;
            [self animateTouch:self.leftThumb];
        }
    }
    else if(self.rocket.bThrustForward){
        self.leftThumb.position = self.thrustForwardControl.position;
        if(![self.leftThumb parent]){
            leftTouching = YES;
            [self animateTouch:self.leftThumb];
        }
    }
    else if([self.leftThumb parent] && leftTouching){
        leftTouching = NO;
        [self animateRelease:self.leftThumb];
    }
    
    if(self.spinControl.bTouch){
        rightTouching = YES;
        //spinControl.target
        self.rightThumb.position = CGPointMake(
                                                self.spinControl.position.x - ( 40 * sinf(self.spinControl.target)),
                                               self.spinControl.position.y + ( 40 * cosf(self.spinControl.target) )
                                               );
        if(![self.rightThumb parent]){
            [self animateTouch:self.rightThumb];
        }
    }
    else{
        if([self.rightThumb parent] && rightTouching){
            rightTouching = NO;
            [self animateRelease:self.rightThumb];
        }
    }
    

    [super update:currentTime];
}

-(void)animateTouch:(SKSpriteNode*)sprite{
    if(![sprite parent]){
        [self addChild:sprite];
    }
    SKAction* touch = [SKAction fadeInWithDuration:0.2];
    
    
    SKSpriteNode* touchSprite = [SKSpriteNode spriteNodeWithTexture:touchThumbTextures[0]];
    //[sprite addChild:touchSprite];
    touchSprite.alpha = 0.7;
    
    [sprite runAction:[SKAction sequence:@[
                                           [SKAction group:@[touch, thumbDownAnimation]],
                                           [SKAction runBlock:^{
        [sprite addChild:touchSprite];
        [touchSprite runAction:touchAnimation];
    }]
                                           ]]];
    
    
}

-(void)animateRelease:(SKSpriteNode*)sprite{
    
    SKAction* release = [SKAction fadeAlphaTo:0.0 duration:0.1];
    SKAction* remove = [SKAction runBlock:^{[sprite removeFromParent];}];
    
    
    
    [sprite runAction:[SKAction sequence:@[
                       [SKAction group:@[release, thumbUpAnimation]],
                       [SKAction waitForDuration:0.1],
                       remove]]
     ];
     
    [sprite removeAllChildren];
}

-(void)showTouches:(NSSet*)touches newTouches:(BOOL)new{
    
    CGPoint positions[2];
    int i =0;
    
    for(UITouch * touch in [touches allObjects]){
        positions[i] = [touch locationInNode:self];
        i++;
    }
    
    self.leftThumb.position  = positions[0].x < positions[1].x ? positions[0] : positions[1] ;
    self.rightThumb.position = positions[0].x > positions[1].x ? positions[0] : positions[1] ;
    
    if(new){
        
        [self animateTouch:self.leftThumb];
        [self animateTouch:self.rightThumb];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    NSSet *allTouches = [event allTouches];
    
    if([allTouches count] == 2){
        [self showTouches:allTouches newTouches:YES];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    NSSet *allTouches = [event allTouches];
    
    //check for pinch
    if([allTouches count] == 2){
        [self showTouches:allTouches newTouches:NO];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    [self animateRelease:self.leftThumb];
    [self animateRelease:self.rightThumb];
}


@end
