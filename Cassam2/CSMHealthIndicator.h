//
//  CSMHealthIndicator.h
//  Cassam2
//
//  Created by The Cowans on 06/08/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class  CSMGamePlayScene;
@class  CSMTestScene;

@interface CSMHealthIndicator : SKSpriteNode

-(void)reduceHealthTo:(CGFloat)health;
-(BOOL)increaseHealthTo:(CGFloat)health;
-(void)prepareAnimation:(CSMGamePlayScene*)scene;
-(void)prepareAnimationforTest:(CSMTestScene *)scene;
-(void)showDistress;
-(void)clearReferences;

@end
