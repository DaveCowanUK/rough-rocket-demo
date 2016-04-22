//
//  CSMGamePlayScene.h
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMTemplateScene.h"
@class SpinControlSprite;
@class CSMLevelsLibrary;
@class CSMLevel;
@class CSMRocketSprite;
@class CSMGameData;
@class CSMHealthIndicator;


@interface CSMGamePlayScene : CSMTemplateScene 

//@property (nonatomic) CSMRocketSprite *rocket;
@property (nonatomic) SpinControlSprite *spinControl;
@property (nonatomic) SKAction *fuelBurnAnimation;
@property (nonatomic) NSArray *rocketBurnTextures; 
@property (nonatomic) SKSpriteNode *thrustForwardControl;
////@property (nonatomic) SKSpriteNode *thrustBackwardControl;
@property (nonatomic) SKSpriteNode *fireControl;
@property (nonatomic) NSArray *rocketBurnSprites;
@property (nonatomic) SKTexture *enemyTexture;
//@property (nonatomic) CGRect boundary;
@property (nonatomic) SKLabelNode* hud;
//@property (nonatomic) SKNode *spriteHolder;
@property (nonatomic) GameState gameState;
@property CSMLevel* currentLevel;
@property CSMGameData* gameData;

@property (nonatomic) NSTimeInterval lastUpdateTime;
@property (nonatomic) SKAction* sThrustSoundAction;
@property (nonatomic) SKAction* sFireSoundAction;
@property (nonatomic) SKAction* sExplosionAction;
@property (nonatomic) SKAction* sExplosionSmallAction;
@property (nonatomic) CSMHealthIndicator* healthIndicator;
@property BOOL bLargeScreen;



+(id)sceneWithSize:(CGSize)size library:(CSMLevelsLibrary*)library level:(CSMLevel*)level; //old
+(id)sceneWithSize:(CGSize)size level:(CSMLevel*)level gameData:(CSMGameData*)gData; //new

-(id)initWithSize:(CGSize)size;
-(id)initWithSize:(CGSize)size library:(CSMLevelsLibrary*)library level:(CSMLevel*)level;
-(id)initWithSize:(CGSize)size level:(CSMLevel *)level gameData:(CSMGameData*)gData;
-(void)backgroundOnly;
-(void)prepareSceneForLoading;
-(void)loadControls;
-(void)loadLevel;
-(void)placeRocket:(CGPoint)location;
-(void)rescaleScene:(CGFloat)scale;
-(void)addBullet:(CGPoint)position direction:(CGFloat)rotation;
-(void)addEnemy:(CGPoint)location;
-(void)addEnemy:(CGPoint)location impulse:(CGVector)impulse;
-(void)addEnemyScud:(CGPoint)position velocity:(CGVector)vel direction:(CGFloat)rotation;
-(NSArray*)getSprites:(NSString*)fileName frames:(int)frames;
-(void)explosion:(CGPoint)location;
-(void)animateThrust:(BOOL)forward;
-(void)stopThrustAnimation:(BOOL)forward;

@end
