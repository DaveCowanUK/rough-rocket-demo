//
//  CSMRocketSprite.h
//  Cassam2
//
//  Created by The Cowans on 16/07/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMSpriteNode.h"
#import "GameConstants.h"
@class CSMTemplateScene;

@interface CSMRocketSprite : CSMSpriteNode

@property CGFloat thrustControlValue;
//@property (nonatomic) CGPoint speed;
@property (nonatomic) CGFloat direction;
@property BOOL bFire;
@property BOOL bThrustForward;
@property BOOL bThrustBackward;

-(id)initWithScene:(CSMTemplateScene*)scene;
-(void)providePhysicsBodyAndActions;
-(void)showDistress;
-(int)getHealth;
-(void)addtoHealth:(int)i;

@end
