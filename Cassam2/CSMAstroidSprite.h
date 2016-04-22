//
//  CSMAstroidSprite.h
//  Cassam2
//
//  Created by The Cowans on 15/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameConstants.h"

#import "CSMSpriteNode.h"
@class CSMTemplateScene;
@class CSMNodeSprite;
@class CSMEnemyArtilary;

@interface CSMAstroidSprite : CSMSpriteNode <NSCoding, NSCopying>
@property CGFloat angularVelocity;


//-(id)initWithSize:(CGSize)size scene:(CSMTemplateScene*)scene;
//+(id)astroidWithSize:(CGSize)size scene:(CSMTemplateScene *)scene;
//-(id)initWithSize:(CGSize)size scene:(CSMTemplateScene*)scene parent:(CSMNodeSprite*)node;
//+(id)astroidWithSize:(CGSize)size scene:(CSMTemplateScene *)scene parent:(CSMNodeSprite*)node;

-(id)initWithType:(int)type scene:(CSMTemplateScene*)scene;
+(id)astroidWithType:(int)type scene:(CSMTemplateScene *)scene;


-(void)rotate:(NSTimeInterval)interval;
-(void)providePhysicsBody:(uint32_t)category collisions:(uint32_t)collisionCategories contacts:(uint32_t)contactCategories;
-(void)lineToParent:(CSMNodeSprite*)node;
//-(void)addArtilary:(CSMEnemyArtilary*)art;
@end
