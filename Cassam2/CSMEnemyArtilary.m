//
//  CSMEnemyArtilary.m
//  Cassam2
//
//  Created by The Cowans on 13/08/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMEnemyArtilary.h"
#import "CSMEnemySprite.h"
#import "CSMTemplateScene.h"
#import "GameConstants.h"
#import "Tools.h"
#import "CSMGamePlayScene.h"
#import "CSMRocketSprite.h"

@implementation CSMEnemyArtilary{
    CGFloat rocketDirection;
    BOOL bFire;
    //SKShapeNode* selfLocation;
    //SKShapeNode* rocketLocation;
}


/*
 
 -(int)getType{
 return kRocket;
 }
 */

-(id)init{
    if([super initWithImageNamed:@"enemyartilary.png"])
    {
        self.name = @"enemyartilary";
    }
    return self;
}

-(id)initWithScene:(CSMTemplateScene *)scene
{
    if([self init])
        [self setScene:scene];
    // if([scene.name isEqualToString:@"gameplayscene"])
    //     [self prepareActions];
    return self;
}

-(id)initWithScene:(CSMTemplateScene *)scene rotation:(CGFloat)rotation{
    
    if([self initWithScene:scene]){
        self.homeRotation = rotation;
        self.zRotation = rotation;
    }
    return self;
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: scale * ( ((self.size.width + self.size.height) / 4))];
    self.physicsBody.dynamic = NO;
    
    self.physicsBody.categoryBitMask = categoryEnemyArtilary;
    self.physicsBody.contactTestBitMask = enemyArtilaryContacts;
    self.physicsBody.collisionBitMask = enemyArtilaryCollisions;
}

-(void)providePhysicsBodyAndActions{
    
    [self providePhysicsBodyToScale:1.0];
    [self prepareActions];
    
}

-(void)prepareActions{
    //NSLog(@"[CSMEmenySpriteArtilary prepareActions]");
    //apply actions to call setCoure and attemptFire methods
    SKAction *randomWait = [SKAction waitForDuration:((float)rand() / RAND_MAX)];
    SKAction *wait = [SKAction waitForDuration:0.5];
    SKAction *performSetCourseSelector = [SKAction performSelector:@selector(setCourse) onTarget:self];
    SKAction *performAttemptFireSelector = [SKAction performSelector:@selector(attemptFire) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, performSetCourseSelector, wait, performSetCourseSelector, performAttemptFireSelector]];
    SKAction *repeat   = [SKAction repeatActionForever:sequence];
    [self runAction:[SKAction sequence:@[randomWait, repeat]]];
    
}

-(void)setCourse{
    
    //find rocket direction relative to self
    static CGFloat previousRotation;
    previousRotation = self.zRotation;
    self.zRotation = 0.0;
    rocketDirection = [Tools getAngleFrom:CGPointMake(0.0, 0.0)
                                       to:[self convertPoint:self.parentScene.rocket.position fromNode:self.parentScene.spriteHolder]
                       ];
    
   // NSLog(@"rocketDirection: %f", rocketDirection/M_PI);
    

    
    //self.zRotation = rocketDirection;
    
    CGFloat theta = rocketDirection > self.homeRotation ? (rocketDirection - self.homeRotation) : (self.homeRotation - rocketDirection) ;
    if( (theta < M_PI/2) || (theta > M_PI * 1.5) ){
        self.zRotation = rocketDirection;
       // self.zRotation = [Tools turnToward:rocketDirection from:self.zRotation step:spinStep/60.0];
        bFire = YES;
        
    }
    else{
        bFire = NO;
        //self.zRotation = previousRotation;
        self.zRotation = self.homeRotation;
    }
    
    
}

-(void)setScene:(CSMTemplateScene *)scene{
    [super setScene:scene];
    
}

-(void)doPhysics:(NSTimeInterval)interval{
    [self setCourse];
    //NSLog(@"[CSMEnemyArtilary doPhysics]");
    //if(bFire)
       // self.zRotation = [Tools turnToward:rocketDirection from:self.zRotation step:spinStep*interval];
    //else
        //self.zRotation = [Tools turnToward:self.homeRotation from:self.zRotation step:spinStep*interval];
    
    
    /*
     NSLog(@"artilary position:%f, %f", [self convertPoint:self.position toNode:self.parentScene.spriteHolder].x,
     [self convertPoint:self.position toNode:self.parentScene.spriteHolder].y);
     rocketDirection = [Tools getAngleFrom:[self convertPoint:self.position toNode:self.parentScene.spriteHolder] to:self.parentScene.rocket.position];
     
     */
}

-(void)attemptFire{
    CGFloat distanceToRocket = [Tools getDistanceBetween:
                                [self.parent convertPoint:self.position toNode:self.parentScene.spriteHolder]
                                                     and:self.parentScene.rocket.position];
    if ( (distanceToRocket < 700) && bFire ){
        CSMGamePlayScene* gps = (CSMGamePlayScene*)self.parentScene;
        CGFloat scudCourse = [Tools getAngleFrom:[self.parent convertPoint:self.position toNode:self.parentScene.spriteHolder]
                                              to:self.parentScene.rocket.position
                              ];
        [gps addEnemyScud:[self.parent convertPoint:self.position toNode:self.parentScene.spriteHolder]
                 velocity:self.physicsBody.velocity direction:scudCourse];
    }
}



#pragma mark - Coding

static NSString* const kPositionKey = @"r";
static NSString* const kParentNumberKey = @"p";

-(NSString*)getcsv{
    return [NSString stringWithFormat:@"%i,%f,%f,%i;", kCSMEnemyArtilary, self.position.x, self.position.y, self.parentNumber];
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:4];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemyArtilary]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithFloat:self.parentNumber]];
    
    return seedArray;
}

-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([seedArray count] != 4){
        NSLog(@"Can't init CSMEnemyArtilary with seedArray:\n%@",seedArray);
    }
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    CGFloat parentNo = [[seedArray objectAtIndex:3]intValue];
    
    self = [super initWithImageNamed:@"enemyartilary.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = CGPointMake(xPos, yPos);
        self.parentNumber = parentNo;
        self.name = @"enemyartilary";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *parentNumber = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@";" intoString:&parentNumber];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:4];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemyArtilary]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[parentNumber intValue]]];
    
    [array addObject:seedArray];
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithImageNamed:@"enemyartilary.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.parentNumber = [[aDecoder decodeObjectForKey:kParentNumberKey] intValue];
        self.name = @"enemyartilary";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:kPositionKey];
    [aCoder encodeObject:[NSNumber numberWithInt:self.parentNumber] forKey:kParentNumberKey];
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
    CSMEnemyArtilary *copy = [[[self class] allocWithZone:zone] initWithImageNamed:@"enemyartilary.png"];
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.parentNumber = self.parentNumber;
    copy.name = @"enemyartilary";
    copy.zPosition = self.zPosition;
    return copy;
}


@end