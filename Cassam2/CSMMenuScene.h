//
//  CSMMenuScene.h
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>
#import "CSMTemplateScene.h"

@class CSMGameData;
@class  ButtonSprite;


typedef enum{
    CSMOriginalLevelsPos = 0,
    CSMUserLevelsPos,
    CSMLoadedLevelsPos
} CSMMenuPos;


@interface CSMMenuScene : CSMTemplateScene

@property (nonatomic) ButtonSprite *buildControl;
@property (nonatomic) ButtonSprite *addLevelControl;
@property (nonatomic) ButtonSprite *settingsControl;
@property (nonatomic) UIViewController *viewController;

//-(id)initWithSize:(CGSize)size pos:(CSMMenuPos)pos;
-(id)initWithSize:(CGSize)size gameData:gData levels:(BOOL)startAtLevels;
+(CSMMenuScene*)sceneWithSize:(CGSize)size gameData:(CSMGameData*)gData;
+(CSMMenuScene*)sceneWithSize:(CGSize)size viewController:(UIViewController*)vc;
+(CSMMenuScene*)sceneWithSize:(CGSize)size gameData:(CSMGameData*)gData levels:(BOOL)startAtLevels;

-(void)showGameCenterControl;
-(void)scrollFrom:(CGPoint)p1 to:(CGPoint)p2;

@end
