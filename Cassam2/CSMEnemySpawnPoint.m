//
//  CSMEnemySpawnPoint.m
//  Cassam2
//
//  Created by The Cowans on 16/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMSpriteNode.h"
#import "CSMEnemySpawnPoint.h"
#import "CSMGamePlayScene.h"
#import "CSMRocketSprite.h"
#import "Tools.h"
#import "GameConstants.h"
#import "CSMNodeSprite.h"

@implementation CSMEnemySpawnPoint{
    CSMTemplateScene* tScene;
}

-(id)initWithSettings:(struct CSMEnemySpawnPointSettings)settings scene:(CSMTemplateScene *)scene{
    if([super initWithImageNamed:@"enemySpawnPoint.png"]){
        tScene = scene;
        self.name = @"enemyspawnpoint";
        self.position = settings.position;
        self.spawnRate = settings.spawnRate;
        NSLog(@"enemySpawnPoint with spawnRate %f", self.spawnRate);
        [self setScene:scene];
    }
    return self;
}

-(CSMEnemySpawnPointSettings)getSettings{
    CSMEnemySpawnPointSettings settings;
    settings.position = self.position;
    settings.spawnRate = self.spawnRate;
    return settings;
}

-(NSValue*)getValue{
    CSMEnemySpawnPointSettings settings = [self getSettings];
    return [NSValue valueWithBytes:&settings objCType:@encode(CSMEnemySpawnPointSettings)];
}

-(void)providePhysicsBodyAndActions{
    //no physics body
    
    //actions
    SKAction *wait = [SKAction waitForDuration:self.spawnRate];
    SKAction *performSelector = [SKAction performSelector:@selector(spawn) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
    SKAction *repeat   = [SKAction repeatActionForever:sequence];
    [self runAction:repeat];
}
/*
-(int)getType{
    return kEnemySpawnPoint;
}
 */


-(void)spawn{
    CSMGamePlayScene* ss = (CSMGamePlayScene*)self.parentScene;
    
    if([[self parent] isKindOfClass:[CSMNodeSprite class]]){
        CGPoint scenePosition = [self.parentScene.spriteHolder convertPoint:self.position fromNode:[self parent]];
        CGFloat distanceToRocket = [Tools getDistanceBetween:scenePosition and:ss.rocket.position];
        if(distanceToRocket < 900)
            [ss addEnemy:scenePosition];
    }
    else{
        CGFloat distanceToRocket = [Tools getDistanceBetween:self.position and:ss.rocket.position];
        if(distanceToRocket < 900)
            [ss addEnemy:self.position];
    }
}

#pragma mark - Coding

static NSString* const kSpawnRateKey = @"s";
static NSString* const kPositionKey = @"p";
static NSString* const kNodeNumberKey = @"n";

-(NSString*)getcsv{
    return [NSString stringWithFormat:@"%i,%f,%f,%f,%i;", kCSMEnemySpawnPoint, self.position.x, self.position.y, self.spawnRate, self.parentNumber];
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [NSMutableArray arrayWithCapacity:5];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemySpawnPoint]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithFloat:self.spawnRate]];
    [seedArray addObject:[NSNumber numberWithFloat:self.parentNumber]];
    
    return  seedArray;
}

-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([seedArray count] != 5){
        NSLog(@"Can't init CSMEnemySpawnPoint with seedArray:\n%@",seedArray);
    }
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    CGFloat spRate = [[seedArray objectAtIndex:3]floatValue];
    int parentNo = [[seedArray objectAtIndex:4] intValue];
    
    
    self = [super initWithImageNamed:@"enemySpawnPoint.png" ];// initWithCoder:aDecoder];
    if(self)
    {
        self.spawnRate = spRate;
        self.position = CGPointMake(xPos, yPos);
        self.name = @"enemyspawnpoint";
        self.parentNumber = parentNo;
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *spawnRate = nil, *parentNumber = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@"," intoString:&spawnRate];
    [scanner scanUpToString:@";" intoString:&parentNumber];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:5];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemySpawnPoint]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[spawnRate floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[parentNumber intValue]]];
    
    [array addObject:seedArray];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithImageNamed:@"enemySpawnPoint.png" ];// initWithCoder:aDecoder];
    if(self)
    {
        self.spawnRate = [[aDecoder decodeObjectForKey:kSpawnRateKey] floatValue];
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.name = @"enemyspawnpoint";
        self.parentNumber = [[aDecoder decodeObjectForKey:kNodeNumberKey]intValue];
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:kPositionKey];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.spawnRate] forKey:kSpawnRateKey];
    if(self.parentNumber != 0)
        [aCoder encodeObject:[NSNumber numberWithInt:self.parentNumber] forKey:kNodeNumberKey];
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
    CSMEnemySpawnPoint *copy = [[[self class] allocWithZone:zone] initWithImageNamed:@"enemySpawnPoint.png"];
    copy.spawnRate = self.spawnRate;
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.parentNumber = self.parentNumber;
    copy.zPosition = self.zPosition;
    copy.name = self.name;
    return copy;
}

-(void)removeReferences{
    [super removeReferences];
    tScene = nil;
}

@end

