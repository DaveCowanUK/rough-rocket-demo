//
//  CSMResponsiveLabel.h
//  Cassam2
//
//  Created by The Cowans on 10/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class CSMResponsiveSKScene;

@interface CSMResponsiveLabel : SKLabelNode

-(id)initWithScene:(CSMResponsiveSKScene*)scene;
-(id)initWithNumber:(int)i scene:(CSMResponsiveSKScene*)scene;
-(void)clearReferences;

@end
