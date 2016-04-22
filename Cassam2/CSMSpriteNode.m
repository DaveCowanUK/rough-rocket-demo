//
//  CSMSpriteNode.m
//  Cassam2
//
//  Created by The Cowans on 01/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMSpriteNode.h"
#import "CSMTemplateScene.h"
#import "CSMLevelBuildScene.h"

@implementation CSMSpriteNode{
    CGPoint touch1;
    NSTimeInterval touchStarted;
    BOOL bLabels;
}


-(id)initWithImageNamed:(NSString *)name scene:(CSMTemplateScene *)scene{
    if([super initWithImageNamed:name]){
        _parentScene = scene;
    }
    return self;
}

-(id)initWithSeedArray:(NSArray *)seedArray{
    NSLog(@"initWithSeedArray not overiden. Seed:%@", seedArray);
    return nil;
}

-(void)setScene:(CSMTemplateScene*)scene{
    self.parentScene = scene;
    for(CSMSpriteNode* sprite in [self children])
        if([sprite respondsToSelector:@selector(setScene:)]){
            [sprite setScene:scene];
        }
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    NSLog(@"[CSMSpriteNode providePhysicsBodyToScale] not overriden in %@", self);
}

-(void)providePhysicsBodyAndActions{
    //for children
    for(CSMSpriteNode* sprite in [self children]){
        if(![sprite.name isEqualToString:@"label"])
        [sprite providePhysicsBodyAndActions];
    }
}

-(void)setDampingAndFriction{
    self.physicsBody.friction = kFriction;
    self.physicsBody.linearDamping = kLinearDamping;
    self.physicsBody.angularDamping = kAngularDamping;
}

-(SKNode*)getHighlight{
    CGFloat spriteMargin = 20.0;
    
    SKShapeNode* highlight = [SKShapeNode node];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, self.position.x, self.position.y, spriteMargin + self.size.width/2, 0, 2*M_PI, YES);
    
    highlight.path = CGPathCreateCopyByStrokingPath(path,
                                                  NULL,
                                                  1,
                                                  kCGLineCapButt,
                                                  kCGLineJoinMiter,
                                                  1);
    
    highlight.strokeColor = [SKColor magentaColor];
    highlight.name = @"highlight";
    highlight.glowWidth = 4;
    //highlight.alpha = 0.5;
    //highlight.zPosition = -1;
    
    return highlight;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self.parentScene isMemberOfClass:[CSMLevelBuildScene class]] == YES){
        CSMLevelBuildScene* lbs = (CSMLevelBuildScene*)self.parentScene;
        
        if([lbs editMode]){
            
            CGPoint touch2 = [[touches anyObject] locationInNode:_parentScene.spriteHolder];
            self.position = CGPointMake(
                                        self.position.x + touch2.x - self.position.x,
                                        self.position.y + touch2.y - self.position.y
                                        );
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    touch1 = [[touches anyObject] locationInNode:_parentScene.spriteHolder];
    touchStarted = [NSDate timeIntervalSinceReferenceDate];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSTimeInterval touchEnded = [NSDate timeIntervalSinceReferenceDate];
    if( (touchEnded - touchStarted) < 0.4)
        [_parentScene spriteTouched:self];
}

-(CGFloat)convertRotationFrom:(SKNode *)nodeA toNode:(SKNode *)nodeB{
    return 0.0;
}

-(void)pickupChildren{
    if(self.number != 0){
        for(CSMSpriteNode* node in self.parentScene.spriteHolder.children){
            if([node isKindOfClass:[CSMSpriteNode class]]){
                if(node.parentNumber == self.number){
                    [node pickupChildren];
                    [node removeFromParent];
                    node.position = [self convertPoint:node.position fromNode:self.parentScene.spriteHolder];
                    [self addChild:node];
                }
            }
        }
    }
}

-(void)setdownChildren{
    //NSLog(@"[CSMSpriteNode setdownChildren]");
    for(CSMSpriteNode* node in self.children){
        if([node isKindOfClass:[CSMSpriteNode class]]){
            [node removeFromParent];
            node.position = [self convertPoint:node.position toNode:self.parentScene.spriteHolder];
            [self.parentScene.spriteHolder addChild:node];
            [node setScene:self.parentScene];
            [node setdownChildren];
            node.zPosition = kDrawing1zPos;
        }
    }
}

-(NSString*)getcsv{
    return @"";
}

-(NSArray*)seedArray{
    NSLog(@"[CSMSpriteNode seedArray] not overriden in %@", self);
    return  nil;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    NSLog(@"getSeecValues not overriden");
}

-(void)removeReferences{
    self.parentScene = nil;
    [self removeAllActions];
    for (SKNode* node in [self children]) {
        if([node isKindOfClass:[CSMSpriteNode class]]){
            [(CSMSpriteNode*)node removeReferences];
        }
    }
    [self removeAllChildren];
}

/*
 -(NSValue*)getValue{
 return NULL;
 }
 
 -(int)getType{
 return 0;
 }
 
 -(CSMSpriteSeed*)getSeed{
 return NULL;
 }
 */

@end
