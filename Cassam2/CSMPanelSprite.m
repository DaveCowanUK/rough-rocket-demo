//
//  CSMPanelSprite.m
//  Cassam2
//
//  Created by The Cowans on 02/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMPanelSprite.h"

@implementation CSMPanelSprite{
    SKAction* open;
    SKAction* close;
}



-(id)initWithColor:(UIColor *)color number:(int)num size:(CGSize)size open:(CGVector)openVect{
    if([super init]){
        self.size = size;
        SKSpriteNode* panel = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:size];
        panel.position = CGPointMake(size.width/2, size.height/2);
        panel.alpha = 0.75;
        [self addChild:panel];
        _inUse = NO;
        self.userInteractionEnabled = YES;
        //self.alpha = 0.3;
        open = [SKAction moveBy:openVect duration:0.2];
        close = [SKAction moveBy:CGVectorMake(-openVect.dx, -openVect.dy) duration:0.2];
        
        if(num > 0){
            SKSpriteNode* tab = [SKSpriteNode spriteNodeWithColor:color size:CGSizeMake(20, size.height/5)];
            tab.anchorPoint = CGPointMake(1, 0);
            tab.position = CGPointMake(0, size.height-((tab.size.height) * num));
            tab.alpha=0.7;
            [self addChild:tab];
        }
    }
    
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //[self open];
}

-(void)close{
    if(self.inUse){
        //[self runAction: [SKAction moveByX:(68) y:0 duration:0.3]];
        [self runAction:close];
    }
    self.inUse = NO;
}

-(void)open{
    if(!self.inUse){
        //[self runAction: [SKAction moveByX:(-68) y:0 duration:0.3]];
        [self runAction:open];
        self.inUse = YES;
    }
}


@end
