//
//  SpriteViewController.h
//  Cassam2
//
//  Created by The Cowans on 16/12/2013.
//  Copyright (c) 2013 RNC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
@import AVFoundation;

@interface SpriteViewController : UIViewController <GKGameCenterControllerDelegate, AVAudioPlayerDelegate>

@property (nonatomic) BOOL gameCenterEnabled;

#ifdef compileWithGameKit
-(void)reportScore:(int)newScore;
-(void)showLeaderboard;
#endif

-(void)switchSceneFrom:(SKScene*)oldScene to:(SKScene*)newScene;
- (void)replaceViewUsing:(SKScene*)newScene;
-(BOOL)toggleSound;
-(BOOL)musicPlaying;
-(void)pauseGame;

@end
