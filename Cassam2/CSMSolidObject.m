//
//  CSMSolidObject.m
//  Cassam2
//
//  Created by The Cowans on 20/06/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMSolidObject.h"
#import "GameConstants.h"

@implementation CSMSolidObject


-(id)initWithType:(spriteType)type scene:(CSMTemplateScene *)scene
{
    
    NSString *imageName;
    NSString *spriteName;
    
    switch (type)
    {
            
        case kSharpener:
            imageName = @"sharpener.png";
            spriteName = @"sharpener";
            break;
            
        case kPencilRed:
            imageName = @"pencil_red.png";
            spriteName = @"pencil";
            break;
            
        case kPencilBlue:
            imageName = @"pencil_blue.png";
            spriteName = @"pencil";
            break;
            
        case kPencilGreen:
            imageName = @"pencil_green.png";
            spriteName = @"pencil";
            break;
            
        case kPencilBrown:
            imageName = @"pencil_brown.png";
            spriteName = @"pencil";
            break;
            
        case kEraser:
            imageName = @"objecteraser.png";
            spriteName = @"eraser";
            break;
            
        default:
            NSLog(@"trying to initialise unknown CSMSolidObject");
            break;
            
    }
    
    if([super initWithImageNamed:imageName scene:scene]){
        [self addShadow];
        //NSLog(@"201");
        self.name = spriteName;
        self.type = type;
    }
    
  
    
    return self;
    
}

-(void)setScene:(CSMTemplateScene *)scene{
    [super setScene:scene];
}

-(void)addShadow{
    
    //self.zPosition = 2;
    
    SKShapeNode *shadBTM = [SKShapeNode node];
    SKShapeNode *shadRHS = [SKShapeNode node];
    
    CGMutablePathRef pathBTM = CGPathCreateMutable();
    CGPathMoveToPoint(pathBTM, NULL, -self.size.width/2+20, -self.size.height/2+5);
    CGPathAddLineToPoint(pathBTM, NULL, self.size.width/2-10, -self.size.height/2+5);
    shadBTM.path = CGPathCreateCopyByStrokingPath(pathBTM,
                                                  NULL,
                                                  10,
                                                  kCGLineCapRound,
                                                  kCGLineJoinMiter,
                                                  20);
    
    shadBTM.strokeColor = [SKColor grayColor];
    //shadBTM.fillColor = [SKColor grayColor];
    shadBTM.glowWidth = 20;
    shadBTM.alpha = 0.5;
    shadBTM.zPosition = -1;
    [self addChild:shadBTM];
    
    CGMutablePathRef pathRHS = CGPathCreateMutable();
    CGPathMoveToPoint(pathRHS, NULL, self.size.width/2-5, self.size.height/2-20);
    CGPathAddLineToPoint(pathRHS, NULL, self.size.width/2-5, -self.size.height/2+10);
    shadRHS.path = CGPathCreateCopyByStrokingPath(pathRHS,
                                                  NULL,
                                                  10,
                                                  kCGLineCapRound,
                                                  kCGLineJoinMiter,
                                                  20);
    shadRHS.strokeColor = [SKColor grayColor];
    shadRHS.fillColor = [SKColor grayColor];
    shadRHS.glowWidth = 20;
    shadRHS.alpha = 0.5;
    shadRHS.zPosition = -1;
    [self addChild:shadRHS];
    
    

}

-(void)reshadow{
    
    
    if(self.zRotation < 0){
        self.zRotation = 2*M_PI + self.zRotation;
    }
    else if (self.zRotation > (2 * M_PI)){
        self.zRotation = self.zRotation - (2 * M_PI);
    }
    for(SKSpriteNode *shadow in [self children]){
        if([shadow.name isEqualToString:@"bottomshadow" ]){
            shadow.yScale = cosf( self.zRotation  - (M_PI * 0.25));
            NSLog(@"angle: %f", self.zRotation/M_PI);
        }
        else if ([shadow.name isEqualToString:@"rightshadow" ]){
            shadow.xScale = cosf( self.zRotation  + (M_PI * 0.25));
            NSLog(@" and: %f", self.zRotation/M_PI);
        }
    }
    
    
}



-(void)providePhysicsBodyAndActions{
    
    if(
       self.type == kPencilRed ||
       self.type == kPencilBlue ||
       self.type == kPencilGreen ||
       self.type == kPencilBrown
       )
    {
        
        //iOS9 bug
        if(self.size.width == 0.0){
            NSLog(@"texture problem: %@", self);
            self.position = CGPointMake(0.0, 0.0);
            self.zRotation = 0.0;
            return;
        }
        
        
        SKSpriteNode* nodeForPhysicsBod = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                                       size:CGSizeMake(self.size.width - 144.0,
                                                                                       self.size.height / 1.5
                                                                                       )
                                           ];
        nodeForPhysicsBod.position = CGPointMake(72, 0);
        nodeForPhysicsBod.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:nodeForPhysicsBod.size];
        nodeForPhysicsBod.physicsBody.categoryBitMask = categorySolidObject;
        nodeForPhysicsBod.physicsBody.contactTestBitMask = solidObjectContacts;
        nodeForPhysicsBod.physicsBody.collisionBitMask = solidObjectCollisions;
        nodeForPhysicsBod.physicsBody.dynamic = NO;
        [self addChild:nodeForPhysicsBod];
        
    }
    else{
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        
        //[self setDampingAndFriction];
        
        self.physicsBody.categoryBitMask = categorySolidObject;
        self.physicsBody.contactTestBitMask = solidObjectContacts;
        self.physicsBody.collisionBitMask = solidObjectCollisions;
        self.physicsBody.dynamic = NO;
    }
    
}

#pragma mark - Coding

static NSString* const kRotationKey = @"p";
static NSString* const kPositionKey = @"r";
static NSString* const kTypeKey = @"t";

-(NSString*)getcsv{
    return [NSString stringWithFormat:@"%i,%f,%f,%f,%i;", kCSMSolidObject, self.position.x, self.position.y, self.zRotation, self.type];
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [NSMutableArray arrayWithCapacity:5];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMSolidObject]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.position.y]];
    [seedArray addObject:[NSNumber numberWithFloat:self.zRotation]];
    [seedArray addObject:[NSNumber numberWithFloat:self.type]];
    
    return  seedArray;
}

-(id)initWithSeedArray:(NSArray*)seedArray{
    
    if([seedArray count] != 5){
        NSLog(@"Can't init CSMSolidObject with seedArray:\n%@",seedArray);
    }
    
    CGFloat xPos = [[seedArray objectAtIndex:1]floatValue];
    CGFloat yPos = [[seedArray objectAtIndex:2]floatValue];
    CGFloat rotation = [[seedArray objectAtIndex:3]floatValue];
    spriteType newType = [[seedArray objectAtIndex:4] intValue];
    
    self = [self initWithType:newType scene:NULL];
    
    // NSLog(@"solid object initwithcoder tyep:%i", self.type);
    
    if(self)
    {
        self.position = CGPointMake(xPos, yPos);
        self.zRotation = rotation;
        self.zPosition = kSolidObjzPos;
        
        switch (self.type) {
            case kSharpener:
                self.name = @"sharpener";
                break;
            case kPencilRed:
                self.name = @"pencil";
                break;
            case kPencilGreen:
                self.name = @"pencil";
                break;
            case kPencilBlue:
                self.name = @"pencil";
                break;
            case kPencilBrown:
                self.name = @"pencil";
                break;
            case kEraser:
                self.name = @"eraser";
                break;
            default:
                NSLog(@"unrecognised CSMSolidObject type:%i", self.type);
                self.size = CGSizeMake(50, 50);
                self.color = [UIColor redColor];
                self.name =@"unknown";
                break;
        }
        
    }
    return self;
}

+(void)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *positionX = nil, *positionY = nil, *rotation = nil, *type = nil;
    
    [scanner scanUpToString:@"," intoString:&positionX];
    [scanner scanUpToString:@"," intoString:&positionY];
    [scanner scanUpToString:@"," intoString:&rotation];
    [scanner scanUpToString:@";" intoString:&type];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:5];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMSolidObject]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[positionY floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[rotation floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[type intValue]]];
    
    [array addObject:seedArray];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    spriteType newType = [[aDecoder decodeObjectForKey:kTypeKey] intValue];
    self = [self initWithType:newType scene:NULL];
    
    // NSLog(@"solid object initwithcoder tyep:%i", self.type);
    
    if(self)
    {
        self.position = [[aDecoder decodeObjectForKey:kPositionKey] CGPointValue];
        self.zRotation = [[aDecoder decodeObjectForKey:kRotationKey] floatValue];
        self.zPosition = kSolidObjzPos;
        
        switch (self.type) {
            case kSharpener:
                self.name = @"sharpener";
                break;
            case kPencilRed:
                self.name = @"pencil";
                break;
            case kPencilGreen:
                self.name = @"pencil";
                break;
            case kPencilBlue:
                self.name = @"pencil";
                break;
            case kPencilBrown:
                self.name = @"pencil";
                break;
            case kEraser:
                self.name = @"eraser";
                break;
            default:
                NSLog(@"unrecognised CSMSolidObject type:%i", self.type);
                self.size = CGSizeMake(50, 50);
                self.color = [UIColor redColor];
                self.name =@"unknown";
                break;
        }
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    //NSLog(@"solidObject encode type:%i", self.type);
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:kPositionKey];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.zRotation] forKey:kRotationKey];
    [aCoder encodeObject:[NSNumber numberWithInt:self.type] forKey:kTypeKey];
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
   // NSLog(@"solidObject copy type:%i", self.type);
    
    NSString *imageName;
    
    //NSLog(@"type: %i", self.type);
    
    switch (self.type)
    {
            
        case kSharpener:
            imageName = @"sharpener.png";
            break;
            
        case kPencilRed:
            imageName = @"pencil_red.png";
            break;
            
        case kPencilGreen:
            imageName = @"pencil_green.png";
            break;
            
        case kPencilBlue:
            imageName = @"pencil_blue.png";
            break;
            
        case kPencilBrown:
            imageName = @"pencil_brown.png";
            break;
            
        case kEraser:
            imageName = @"objecteraser.png";
            break;
            
        default:
            break;
            
    }
    

    //NSLog(@"imageName: %@", imageName);
    
    
    
    CSMSolidObject *copy = [[[self class] allocWithZone:zone] initWithImageNamed:imageName];
   
/*
    NSLog(@"copy: %@", copy);
    if(copy.size.width == 0.0){
        SKTexture *tex = [SKTexture textureWithImageNamed:imageName];
        NSLog(@"tex: %@", tex);
        copy = [[[self class] allocWithZone:zone] initWithTexture:tex];
    }
 */
    
    
    
    copy.position = CGPointMake(self.position.x, self.position.y);
    copy.zRotation = self.zRotation;
    copy.zPosition = self.zPosition;
    copy.type = self.type;
    copy.name = self.name;
    [copy addShadow];
    
    
    return copy;
}


@end
