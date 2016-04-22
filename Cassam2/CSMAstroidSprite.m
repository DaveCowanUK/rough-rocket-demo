//
//  CSMAstroidSprite.m
//  Cassam2
//
//  Created by The Cowans on 15/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMAstroidSprite.h"
#import "CSMTemplateScene.h"
#import "CSMNodeSprite.h"
#import "CSMEnemyArtilary.h"
#import "Tools.h"


@implementation CSMAstroidSprite{
    //CSMTemplateScene* tScene;
    CGPoint touch1;
    int astroidType;
}


-(id)initWithType:(int)type scene:(CSMTemplateScene *)scene{
    NSString *imageName;
    astroidType = type;
    switch (astroidType) {
        case 2:
            imageName = @"astroid2.png";
            break;
        case 3:
            imageName = @"astroid3.png";
            break;
         default:
            imageName = @"astroid2.png";
            //NSLog(@"undefined astroid type '%i' in [CSMAstroid initWithType:scene:]", type);
            break;
    }
    if([super initWithTexture:[SKTexture textureWithImageNamed:imageName]]){
        [self setScene:scene];
        self.parentNumber = 0;
    }
    return self;
}

+(id)astroidWithType:(int)type scene:(CSMTemplateScene *)scene{
    return [[CSMAstroidSprite alloc]initWithType:type scene:scene];
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: scale * ( ((self.size.width + self.size.height) / 4))];
    [self setDampingAndFriction];
    
    self.physicsBody.categoryBitMask = categoryAstroid;
    self.physicsBody.contactTestBitMask = astroidContacts;
    self.physicsBody.collisionBitMask = astroidCollisions;
    
    for(CSMSpriteNode* sprite in [self children])
        [sprite providePhysicsBodyToScale:scale];
}

-(void)providePhysicsBodyAndActions{
    [self providePhysicsBodyToScale:1.0];
}

-(void)pickupChildren{
    //NSLog(@"[CSMAstroid pickupChildren]");
    [super pickupChildren];
    
    //set home for enemyArtilary children
    for(CSMSpriteNode* node in self.children){
        if([node isKindOfClass:[CSMEnemyArtilary class]]){
            CSMEnemyArtilary* ea = (CSMEnemyArtilary*)node;
            ea.homeRotation = [Tools getAngleFrom:CGPointMake(0.0, 0.0)
                                               to:ea.position
                               ];
            ea.zRotation = ea.homeRotation;
           // NSLog(@"homeRotation:%f", ea.homeRotation/M_PI);
            
        }
    }
}

-(void)lineToParent:(CSMNodeSprite *)node{
    NSLog(@"addLineToParent");
    SKShapeNode* line = [SKShapeNode node];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPoint parentPosition = [self.parentScene.spriteHolder convertPoint:node.position toNode:self];
    CGPathAddLineToPoint(path, NULL, parentPosition.x, parentPosition.y);
    
    line.path = CGPathCreateCopyByStrokingPath(path,
                                                    NULL,
                                                    1,
                                                    kCGLineCapButt,
                                                    kCGLineJoinMiter,
                                                    1);
    
    line.strokeColor = [SKColor magentaColor];
    line.name = @"link";
    line.glowWidth = 0;
    //highlight.alpha = 0.5;
    //highlight.zPosition = -1;
    [self addChild:line];
}


-(void)providePhysicsBody:(uint32_t)category collisions:(uint32_t)collisionCategories contacts:(uint32_t)contactCategories{
    
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = category;
    self.physicsBody.collisionBitMask = collisionCategories;
    self.physicsBody.contactTestBitMask = contactCategories;
    self.physicsBody.dynamic = NO;

    //add physics bodies to circles
    for(SKSpriteNode* sprite in [self children]){
        if([sprite.name isEqualToString:@"circleAstroid"]){
            sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
            sprite.physicsBody.categoryBitMask = category;
            sprite.physicsBody.collisionBitMask = collisionCategories;
            sprite.physicsBody.contactTestBitMask = contactCategories;
            sprite.physicsBody.dynamic = NO;
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //pick up enemyartilary children
    //NSLog(@"[super pickupChildren]");
    [super pickupChildren];
    
    [super touchesBegan:touches withEvent:event];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //return astroids
    
    [super setdownChildren];
    [super touchesEnded:touches withEvent:event];
}



-(void)rotate:(NSTimeInterval)interval{
    //NSLog(@"astroid position:%f, %f", self.position.x, self.position.y);
    self.zRotation = self.zRotation + self.angularVelocity * interval;
    /*
    for(CSMEnemyArtilary* artilary in [self children]){
        [artilary doPhysics];
    }
     */
}

/*
-(void)addArtilary:(CSMEnemyArtilary *)art{
    
    NSLog(@"\n\n[CSMAstroidSprite addArtilary] now redundant\n\n");
 
    art.position = [self convertPoint:art.position fromNode:self.parentScene.spriteHolder];
    [self addChild:art];
    [art setHome];
 
}
*/

/*
-(void)pickupChildren{
    
    for(CSMSpriteNode* node in self.parentScene.spriteHolder.children){
      //  NSLog(@"chlidren: %ui; self.number:%i", [self.parentScene.sp])
        CSMEnemyArtilary* ea = (CSMEnemyArtilary*)node;
        if(ea.astroidNumber == self.number){
            [ea removeFromParent];
            ea.position = [self convertPoint:ea.position fromNode:self.parentScene.spriteHolder];
            [self addChild:ea];
            
        }
    }
}

-(void)setdownChildren{
    for(CSMSpriteNode* node in self.children){
        CSMEnemyArtilary* ea = (CSMEnemyArtilary*)node;
        [ea removeFromParent];
        ea.position = [self convertPoint:ea.position toNode:self.parentScene.spriteHolder];
        [self.parentScene.spriteHolder addChild:ea];
        
    }
}
 */


#pragma mark - Coding


static NSString* const kRotationKey = @"r";
static NSString* const kAngularVelocityKey = @"a";
static NSString* const kPositionKey = @"p";
static NSString* const kParentNumberKey = @"n";
static NSString* const kTypeKey = @"t";
static NSString* const kNumberKey = @"x";
static NSString* const kChildrenKey = @"c";

-(NSString*)getcsv{
    NSMutableString* csvString =  [NSMutableString stringWithFormat:@"%i,%f,%f,%f,%f,%i,%i,%i;", kCSMAsroidSprite, self.position.x, self.position.y, self.zRotation, self.angularVelocity, self.parentNumber, self.number, astroidType];
    
    for(CSMSpriteNode* sprite in [self children]){
        if([[sprite class]isSubclassOfClass:[CSMSpriteNode class]]){
            sprite.position = CGPointMake(self.position.x + sprite.position.x, self.position.y + sprite.position.y);
            [csvString appendString:[NSString stringWithFormat:@"\n%@",[sprite getcsv]]];
           // NSLog(@"child sprite csv:%@", [sprite getcsv]);
        }
    }
    return csvString;
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [NSMutableArray arrayWithCapacity:8];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMAsroidSprite]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithFloat:self.zRotation]];
    [seedArray addObject:[NSNumber numberWithFloat:self.angularVelocity]];
    [seedArray addObject:[NSNumber numberWithFloat:self.parentNumber]];
    [seedArray addObject:[NSNumber numberWithFloat:self.number]];
    [seedArray addObject:[NSNumber numberWithFloat:astroidType]];
    
    return seedArray;
}

-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([seedArray count] != 8){
        NSLog(@"Can't init CSMAstroidSprite with seedArray:\n%@",seedArray);
    }
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    CGFloat rotation = [[seedArray objectAtIndex:3]floatValue];
    CGFloat angVel = [[seedArray objectAtIndex:4]floatValue];
    int parentNo = [[seedArray objectAtIndex:5] intValue];
    int no = [[seedArray objectAtIndex:6]intValue];
    int type = [[seedArray objectAtIndex:7]intValue];
    
    
    self = [CSMAstroidSprite astroidWithType:type scene:NULL]; //] initWithCoder:aDecoder];
    if(self)
    {
        self.angularVelocity = angVel;
        self.position = CGPointMake(xPos, yPos);
        self.zRotation = rotation;
        self.parentNumber = parentNo;
        self.number = no;
        astroidType = type;
        self.name = @"astroid";
        self.zPosition = kDrawing1zPos;
        /*
        NSArray* children = [aDecoder decodeObjectForKey:kChildrenKey];
        for(CSMSpriteNode* sprite in children){
            [self addChild:sprite];
        }
         */
        
    }
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *rotation = nil, *angularVelocity = nil, *parentNumber = nil, *number = nil, *type = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@"," intoString:&rotation];
    [scanner scanUpToString:@"," intoString:&angularVelocity];
    [scanner scanUpToString:@"," intoString:&parentNumber];
    [scanner scanUpToString:@"," intoString:&number];
    [scanner scanUpToString:@";" intoString:&type];
    
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:8];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMAsroidSprite]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[rotation floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[angularVelocity floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[parentNumber intValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[number intValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[type intValue]]];
    
    [array addObject:seedArray];
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    int type = [[aDecoder decodeObjectForKey:kTypeKey] intValue];
    self = [CSMAstroidSprite astroidWithType:type scene:NULL]; //] initWithCoder:aDecoder];
    if(self)
    {
        self.angularVelocity = [[aDecoder decodeObjectForKey:kAngularVelocityKey] floatValue];
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.zRotation = [[aDecoder decodeObjectForKey:kRotationKey] floatValue];
        self.parentNumber = [[aDecoder decodeObjectForKey:kParentNumberKey] intValue];
        self.number = [[aDecoder decodeObjectForKey:kNumberKey] intValue];
        astroidType = type;
        self.name = @"astroid";
        self.zPosition = kDrawing1zPos;
        
        NSArray* children = [aDecoder decodeObjectForKey:kChildrenKey];
        for(CSMSpriteNode* sprite in children){
            [self addChild:sprite];
        }
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.angularVelocity] forKey:kAngularVelocityKey];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:kPositionKey];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.zRotation] forKey:kRotationKey];
    [aCoder encodeObject:[NSNumber numberWithInt:self.parentNumber] forKey:kParentNumberKey];
    [aCoder encodeObject:[NSNumber numberWithInt:self.number] forKey:kNumberKey];
    [aCoder encodeObject:[NSNumber numberWithInt:astroidType] forKey:kTypeKey];
    [aCoder encodeObject:[self children] forKey:kChildrenKey];
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
    CSMAstroidSprite *copy = [[[self class] allocWithZone:zone] initWithType:astroidType scene:self.parentScene];
    copy.angularVelocity = self.angularVelocity;
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.zRotation = self.zRotation;
    copy.name = self.name;
    copy.parentNumber = self.parentNumber;
    copy.number = self.number;
    copy.zPosition = self.zPosition;
    
    for(CSMSpriteNode* sprite in [self children]){
        [copy addChild:[sprite copy]];
    }
    
    return copy;
}

@end
