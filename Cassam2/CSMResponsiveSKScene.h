//
//  CSMResponsiveSKScene.h
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameConstants.h"
#import "CSMSpriteNode.h"

@interface CSMResponsiveSKScene : SKScene



-(void)buttonTouched:(ButtonType)button;
-(void)buttonReleased:(ButtonType)button;
-(void)labelTouched:(NSString*)labelText;
-(void)createSceneContents;
-(void)clearReferences;
@end
