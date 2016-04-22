//
//  CSMTemplateScene.h
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//




#import "CSMResponsiveSKScene.h"
@class CSMRocketSprite;

@class ButtonSprite;

@interface CSMTemplateScene : CSMResponsiveSKScene

@property (nonatomic) CSMRocketSprite *rocket;
@property (nonatomic) CGRect boundary;
@property (nonatomic) SKNode *spriteHolder;
@property (nonatomic) SKNode *gameNode;
@property (nonatomic) ButtonSprite *backControl;
@property CGFloat minScale;

-(void)openMenu;
-(void)spriteTouched:(SKSpriteNode*)sprite;
-(void)addBackground:(SKNode*)node Size:(CGSize)size;

-(SKSpriteNode*)mark:(CGPoint)location;

@end
