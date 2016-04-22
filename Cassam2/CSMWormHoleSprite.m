//
//  CSMWormHoleSprite.m
//  Cassam2
//
//  Created by The Cowans on 07/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMWormHoleSprite.h"

@implementation CSMWormHoleSprite

-(id)initWithSettings:(struct CSMWormHoleSettings)settings scene:(CSMTemplateScene *)scene{
    if([super initWithImageNamed:@"WormHole.png"]){
        self.name = @"wormhole";
        self.position = settings.position;
        [self setScene:scene];
    }
    return self;
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: scale * ( ((self.size.width + self.size.height) / 4))];
    //[self setDampingAndFriction];
    
    self.physicsBody.categoryBitMask = categoryWormhole;
    self.physicsBody.contactTestBitMask = wormholeContacts;
    self.physicsBody.collisionBitMask = wormholeCollisions;
    self.physicsBody.dynamic = NO;
}

-(void)providePhysicsBodyAndActions{
    
    [self providePhysicsBodyToScale:1.0];
    SKAction *rotate = [SKAction rotateByAngle:M_PI/2 duration:1];
    SKAction *repeat   = [SKAction repeatActionForever:rotate];
    [self runAction:repeat];
}


-(CSMWormHoleSettings)getSettings{
    CSMWormHoleSettings settings;
    settings.position = self.position;
    return settings;
}

-(NSValue*)getValue{
    CSMWormHoleSettings settings = [self getSettings];
    return [NSValue valueWithBytes:&settings objCType:@encode(CSMWormHoleSettings)];
}
/*
-(int)getType{
    return kWormhole;
}
*/
#pragma mark - Coding

static NSString* const kPositionKey = @"r";

-(NSString*)getcsv{
    return [NSString stringWithFormat:@"%i,%f,%f, %i;", kCSMWormHoleSprite, self.position.x, self.position.y, self.parentNumber];
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:4];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMWormHoleSprite]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithInt:self.parentNumber]];
    
    return seedArray;
}

-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([seedArray count] != 4){
        NSLog(@"Can't init CSMWormHoleSprite with seedArray:\n%@",seedArray);
    }
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    int pNum = [[seedArray objectAtIndex:3]intValue];
    
    self = [super initWithImageNamed:@"WormHole.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = CGPointMake(xPos, yPos);
        self.parentNumber = pNum;
        self.name = @"wormhole";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *pNum = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@";" intoString:&pNum];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:3];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMWormHoleSprite]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithInt:[pNum intValue]]];
    
    [array addObject:seedArray];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithImageNamed:@"WormHole.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.name = @"wormhole";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:kPositionKey];
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
    CSMWormHoleSprite *copy = [[[self class] allocWithZone:zone] initWithImageNamed:@"WormHole.png"];
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.zPosition = self.zPosition;
    copy.parentNumber = self.parentNumber;
    copy.name = self.name;
    return copy;
}

@end
