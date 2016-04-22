//
//  CSMLevel.m
//  Cassam2
//
//  Created by The Cowans on 13/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMLevel.h"
#import "CSMSpriteNode.h"
#import "GameConstants.h"

#import "CSMAstroidSprite.h"
#import "CSMEnemySpawnPoint.h"
#import "CSMWormHoleSprite.h"
#import "CSMRocketSprite.h"
#import "CSMEnemySprite.h"
#import "CSMSpriteNode.h"
#import "CSMNodeSprite.h"
#import "CSMEnemyArtilary.h"
#import "CSMEnemyEgg.h"
#import "CSMSolidObject.h"


@interface CSMLevel()
@property (nonatomic) CGPoint rocketLocation;
@property (nonatomic) NSArray *sprites;
@property (nonatomic) NSNumber *number;
@end

@implementation CSMLevel{
    int highScore;
}

+(id)levelWithSpriteHolder:(SKNode *)spriteHolder num:(int)num fieldSize:(CGSize)size{
    CSMLevel* level = [[CSMLevel alloc] initWithSpriteHolder:spriteHolder num:num];
    level.fieldSize = size;
    return level;
}

-(id)initWithSpriteHolder:(SKNode *)spriteHolder num:(int)num{
    if([super init]){
        
        NSMutableArray *spriteList = [NSMutableArray arrayWithCapacity:10];
        self.number = [NSNumber numberWithInt:num];
        for(CSMSpriteNode *sprite in [spriteHolder children]){
            if(
               [sprite.name isEqualToString: @"enemy"]     ||
               [sprite.name isEqualToString: @"astroid"]   ||
               [sprite.name isEqualToString: @"wormhole"]  ||
               [sprite.name isEqualToString: @"enemyspawnpoint"] ||
               [sprite.name isEqualToString: @"eraser"] ||
               [sprite.name isEqualToString: @"pencil"] ||
               [sprite.name isEqualToString: @"sharpener"] ||
               [sprite.name isEqualToString:@"node"] ||
               [sprite.name isEqualToString:@"enemyartilary"] ||
               [sprite.name isEqualToString:@"enemyegg"]
               ){
                
                [spriteList addObject:sprite];
            }
            else if([sprite.name isEqualToString:@"rocket"]){
                _rocketLocation = CGPointMake(sprite.position.x, sprite.position.y);
                [spriteList removeObject:sprite];
                
            }
            _sprites = [NSArray arrayWithArray:spriteList];
        }
        //NSLog(@"created level with %lu enemies.", [self.sprites count]);
        highScore = 0;
    }
    return self;
}


+(CSMLevel*)emptyLevel:(int)num{
    CSMLevel* level = [[CSMLevel alloc]initWithSpriteHolder:nil num:num];
    level.fieldSize = CGSizeMake(kFieldSizeX, kFieldSizeY);
    return level;
}

-(CGPoint)getRocketPosition{
    return self.rocketLocation;
}

-(NSArray*)getSprites{
    return self.sprites;
}

-(NSNumber*)getLevelNumber{
    return self.number;
}

-(void)setLevelNumber:(int)i{
    self.number = [NSNumber numberWithInt:i];
}

-(void)setHighScore:(int)score{
    if (score > highScore)
        highScore = score;
}

-(int)getHighScore{
    return highScore;
}



#pragma mark - Coding

static NSString* const kSpritesKey = @"kSpritesKey";
static NSString* const kRocketKey = @"kRocketKey";
static NSString* const kNameKey = @"kNameKey";
static NSString* const kHighScoreKey = @"kHighScore";
static NSString* const kFieldSizeKey = @"f";

-(NSString*)getcsv{
    NSMutableString* output = [NSMutableString stringWithFormat:@"%i,%@,%i,%f,%f,%f,%f;",
            kCSMLevel, self.number, highScore, self.fieldSize.width, self.fieldSize.height, self.rocketLocation.x, self.rocketLocation.y];
    for(CSMSpriteNode* sprite in self.sprites){
        [output appendString:@"\n"];
        [output appendString:[sprite getcsv]];
    }
    return output;
}

-(NSArray*)levelArray{
    
    NSMutableArray* levelArray = [[NSMutableArray alloc]initWithCapacity:[self.sprites count]+1];
    
    [levelArray addObject:[self seedArray]];
    
    for(CSMSpriteNode* sprite in self.sprites){
        [levelArray addObject:[sprite seedArray]];
    }
    
    return levelArray;
    
}

+(int)levelNoFromSeedArray:(NSArray *)seedArray{
    NSArray* seedValues = [seedArray objectAtIndex:0];
    return [[seedValues objectAtIndex:1]intValue];
}

+(NSArray*)setSeedArrayLevelNo:(NSArray *)seedArray levelNo:(int)no{
    
    NSMutableArray* newSeed = [NSMutableArray arrayWithArray:seedArray];
    NSMutableArray* newLevelValuesSeed = [NSMutableArray arrayWithArray:[newSeed objectAtIndex:0]];
    
    [newLevelValuesSeed replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:no]];
    [newSeed replaceObjectAtIndex:0 withObject:newLevelValuesSeed];
    
    return [NSArray arrayWithArray:newSeed];
}


-(id)initWithSeedArray:(NSArray *)seedArray{
    
    if([[seedArray objectAtIndex:0]count] != 7){
        NSLog(@"Can't init CSMLevel with seedArray:\n%@",seedArray);
    }
    
    NSArray* levelSeed = [seedArray objectAtIndex:0];
    
    int no = [[levelSeed objectAtIndex:1]intValue];
    int higScr = [[levelSeed objectAtIndex:2]intValue];
    CGFloat fieldWidth = [[levelSeed objectAtIndex:3]floatValue];
    CGFloat fieldHeight = [[levelSeed objectAtIndex:4]floatValue];
    CGFloat rocketX = [[levelSeed objectAtIndex:5]floatValue];
    CGFloat rocketY = [[levelSeed objectAtIndex:6]floatValue];
    
    self = [super init];
    if(self)
    {
        //self.sprites = [aDecoder decodeObjectForKey:kSpritesKey];
        self.rocketLocation = CGPointMake(rocketX, rocketY);
        self.number = [NSNumber numberWithInt: no];
        highScore = higScr;
        self.fieldSize = CGSizeMake(fieldWidth, fieldHeight);
    }
    //NSLog(@"initWithCoder returning level with %lu sprites", [self.sprites count]);
    
    //load sprites
    NSMutableArray* spriteBook = [[NSMutableArray alloc]initWithCapacity:[seedArray count]-1];
    
    for(int i=1; i<[seedArray count]; i++){
        switch ([[[seedArray objectAtIndex:i]objectAtIndex:0] intValue]) {
            case kCSMLevel:
                NSLog(@"error: trying to load level in level:%@", [seedArray objectAtIndex:i]);
                break;
            case kCSMSolidObject:
                [spriteBook addObject:[[CSMSolidObject alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            case kCSMEnemySpawnPoint:
                [spriteBook addObject:[[CSMEnemySpawnPoint alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            case kCSMAsroidSprite:
                [spriteBook addObject:[[CSMAstroidSprite alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            case kCSMEnemySprite:
                [spriteBook addObject:[[CSMEnemySprite alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            case kCSMEnemyEgg:
                [spriteBook addObject:[[CSMEnemyEgg alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            case kCSMEnemyArtilary:
                [spriteBook addObject:[[CSMEnemyArtilary alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            case kCSMWormHoleSprite:
                [spriteBook addObject:[[CSMWormHoleSprite alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            case kCSMNodeSprite:
                [spriteBook addObject:[[CSMNodeSprite alloc]initWithSeedArray:[seedArray objectAtIndex:i]]];
                break;
            default:
                NSLog(@"unknown seed:\n%@", [seedArray objectAtIndex:i]);
                break;
        }
    }
    
    self.sprites = spriteBook;
    
    
    return self;
}

-(NSArray*)seedArray{
    NSMutableArray* seedArray = [NSMutableArray arrayWithCapacity:7];
    
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMLevel]];
    [seedArray addObject:self.number];
    [seedArray addObject:[NSNumber numberWithInt:highScore]];
    [seedArray addObject:[NSNumber numberWithFloat:self.fieldSize.width]];
    [seedArray addObject:[NSNumber numberWithFloat:self.fieldSize.height]];
    [seedArray addObject:[NSNumber numberWithFloat:self.rocketLocation.x]];
    [seedArray addObject:[NSNumber numberWithFloat:self.rocketLocation.y]];
    
    return seedArray;
}

+(NSArray*)setLevelSeedNumber:(NSArray*)seed number:(int)no{
    NSMutableArray* tempSeed = [NSMutableArray arrayWithArray:seed];
    [tempSeed replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:no]];
    NSArray* newSeed = [NSArray arrayWithArray:tempSeed];
    return newSeed;
}

+(int)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array{
    
    NSString *number = nil, *levelHighscore = nil, *fieldWidth = nil, *fieldHeight = nil, *rocketX = nil, *rocketY = nil;
    
    [scanner scanUpToString:@"," intoString:&number];
    [scanner scanUpToString:@"," intoString:&levelHighscore];
    [scanner scanUpToString:@"," intoString:&fieldWidth];
    [scanner scanUpToString:@"," intoString:&fieldHeight];
    [scanner scanUpToString:@"," intoString:&rocketX];
    [scanner scanUpToString:@";" intoString:&rocketY];
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:7];
    
    [seedArray addObject:[NSNumber numberWithInt:kCSMLevel]];
    [seedArray addObject:[NSNumber numberWithInt:[number intValue]]];
    [seedArray addObject:[NSNumber numberWithInt:[levelHighscore intValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[fieldWidth floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[fieldHeight floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[rocketX floatValue]]];
    [seedArray addObject:[NSNumber numberWithFloat:[rocketY floatValue]]];
    
    [array addObject:seedArray];
    
    return [number intValue];
}




-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self)
    {
        self.sprites = [aDecoder decodeObjectForKey:kSpritesKey];
        self.rocketLocation = [[aDecoder decodeObjectForKey:kRocketKey] CGPointValue];
        self.number = [aDecoder decodeObjectForKey:kNameKey];
        highScore = [[aDecoder decodeObjectForKey:kHighScoreKey] intValue];
        self.fieldSize = [[aDecoder decodeObjectForKey:kFieldSizeKey] CGSizeValue];
    }
    //NSLog(@"initWithCoder returning level with %lu sprites", [self.sprites count]);
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    //NSLog(@"encodeWithCoder level with %lu sprites", [self.sprites count]);
    [aCoder encodeObject:self.sprites forKey:kSpritesKey];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.rocketLocation] forKey:kRocketKey];
    [aCoder encodeObject:self.number forKey:kNameKey];
    [aCoder encodeObject:[NSNumber numberWithInt:highScore] forKey:kHighScoreKey];

    if(self.fieldSize.width != 0.0){
        [aCoder encodeObject:[NSValue valueWithCGSize:self.fieldSize] forKey:kFieldSizeKey];
    }
    else{
        NSLog(@"fieldsize.width = 0.0");
    }
    
}

#pragma mark - Copying

-(id)copyWithZone:(NSZone *)zone{
    CSMLevel *copy = [[[self class] allocWithZone:zone] init];
    NSMutableArray *spritesCopy = [NSMutableArray array];
    for(id enemy in self.sprites){
        [spritesCopy addObject:[enemy copyWithZone:zone]];
    }
    copy.sprites = spritesCopy;
    copy.rocketLocation = CGPointMake(self.rocketLocation.x, self.rocketLocation.y);
    copy.number = [self.number copyWithZone:zone];
    [copy setHighScore:self.getHighScore];
    copy.fieldSize = CGSizeMake(self.fieldSize.width, self.fieldSize.height);
    //NSLog(@"copyWithZone level with %lu sprites", [self.sprites count]);
    return copy;
}



@end
