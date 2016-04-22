//
//  CSMGameData.h
//  Cassam2
//
//  Created by The Cowans on 07/10/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>

@class CSMLevel;
@class SpriteViewController;

@interface CSMGameData : NSObject

@property SpriteViewController * vc;
@property BOOL demoWatched;
@property NSString *pngExtension;


+(CSMGameData*)gameData;

-(void)openDemoLevelFromScene:(SKScene*)scene;
-(void)openGamePlayLevel:(int)levelNo fromScene:(SKScene*)scene;
-(void)openBuildLevel:(int)levelNo fromScene:(SKScene*)scene;
-(void)openMenuFromScene:(SKScene*)scene;

-(void)saveLevel:(CSMLevel*)level;
-(void)addLevel:(CSMLevel*)level;
//-(void)insertLevel:(CSMLevel*)level;
-(void)deleteLevel:(int)levelNo;
-(NSUInteger)numberOfLevels;


-(CSMLevel*)getDemoLevel;


-(void)completedlevel:(int)levelNo withScore:(int)score;
-(int)scoreForLevel:(int)levelNo;
-(int)totalScore;
-(BOOL)gameComplete;

-(BOOL)gameCenterEnabled;
-(void)showLeaderboard;

-(BOOL)toggleSound;
-(BOOL)musicPlaying;

-(void)pauseGame;

-(SKTexture*)getTextureNamed:(NSString*)imageName;
@end
