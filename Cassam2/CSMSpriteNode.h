//
//  CSMSpriteNode.h
//  Cassam2
//
//  Created by The Cowans on 01/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class CSMSpriteSeed;
@class CSMTemplateScene;

@interface CSMSpriteNode : SKSpriteNode

@property CSMTemplateScene* parentScene;
@property int parentNumber;
@property int number;


-(id)initWithImageNamed:(NSString *)name scene:(CSMTemplateScene*)scene;
-(void)setScene:(CSMTemplateScene*)scene;
-(id)initWithSeedArray:(NSArray*)seedArray;
//-(NSValue*)getValue;
//-(int)getType;
//-(CSMSpriteSeed*)getSeed;
-(void)providePhysicsBodyAndActions;
-(void)providePhysicsBodyToScale:(CGFloat)scale;
-(void)setDampingAndFriction;
-(SKNode*)getHighlight;
-(CGFloat)convertRotationFrom:(SKNode*)nodeA toNode:(SKNode*)nodeB;

-(void)pickupChildren;
-(void)setdownChildren;

-(NSString*)getcsv;
-(NSArray*)seedArray;

+(void)getSeedValues:(NSScanner*)scanner array:(NSMutableArray*)array;

-(void)removeReferences;
@end
