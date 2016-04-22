//
//  ButtonSprite.h
//  Cassam2
//
//  Created by The Cowans on 27/01/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameConstants.h"
#import "CSMResponsiveSKScene.h"
@class SpacefieldScene;

@interface ButtonSprite : SKSpriteNode

-(id)initWithTexture:(SKTexture*)texture scene:(CSMResponsiveSKScene*)scene type:(ButtonType)use;
-(void)clearReferences;

@end
