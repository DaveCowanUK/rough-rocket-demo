//
//  CSMFeeler.m
//  Cassam2
//
//  Created by The Cowans on 07/11/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMFeeler.h"
#import "CSMEnemySprite.h"
#import "GameConstants.h"

@implementation CSMFeeler{
    CSMEnemySprite* delegate;
}

-(id)initWithColor:(UIColor *)color size:(CGSize)size delegate:(CSMEnemySprite *)del position:(CGPoint)pos{
    if(self = [super initWithColor:color size:size]){
        delegate = del;
        self.position = pos;
        self.name = @"feeler";
    }
    return self;
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:scale * ( ((self.size.width + self.size.height) / 4))];
    self.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    
    self.physicsBody.categoryBitMask = categoryBullet;
    self.physicsBody.contactTestBitMask = bulletContacts;
    self.physicsBody.collisionBitMask = 0;
}
/*
-(void)contactWith:(CSMSpriteNode *)sprite{
    if([sprite.name isEqualToString:@"rocket"])
        return;
    [delegate ]
    
}
 */



@end
