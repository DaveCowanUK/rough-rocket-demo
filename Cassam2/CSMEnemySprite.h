//
//  CSMEnemySprite.h
//  Cassam2
//
//  Created by The Cowans on 19/02/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "CSMSpriteNode.h"
#import "GameConstants.h"
@class CSMTemplateScene;

@interface CSMEnemySprite : CSMSpriteNode <NSCoding, NSCopying>

@property BOOL bFeelerBlocked;
@property CGFloat rocketDirection;

-(id)initWithScene:(CSMTemplateScene*)scene;
//-(id)initWithTexture:(SKTexture*)texture scene:(CSMTemplateScene*)scene;


-(void)setCourse;
-(void)doPhysics:(NSTimeInterval)interval;
-(void)attemptFire;
-(void)providePhysicsBodyOnly;
//-(struct CSMEnemySettings)getSettings;
@end
