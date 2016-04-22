//
//  CSMFeeler.h
//  Cassam2
//
//  Created by The Cowans on 07/11/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class CSMEnemySprite;
@class CSMSpriteNode;

@interface CSMFeeler : SKSpriteNode

-(id)initWithColor:(UIColor *)color size:(CGSize)size delegate:(CSMEnemySprite*)del position:(CGPoint)pos;
//-(void)contactWith:(CSMSpriteNode*)sprite;

@end
