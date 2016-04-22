//
//  CSMNodeSprite.m
//  Cassam2
//
//  Created by The Cowans on 04/07/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMNodeSprite.h"
#import "CSMLevelBuildScene.h"
#import "CSMGamePlayScene.h"
#import "CSMAstroidSprite.h"


@implementation CSMNodeSprite

-(id)initWithNumber:(int)num scene:(CSMTemplateScene *)scene
{
    
    if([self init]){
        [self setScene:scene];
        self.number = num;
    }
    NSLog(@"new node num: %i", self.number);
    return self;
    
}

-(id)init{
    if([super initWithImageNamed:@"iconNode.png"])
    {
        self.name = @"node";
    }
    return self;
}

-(void)providePhysicsBodyToScale:(CGFloat)scale{
    for(CSMSpriteNode* sprite in [self children])
        [sprite providePhysicsBodyToScale:scale];
}

-(void)providePhysicsBodyAndActions
{
    
    self.physicsBody = NULL;
    [self prepareActions];
    for(CSMSpriteNode* sprite in [self children])
        [sprite providePhysicsBodyAndActions];

}

-(void)prepareActions
{
    
    SKAction *rotate = [SKAction rotateByAngle:self.angularVelocity*M_PI*2 duration:1];
    SKAction *repeat   = [SKAction repeatActionForever:rotate];
    [self runAction:repeat];
    
}

-(void)hide{
    self.texture = [SKTexture textureWithImageNamed:@"transparent.png"];
}

-(SKNode*)getHighlight{
    
    NSLog(@"highlightNode");
    
    SKNode* highlight = [SKShapeNode node];
    
    for(int i=0; i<10; i++){
        //NSLog(@"adding circle");
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, self.position.x, self.position.y, i*120, 0, 2*M_PI, YES);
        SKShapeNode* circle = [SKShapeNode node];
        circle.path = CGPathCreateCopyByStrokingPath(path,
                                                     NULL,
                                                     1,
                                                     kCGLineCapRound,
                                                     kCGLineJoinMiter,
                                                     1);
        circle.strokeColor = [SKColor magentaColor];
        circle.name = @"circle";
        //circle.userInteractionEnabled = NO;
        [highlight addChild:circle];
    }
    
    return highlight;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //pick up children
    for(CSMSpriteNode* node in self.parentScene.spriteHolder.children){
        if([node isKindOfClass:[CSMSpriteNode class]]){
        if(node.parentNumber == self.number){
            if([node.name isEqualToString:@"astroid"]){
                //NSLog(@"2");
                CSMAstroidSprite* ast = (CSMAstroidSprite*)node;
                [ast pickupChildren];
            }
            //NSLog(@"3");
            [node removeFromParent];
            node.position = [self convertPoint:node.position fromNode:self.parentScene.spriteHolder];
            [self addChild:node];
        }
        }
        
    }
    
    [super touchesBegan:touches withEvent:event];
    
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //return astroids
    for(CSMSpriteNode* node in self.children){
        if(![node.name isEqualToString: @"circle"]){
            [node removeFromParent];
            node.position = [self convertPoint:node.position toNode:self.parentScene.spriteHolder];
            [self.parentScene.spriteHolder addChild:node];
            if([node.name isEqualToString:@"astroid"]){
                NSLog(@"[ast setdownChildren]");
                CSMAstroidSprite* ast = (CSMAstroidSprite*)node;
                [ast setdownChildren];
            }
        }
    }
    
    
    [super touchesEnded:touches withEvent:event];
}


#pragma mark - Coding


static NSString* const kRotationKey = @"r";
static NSString* const kAngularVelocityKey = @"a";
static NSString* const kPositionKey = @"p";
static NSString* const kChildrenKey = @"c";
static NSString* const kNumberKey = @"n";

-(NSString*)getcsv{
    NSMutableString* csvString =  [NSMutableString stringWithFormat:@"%i,%f,%f,%f,%f,%i;", kCSMNodeSprite, self.position.x, self.position.y, self.zRotation, self.angularVelocity, self.number];
    for(CSMSpriteNode* sprite in [self children]){
        if([[sprite class]isSubclassOfClass:[CSMSpriteNode class]]){
            sprite.position = CGPointMake(self.position.x + sprite.position.x, self.position.y + sprite.position.y);
            [csvString appendString:[NSString stringWithFormat:@"\n%@",[sprite getcsv]]];
            //NSLog(@"child sprite csv:%@", [sprite getcsv]);
        }
    }
    return csvString;
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:6];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMNodeSprite]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithFloat:self.zRotation]];
    [seedArray addObject:[NSNumber numberWithFloat:self.angularVelocity]];
    [seedArray addObject:[NSNumber numberWithFloat:self.number]];
    
    return seedArray;

}

-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([seedArray count] != 6){
        NSLog(@"Can't init CSMNodeSprite with seedArray:\n%@",seedArray);
    }
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    CGFloat rotation = [[seedArray objectAtIndex:3]floatValue];
    CGFloat angVel = [[seedArray objectAtIndex:4]floatValue];
    int no = [[seedArray objectAtIndex:5]intValue];
    
    self = [super initWithImageNamed:@"iconNode.png"]; //] initWithCoder:aDecoder];
    if(self)
    {
        self.angularVelocity = angVel;
        self.position = CGPointMake(xPos, yPos);
        self.zRotation = rotation;
        self.number = no;
        /*
        NSArray* children = [aDecoder decodeObjectForKey:kChildrenKey];
        for(CSMSpriteNode* sprite in children){
            [self addChild:sprite];
        }
         */
        self.name = @"node";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *rotation = nil, *angularVelocity = nil, *number = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@"," intoString:&rotation];
    [scanner scanUpToString:@"," intoString:&angularVelocity];
    [scanner scanUpToString:@";" intoString:&number];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:6];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMNodeSprite]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[rotation floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[angularVelocity floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[number intValue]]];
    
    [array addObject:seedArray];
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithImageNamed:@"iconNode.png"]; //] initWithCoder:aDecoder];
    if(self)
    {
        self.angularVelocity = [[aDecoder decodeObjectForKey:kAngularVelocityKey] floatValue];
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.zRotation = [[aDecoder decodeObjectForKey:kRotationKey] floatValue];
        self.number = [[aDecoder decodeObjectForKey:kNumberKey] intValue];
        NSArray* children = [aDecoder decodeObjectForKey:kChildrenKey];
        for(CSMSpriteNode* sprite in children){
            [self addChild:sprite];
        }
        self.name = @"node";
        self.zPosition = kDrawing1zPos;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.angularVelocity] forKey:kAngularVelocityKey];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:kPositionKey];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.zRotation] forKey:kRotationKey];
    [aCoder encodeObject:[NSNumber numberWithInt:self.number] forKey:kNumberKey];
    [aCoder encodeObject:[self children] forKey:kChildrenKey];
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
    CSMNodeSprite *copy = [[[self class] allocWithZone:zone] initWithImageNamed:@"iconNode.png"];
    copy.angularVelocity = self.angularVelocity;
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.zRotation = self.zRotation;
    copy.name = self.name;
    copy.number = self.number;
    for(CSMSpriteNode* sprite in [self children]){
        [copy addChild:[sprite copy]];
    }
    return copy;
}

@end
