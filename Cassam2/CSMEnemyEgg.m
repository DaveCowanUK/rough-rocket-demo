//
//  CSMEnemyEgg.m
//  Cassam2
//
//  Created by The Cowans on 23/08/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMEnemyEgg.h"
#import "GameConstants.h"
#import "CSMGamePlayScene.h"
#import "CSMNodeSprite.h"

@implementation CSMEnemyEgg{
    int life;
    SKTexture* distressTexture;
    SKAction* distressAnimation;
}

-(id)init{
    //NSLog(@"[CSMEnemySprite init]");
    if([super initWithImageNamed:@"enemyegg.png"])
    {
        self.name = @"enemyegg";
        
    }
    return self;
}

-(id)initWithScene:(CSMTemplateScene *)scene
{
    //NSLog(@"[CSMEnemySprite initWithScene]");
    if([self init])
        [self setScene:scene];
    // if([scene.name isEqualToString:@"gameplayscene"])
    //     [self prepareActions];
    return self;
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: scale * ( ((self.size.width + self.size.height) / 4))];
    [self setDampingAndFriction];
    
    self.physicsBody.categoryBitMask = categoryEnemyEgg;
    self.physicsBody.contactTestBitMask = enemyEggContacts;
    self.physicsBody.collisionBitMask = enemyEggCollisions;
}

-(void)providePhysicsBodyAndActions{
    life = kEnemyEggLife;
    
    [self providePhysicsBodyToScale:1.0];
    
    NSArray* distressTextures;
    if([self.parentScene isKindOfClass:[CSMGamePlayScene class]]){
        CSMGamePlayScene* scene = (CSMGamePlayScene*)self.parentScene;
        distressTextures = [scene getSprites:@"enemyeggdistress.png" frames:3];
        /*
        distressAnimation = [SKAction sequence:@[
                                                 [SKAction animateWithTextures:distressTextures timePerFrame:animationFrameLength/2.0],
                                                 [SKAction removeFromParent]
                                                 ]];
         */
        distressAnimation = [SKAction animateWithTextures:distressTextures timePerFrame:animationFrameLength/2.0];
    }
    
    //[self prepareActions];
    
}

-(void)hit{
    
    CSMGamePlayScene* gps = (CSMGamePlayScene*)self.parentScene;
    
    
    life--;
    if(life < 1){
        CGPoint selfPosition = [[self parent] isKindOfClass:[CSMNodeSprite class]] ?
            [self.parentScene.spriteHolder convertPoint:self.position fromNode:[self parent]] :
            self.position ;
        [gps explosion:self.position];
        CGFloat enemyDirection = 0.0;
        for(int i=0; i<5; i++){
            [gps addEnemy:selfPosition impulse:CGVectorMake(
                                                             kEnemyAcceleration / 15 * self.parentScene.spriteHolder.xScale * -sinf(enemyDirection),
                                                             kEnemyAcceleration / 15 * self.parentScene.spriteHolder.yScale * cosf(enemyDirection)
                                                             )];
            enemyDirection += 2 * M_PI/5;
        }
        
            [self removeFromParent];
        
    }
    else{
        //show distress
        SKSpriteNode* die = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(66, 66)];
        [self addChild:die];
        [die runAction:distressAnimation completion:^{
            [die removeFromParent];
        }];
    }
    
}

#pragma mark - Coding

static NSString* const kRotationKey = @"p";
static NSString* const kPositionKey = @"r";

-(NSString*)getcsv{
    return [NSString stringWithFormat:@"%i,%f,%f,%f, %i;", kCSMEnemyEgg, self.position.x, self.position.y, self.zRotation, self.parentNumber];
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:5];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemyEgg]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithFloat:self.zRotation]];
    [seedArray addObject:[NSNumber numberWithInt:self.parentNumber]];
    
    
    return seedArray;
}

-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([seedArray count] != 5){
        NSLog(@"Can't init CSMEnemyEgg with seedArray:\n%@",seedArray);
    }
    
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    CGFloat rotation = [[seedArray objectAtIndex:3]floatValue];
    int pNum = [[seedArray objectAtIndex:4]intValue];
    /*
    if([seedArray count] == 5)
        pNum = [[seedArray objectAtIndex:4]intValue];
     */
    
    self = [super initWithImageNamed:@"enemyegg.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = CGPointMake(xPos, yPos);
        self.zRotation = rotation;
        self.name = @"enemyegg";
        self.zPosition = kDrawing1zPos;
        self.parentNumber = pNum;
    }
    
    
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *rotation = nil, *pNum = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@"," intoString:&rotation];
    [scanner scanUpToString:@";" intoString:&pNum];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:5];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemyEgg]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[rotation floatValue]]];
    [seedArray addObject:[NSNumber numberWithInt:[pNum intValue]]];
    
    //NSLog(@"[CSMEnemyEgg getSeedValues] with pNum %@ - %@", pNum, [seedArray objectAtIndex:4]);
    
    [array addObject:seedArray];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithImageNamed:@"enemyegg.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.zRotation = [[aDecoder decodeObjectForKey:kRotationKey] floatValue];
        self.name = @"enemyegg";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:kPositionKey];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.zRotation] forKey:kRotationKey];
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
    CSMEnemyEgg *copy = [[[self class] allocWithZone:zone] initWithImageNamed:@"enemyegg.png"];
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.zRotation = self.zRotation;
    copy.name = @"enemyegg";
    copy.zPosition = self.zPosition;
    copy.parentNumber = self.parentNumber;
    return copy;
}

@end
