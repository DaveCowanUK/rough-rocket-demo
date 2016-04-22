//
//  ButtonSprite.m
//  Cassam2
//
//  Created by The Cowans on 27/01/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "ButtonSprite.h"
//#import "SpacefieldScene.h"

@implementation ButtonSprite{
    CSMResponsiveSKScene* parentScene;
    ButtonType type;
#ifdef highlightTouches
    SKSpriteNode* highlight;
#endif
}

-(id)initWithTexture:(SKTexture *)texture scene:(CSMResponsiveSKScene *)scene type:(ButtonType)use{
    if([super initWithTexture:texture]){
        parentScene = scene;
        type = use;
#ifdef highlightTouches
        if(use == kFire || use == kThrustForward){
        highlight = [SKSpriteNode spriteNodeWithImageNamed:@"controlBacklight.png"];
        highlight.zPosition = -1;
        }
#endif
    }
    self.userInteractionEnabled = YES;
    return  self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"BUTTON TOUCH");
    
    [parentScene buttonTouched:type];
#ifdef highlightTouches
    if(type == kFire || type == kThrustForward){
    [self addChild:highlight];
    }
#endif
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [parentScene buttonReleased:type];
#ifdef highlightTouches
    if(type == kFire || type == kThrustForward){
    [highlight removeFromParent];
    }
#endif
}

-(void)clearReferences{
    parentScene = nil;
#ifdef highlightTouches
    highlight = nil;
#endif
}

@end
