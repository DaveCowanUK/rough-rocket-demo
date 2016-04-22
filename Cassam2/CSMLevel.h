//
//  CSMLevel.h
//  Cassam2
//
//  Created by The Cowans on 13/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>


@interface CSMLevel : NSObject <NSCoding, NSCopying>

@property CGSize fieldSize;

+(id)levelWithSpriteHolder:(SKNode *)spriteHolder num:(int)num fieldSize:(CGSize)size;
-(id)initWithSpriteHolder:(SKNode *)spriteHolder num:(int)num;
//-(id)initWithSpriteHolder1:(SKNode *)spriteHolder num:(int)num;
+(CSMLevel*)emptyLevel:(int)num;
-(CGPoint)getRocketPosition;
-(NSArray*)getSprites;
-(NSNumber*)getLevelNumber;
-(void)setLevelNumber:(int)i;
-(int)getHighScore;
-(void)setHighScore:(int)i;

-(NSString*)getcsv;
//+(void)getSeedValues:(NSScanner*)scanner array:(NSMutableArray*)array;
+(int)getSeedValues:(NSScanner *)scanner array:(NSMutableArray *)array;
+(NSArray*)setLevelSeedNumber:(NSArray*)seed number:(int)no;
-(NSArray*)levelArray;
-(id)initWithSeedArray:(NSArray *)seedArray;

+(int)levelNoFromSeedArray:(NSArray*)seedArray;
+(NSArray*)setSeedArrayLevelNo:(NSArray*)seedArray levelNo:(int)no;
@end
