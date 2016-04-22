//
//  CSMHealthIndicator.m
//  Cassam2
//
//  Created by The Cowans on 06/08/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMHealthIndicator.h"
#import "CSMGamePlayScene.h"
#import "CSMTestScene.h"

@interface CSMHealthIndicator()

@end

@implementation CSMHealthIndicator{
    SKSpriteNode* indicator;
    SKAction* distressAnimation;
    NSArray* distressTextures;
    SKTexture* plusTexture;
}

-(id)init{
    self = [super initWithImageNamed:@"healthframe.png"];
    if(self){
        self.anchorPoint = CGPointMake(0.5, 0.5);
        indicator = [[SKSpriteNode alloc]initWithImageNamed:@"healthlevel.png"];
        //indicator.centerRect = CGRectMake(0.0, 0.2, 1.0, 0.6);
        indicator.anchorPoint = CGPointMake(0.5, 0.0);
        indicator.position = CGPointMake(0.0, -self.size.height/2+3);
        plusTexture = [SKTexture textureWithImageNamed:@"iconplus.png"];
        [self addChild:indicator];
    }
    return self;
}

-(void)reduceHealthTo:(CGFloat)health{
    
    if(health < 0)
        return;
    
    //animation
    [self showDistress];
    
    SKAction* scale = [SKAction scaleYTo:health duration:0.2];
    [indicator runAction:scale];
    
}

-(BOOL)increaseHealthTo:(CGFloat)health{
    SKAction* scale = [SKAction scaleYTo:health duration:0.2];
    [indicator runAction:scale];
    if(health < 1.0){
        [self showPlus];
        return YES;
    }
    return NO;
}


-(void)prepareAnimation:(CSMGamePlayScene *)scene{
    distressTextures = [scene getSprites:@"rocketDistress.png" frames:3];
    /*
    distressAnimation = [SKAction sequence:@[
                                             [SKAction animateWithTextures:distressTextures timePerFrame:animationFrameLength/2.0],
                                             [SKAction removeFromParent]
                                             ]];
     */
    distressAnimation = [SKAction animateWithTextures:distressTextures timePerFrame:animationFrameLength/2.0];
    
}

-(void)prepareAnimationforTest:(CSMTestScene*)scene{
    distressTextures = [scene getSprites:@"rocketDistress.png" frames:3];
    
    distressAnimation = [SKAction animateWithTextures:distressTextures timePerFrame:animationFrameLength/2.0];
}


-(void)showDistress{
    SKSpriteNode* die = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(66, 66)];
    [self addChild:die];
    [die runAction:distressAnimation completion:^{
        [die removeFromParent];
    }];
}

-(void)showPlus{
    //NSLog(@"showPlus");
    SKSpriteNode* plus = [SKSpriteNode spriteNodeWithTexture:plusTexture];
    plus.xScale = 0.0;
    plus.yScale = 0.0;
    plus.position = CGPointMake(-7, 45);
    plus.zPosition = 50;
    [self addChild:plus];
    
    SKAction* zoom = [SKAction scaleTo:1.0 duration:0.2];
    SKAction* fade = [SKAction fadeOutWithDuration:0.2];
    SKAction* remove = [SKAction runBlock:^{
        [plus removeFromParent];
    }];
    //SKAction* seq = [SKAction sequence:@[[SKAction group:@[zoom, fade]], remove]];
    SKAction* seq = [SKAction sequence:@[zoom, fade, remove]];
    [plus runAction:seq];
 
}

-(void)clearReferences{
    ;
}


@end
