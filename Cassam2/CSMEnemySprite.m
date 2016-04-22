//
//  CSMEnemySprite.m
//  Cassam2
//
//  Created by The Cowans on 19/02/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMEnemySprite.h"
#import "CSMTemplateScene.h"
#import "GameConstants.h"
#import "Tools.h"
#import "CSMGamePlayScene.h"
#import "CSMRocketSprite.h"
#import "CSMFeeler.h"

@implementation CSMEnemySprite{
    CGPoint touch1;
}
/*

-(int)getType{
    return kRocket;
}
 */

-(id)init{
    //NSLog(@"[CSMEnemySprite init]");
    if([super initWithImageNamed:@"enemy1.png"])
    {
        self.name = @"enemy";
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

/*
-(id)initWithTexture:(SKTexture *)texture scene:(CSMTemplateScene*)scene{
    if([super initWithTexture:texture]){
        [self setScene:scene];
        if([scene.name isEqualToString:@"gameplayscene"])
            [self prepareActions];
        self.name = @"enemy";
    }
    return  self;
}
 */

/*
-(id)initWithSettings:(struct CSMEnemySettings)settings scene:(CSMTemplateScene *)scene{
    if([super initWithImageNamed:@"enemy1.png"]){
        [self setScene:scene];
        if([scene.name isEqualToString:@"gameplayscene"]){
            [self prepareActions];
            self.userInteractionEnabled = NO;
        }
        else if([scene.name isEqualToString:@"levelbuildscene"]){
            self.userInteractionEnabled = YES;
        }
        self.name = @"enemy";
        self.position = settings.position;
        self.zRotation = settings.rotation;
        [self setScene:scene];
    }
    return self;
}
 */

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:scale * ( ((self.size.width + self.size.height) / 4))];
    [self setDampingAndFriction];
    
    self.physicsBody.categoryBitMask = categoryEnemy;
    self.physicsBody.contactTestBitMask = enemyContacts;
    self.physicsBody.collisionBitMask = enemyCollisions;
}

-(void)providePhysicsBodyAndActions{
    
    [self providePhysicsBodyToScale:1.0];
    [self prepareActions];
    
}

-(void)providePhysicsBodyOnly{
    [self providePhysicsBodyToScale:1.0];
}



-(void)prepareActions{
    //NSLog(@"[CSMEmenySprite prepareActions]");
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
    //find rocket
    self.rocketDirection = [Tools getAngleFrom:self.position to:self.parentScene.rocket.position];
    
}

-(void)setScene:(CSMTemplateScene *)scene{
    [super setScene:scene];
}

-(void)doPhysics:(NSTimeInterval)interval{
    //turn toward rocket
    self.zRotation = [Tools turnToward:self.rocketDirection from:self.zRotation step:spinStep*interval];
    
    //accelerate
    /*
    [self.physicsBody applyForce:CGVectorMake(
                                               interval * kEnemyAcceleration * self.parentScene.spriteHolder.xScale * -sinf(self.zRotation),
                                               interval * kEnemyAcceleration * self.parentScene.spriteHolder.yScale * cosf(self.zRotation)
                                              )];
     */
    [self.physicsBody applyForce:CGVectorMake(
                                              0.017 * kEnemyAcceleration * self.parentScene.spriteHolder.xScale * -sinf(self.zRotation),
                                              0.017 * kEnemyAcceleration * self.parentScene.spriteHolder.yScale * cosf(self.zRotation)
                                              )];
    /*
    static int i = 0;
    static CFTimeInterval totalUpdate = 0.0;
    totalUpdate += interval;
    i++;
    if(i % 100 == 0){
        //NSLog(@"average fps: %f", 1/(totalUpdate/i));
        NSLog(@"average interval: %f", totalUpdate/i);
    }
     */
    
}

-(void)attemptFire{
    CGFloat distanceToRocket = [Tools getDistanceBetween:self.position and:self.parentScene.rocket.position];
    if (distanceToRocket < 300){
        
        CSMGamePlayScene* gps = (CSMGamePlayScene*)self.parentScene;
        [gps addEnemyScud:self.position velocity:self.physicsBody.velocity direction:self.rocketDirection];
        
        /*
        //place feeler
        CSMFeeler* feeler = [[CSMFeeler alloc]initWithColor:[SKColor clearColor]
                                                       size:CGSizeMake(14, 14)
                                                   delegate:self
                                                   position:CGPointMake(
                                                                        self.position.x + (kbulletPojection * -sinf(rocketDirection)),
                                                                        self.position.y + (kbulletPojection * cosf(rocketDirection))
                                                                        )
                             ];
        
        CSMGamePlayScene* gps = (CSMGamePlayScene*)self.parentScene;
        [gps.spriteHolder addChild:feeler];
         */
    }
}

-(void)fire{

    if(!self.bFeelerBlocked){
        CSMGamePlayScene* gps = (CSMGamePlayScene*)self.parentScene;
        [gps addEnemyScud:self.position velocity:self.physicsBody.velocity direction:self.rocketDirection];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"enemy touched");
    [self.parentScene spriteTouched:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint touch2 = [[touches anyObject] locationInNode:self.parentScene.spriteHolder];
    self.position = CGPointMake(
                                self.position.x + touch2.x - self.position.x,
                                self.position.y + touch2.y - self.position.y
                                );
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    touch1 = [[touches anyObject] locationInNode:self.parentScene.spriteHolder];
}

#pragma mark - Coding

static NSString* const kRotationKey = @"p";
static NSString* const kPositionKey = @"r";

-(NSString*)getcsv{
    return [NSString stringWithFormat:@"%i,%f,%f,%f;", kCSMEnemySprite, self.position.x, self.position.y, self.zRotation];
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:4];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemySprite]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithFloat:self.zRotation]];
    
    return seedArray;
}

-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([seedArray count] != 4){
        NSLog(@"Can't init CSMEnemySprite with seedArray:\n%@",seedArray);
    }
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    CGFloat rotation = [[seedArray objectAtIndex:3]floatValue];

    
    self = [super initWithImageNamed:@"enemy1.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = CGPointMake(xPos, yPos);
        self.zRotation = rotation;
        self.name = @"enemy";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *rotation = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@";" intoString:&rotation];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:4];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMEnemySprite]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[rotation floatValue]]];
    
    [array addObject:seedArray];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithImageNamed:@"enemy1.png"];// initWithCoder:aDecoder];
    if(self)
    {
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.zRotation = [[aDecoder decodeObjectForKey:kRotationKey] floatValue];
        self.name = @"enemy";
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
    CSMEnemySprite *copy = [[[self class] allocWithZone:zone] initWithImageNamed:@"enemy1.png"];
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.zRotation = self.zRotation;
    copy.name = @"enemy";
    copy.zPosition = self.zPosition;
    return copy;
}


@end
