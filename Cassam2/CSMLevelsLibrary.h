//
//  CSMLevelsLibrary.h
//  Cassam2
//
//  Created by The Cowans on 06/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CSMLevel;


@interface CSMLevelsLibrary : NSObject //<NSCoding, NSCopying>

//@property (nonatomic) NSMutableDictionary *levels;
@property NSMutableDictionary* seedDictionary;


+(CSMLevelsLibrary*)levelsLibrary;
-(void)saveLevel:(CSMLevel*)level;
-(void)addLevel:(CSMLevel*)newLevel;
-(void)deleteLevel:(int)levelNumber;

-(CSMLevel*)level:(int)levelNumber;
-(int)newLevelNumber;
-(NSUInteger)numberOfLevels;


-(void)printFromSeedDictionary;
//+(CSMLevelsLibrary*)levelsLibraryFromKeyedArchive;
//-(void)saveLibraryInKeyedArchive;
//-(UIImage*)getLibraryImage;
//-(void)print;
@end
