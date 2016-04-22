//
//  Tools.h
//  Cassam2
//
//  Created by The Cowans on 28/01/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
//#import <AVFoundation/AVFoundation.h>
#import "GameConstants.h"

@interface Tools : NSObject{
    
}



@property CGSize kFieldSize;
/*
@property CGFloat kRocketAcceleration;
@property CGFloat kFireFrequency;
@property CGFloat kMissileLaunchImpulse;
@property CGFloat kFriction;
@property CGFloat kLinearDamping;
@property CGFloat kAngularDamping;
@property CGFloat kbulletPojection;
 */

+(void)addTilesWithTexture:(SKTexture*)texture to:(SKNode*)node area:(CGRect)rect zPos:(CGFloat)zPos;
+(CGFloat)getAngleFrom:(CGPoint)pointA to:(CGPoint)pointB;
+(CGFloat)turnToward:(CGFloat)targetAngle from:(CGFloat)currentAngle step:(CGFloat)spinAmount;
+(CGFloat)getDistanceBetween:(CGPoint)pointA and:(CGPoint)pointB;
+(CGPoint)getMidPoint:(CGPoint)pointA and:(CGPoint)pointB;


+(struct CSMEnemySettings)CSMEnemySettingsMake:(CGPoint)position WithRot:(CGFloat)rotation;

+(struct CSMEnemySpawnPointSettings)CSMEnemySpawnPointSettingsMake:(CGPoint)position WithRot:(CGFloat)spawnRate;

+(struct CSMAstroidSettings)CSMAstroidSettingsMake:(CGRect)rect WithRotation:(CGFloat)rotation WithSpin:(CGFloat)spinRate;

+(struct CSMRocketSettings)CSMRocketSettingsMake:(CGPoint)position WithRot:(CGFloat)rotation;

+(struct CSMWormHoleSettings)CSMWormHoleSettingsMake:(CGPoint)position;



@end


