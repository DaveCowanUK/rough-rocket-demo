//
//  CSMEnemySpawnPoint.h
//  Cassam2
//
//  Created by The Cowans on 16/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "GameConstants.h"
@class CSMTemplateScene;

@interface CSMEnemySpawnPoint : CSMSpriteNode
@property CGFloat spawnRate;
-(id)initWithSettings:(struct CSMEnemySpawnPointSettings)settings scene:(CSMTemplateScene*)scene;
-(struct CSMEnemySpawnPointSettings)getSettings;
-(void)spawn;
@end
