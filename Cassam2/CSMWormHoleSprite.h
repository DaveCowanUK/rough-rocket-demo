//
//  CSMWormHoleSprite.h
//  Cassam2
//
//  Created by The Cowans on 07/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameConstants.h"
#import "CSMSpriteNode.h"
@class CSMTemplateScene;

@interface CSMWormHoleSprite : CSMSpriteNode

-(id)initWithSettings:(struct CSMWormHoleSettings)settings scene:(CSMTemplateScene*)scene;
-(struct CSMWormHoleSettings)getSettings;
@end
