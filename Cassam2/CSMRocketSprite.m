//
//  CSMRocketSprite.m
//  Cassam2
//
//  Created by The Cowans on 16/07/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMRocketSprite.h"
#import "CSMTemplateScene.h"
#import "CSMGamePlayScene.h"

@implementation CSMRocketSprite{
    CGPoint speed;
    SKTexture* distressTexture;
    SKAction* distressAnimation;
    int health;
}


-(id)initWithScene:(CSMTemplateScene *)scene{
    if([super initWithImageNamed:@"rocket2.0.png"]){
        [self setScene:scene];
        health = rocketFullHealth;
        self.name = @"rocket";
        self.zPosition = kDrawing1zPos;
    }

    return self;
}

-(int)getHealth{
    return health;
}

-(void)addtoHealth:(int)i{
    if( !( (health + i) > rocketFullHealth ) ){
        health += i;
    }
}

-(struct CSMRocketSettings)getSettings{
    struct CSMRocketSettings settings;
    settings.position = self.position;
    settings.rotation = self.zRotation;
    return settings;
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:scale * ( ((self.size.width + self.size.height) / 4))];
    
    self.physicsBody.friction = kFriction;
    self.physicsBody.linearDamping = kLinearDamping;
    self.physicsBody.angularDamping = kAngularDamping;
    
    self.physicsBody.categoryBitMask = categoryRocket;
    self.physicsBody.contactTestBitMask = rocketContacts;
    self.physicsBody.collisionBitMask = rocketCollisions;
}

-(void)providePhysicsBodyAndActions{
    [self providePhysicsBodyToScale:1.0];
    
    NSArray* distressTextures;
    if([self.parentScene isKindOfClass:[CSMGamePlayScene class]]){
        CSMGamePlayScene* scene = (CSMGamePlayScene*)self.parentScene;
        distressTextures = [scene getSprites:@"rocketDistress.png" frames:3];
        /*
        distressAnimation = [SKAction sequence:@[
                                                 [SKAction animateWithTextures:distressTextures timePerFrame:animationFrameLength/2.0],
                                                 [SKAction removeFromParent]
                                                 ]];
         */
        distressAnimation = [SKAction animateWithTextures:distressTextures timePerFrame:animationFrameLength/2.0];

         

    }
    
    
}

-(void)showDistress{
    SKSpriteNode* die = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(66, 66)];
    [self addChild:die];
    [die runAction:distressAnimation completion:^{
        [die removeFromParent];
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.parentScene spriteTouched:self];
}



@end
