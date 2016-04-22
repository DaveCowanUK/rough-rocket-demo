//
//  CSMLevelsLibrary.m
//  Cassam2
//
//  Created by The Cowans on 06/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMLevelsLibrary.h"
#import "CSMLevel.h"
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

#import <AssetsLibrary/AssetsLibrary.h>

static NSString* const kLevelsKey = @"kLevelsKey";

@interface CSMLevelsLibrary()

@end

@implementation CSMLevelsLibrary


+(CSMLevelsLibrary*)levelsLibrary{
    return [[CSMLevelsLibrary alloc]init];
}

-(id)init{
    if([super init]){
        [self loadLevelsFromTextFile];
        //NSLog(@"seedDictionary:\n%@", [self levelStringFromSeedDictionary]);
    }
    return  self;
}

-(CSMLevel*)level:(int)levelNumber{
    
    NSArray* levelSeed = [self.seedDictionary objectForKey:[NSNumber numberWithInt:levelNumber]];
    if(levelSeed)
        return [[CSMLevel alloc]initWithSeedArray:levelSeed];
    else
        return [CSMLevel emptyLevel:levelNumber];
    
    /*
     CSMLevel *l = [self.levels objectForKey:[NSNumber numberWithInt:levelNumber]];
     if(l == nil)
     l = [CSMLevel emptyLevel:levelNumber];
     return l;
     */
}

-(NSUInteger)numberOfLevels{
    return[self.seedDictionary count];
}


#pragma mark - Editing levels

-(void)saveLevel:(CSMLevel *)level{
    NSLog(@"new level: %@", [level getcsv]);
    if(level == nil)
        NSLog(@"nil level");
    [self.seedDictionary setObject:[level levelArray] forKey:[level getLevelNumber]];
    [self saveLibraryToTextFile];
}

-(void)addLevel:(CSMLevel *)newLevel{
    if(newLevel == nil)
       NSLog(@"nil level");
    
    if ( newLevel.getLevelNumber.intValue  <  ( (int)[self.seedDictionary count] + 1 ) )
        [self makeSpaceForLevel:newLevel.getLevelNumber.intValue];
    
    [self.seedDictionary setObject:[newLevel levelArray] forKey:[newLevel getLevelNumber]];
    //[self checkLevelNumbering];
}

-(void)deleteLevel:(int)levelNumber{
    
    [self.seedDictionary removeObjectForKey:[NSNumber numberWithInt:levelNumber]];
    [self checkLevelNumbering];
    [self saveLibraryToTextFile];
}

-(int)newLevelNumber{
    //NSLog(@"[library newLevelNumber]: %i", (int)[self.seedDictionary count] + 1);
    return (int)[self.seedDictionary count] + 1;
}

-(void)makeSpaceForLevel:(int)levelNo{
    //enumerate seedDictionary
    NSArray* keys = [self.seedDictionary allKeys];
    NSMutableDictionary* tempSeedDictionary = [[NSMutableDictionary alloc]initWithCapacity:[self.seedDictionary count]];
    
    //add one to all levels necessary
    for(NSNumber* levelKey in keys){
        NSArray* tempLevelArray = [self.seedDictionary objectForKey:levelKey];
        if([CSMLevel levelNoFromSeedArray:tempLevelArray] >= levelNo){
            int newLevelNo = [CSMLevel levelNoFromSeedArray:tempLevelArray] + 1;
            tempLevelArray = [CSMLevel setSeedArrayLevelNo:tempLevelArray levelNo:newLevelNo];
            
        }
        [tempSeedDictionary setObject:tempLevelArray forKey:[NSNumber numberWithInt:[CSMLevel levelNoFromSeedArray:tempLevelArray] ]];
    }
    self.seedDictionary = tempSeedDictionary;
}

-(void)checkLevelNumbering{
    //NSLog(@"check level numbering");
    
    //enumerate seedDictionary
    NSArray* keys = [self.seedDictionary allKeys];
    NSArray* sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    int i = 0;
    
    for(NSNumber* levelKey in sortedKeys){
        i++;
        
        NSArray* tempLevelArray = [self.seedDictionary objectForKey:levelKey];
        if([CSMLevel levelNoFromSeedArray:tempLevelArray] != i){
            tempLevelArray = [CSMLevel setSeedArrayLevelNo:tempLevelArray levelNo:i];
        }
        [self.seedDictionary setObject:tempLevelArray forKey:[NSNumber numberWithInt:[CSMLevel levelNoFromSeedArray:tempLevelArray] ]];
    }
}



#pragma mark - Loading & Saving Data

+(NSString*)bundleDataFilePath{
    //NSLog(@"!!");
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"data.archive"];
}

+(NSString*)documentsDataFolderPath{
    //NSLog(@"!!");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return  documentsDirectory;
}

+(NSString*)textDataBundleFilePath{
    
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"levels.txt"];
}

-(void)printFromSeedDictionary{
    
    //NSLog(@"levels from seedDictionary:\n%@", [self levelStringFromSeedDictionary]);
}

-(NSString*)levelStringFromSeedDictionary{
    //NSMutableString *output = [NSMutableString stringWithFormat:@"CSMLevelsLibrary at %f", NSTimeIntervalSince1970];
    
    //[output appendString:@"\n"];
    NSMutableString *output = [NSMutableString string];
    
    [output appendString:[NSString stringWithFormat:@"%i,%lu;\n", kCSMHeader, (unsigned long)[self.seedDictionary count]]];
    
    NSArray* keys = [self.seedDictionary allKeys];
    NSArray* sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    for(NSNumber* levelNumber in sortedKeys){
        for(NSArray* objectSeed in [self.seedDictionary objectForKey:levelNumber]){
            //NSLog(@"array:%@", objectSeed);
            //[output appendString:@";\n"];
            for(NSNumber* number in objectSeed){
                [output appendString:[NSString stringWithFormat:@"%@,", [number stringValue]]];
            }
            [output deleteCharactersInRange:NSMakeRange(output.length-1, 1)];
            [output appendString:@";\n"];
        }
    }
    return output;
}


#pragma mark - Loading

-(void)loadLevelsFromTextFile{
    //NSLog(@"loadLevelsFromTextFile");
    NSString *filePath = [[CSMLevelsLibrary documentsDataFolderPath] stringByAppendingPathComponent:@"levels.txt"];
    NSString *fileString;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        //NSLog(@"levels.txt exists in documents");
        //NSLog(@"loading file at:\n%@", filePath);
        fileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    }
    else{
        //NSLog(@"levels.txt does not exist in documents");
        //NSLog(@"loading file at:\n%@", [CSMLevelsLibrary textDataBundleFilePath]);
        fileString = [NSString stringWithContentsOfFile:[CSMLevelsLibrary textDataBundleFilePath] encoding:NSUTF8StringEncoding error:NULL];
    }
    
    //NSLog(@"fileString:\n%@", fileString);
    
    [self loadLevelsFromString:fileString];
    
}

-(void)loadLevelsFromString:(NSString*)levelsString{
    //NSLog(@"loading levels from string:\n%@", levelsString);
    
    NSScanner *scanner = [NSScanner scannerWithString:levelsString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\n,; "]];
    
    NSString* objectType = nil, *numberOfLevels = nil;
    
    //load header
    [scanner scanUpToString:@"," intoString:&objectType];
    [scanner scanUpToString:@";" intoString:&numberOfLevels];
    
    //NSLog(@"header:%@, %@", objectType, numberOfLevels);
    
    //NSLog(@"numberOfLevels:%@", numberOfLevels);
    
    
    NSMutableArray* seedArray = [[NSMutableArray alloc]initWithCapacity:2];
    
    /*
     what is this???
     [seedArray addObject:[NSNumber numberWithInt:kCSMHeader]];
     [seedArray addObject:[NSNumber numberWithFloat:[numberOfLevels intValue]]];
     */
    
    
    
    //NSMutableDictionary* seedDictionary = [[NSMutableDictionary alloc]initWithCapacity:[numberOfLevels intValue]];
    
    self.seedDictionary = [[NSMutableDictionary alloc ]initWithCapacity:[numberOfLevels intValue]];
    
    
    int levelNumber = 0;
    
    
    BOOL seedReady = NO;
    
    while([scanner scanUpToString:@"," intoString:&objectType]){
        //NSLog(@"objectType string:%@", objectType);
        int itype = [objectType intValue];
        //NSLog(@"object type:%i", itype);
        switch (itype) {
            case kCSMLevel:
                if(seedReady){
                    [self.seedDictionary setObject:[seedArray copy] forKey:[NSNumber numberWithInt:levelNumber]];
                }
                seedArray = [NSMutableArray arrayWithCapacity:3];
                levelNumber = [CSMLevel getSeedValues:scanner array:seedArray];
                seedReady = YES;
                break;
            case kCSMSolidObject:
                [CSMSolidObject getSeedValues:scanner array:seedArray];
                break;
            case kCSMEnemySpawnPoint:
                [CSMEnemySpawnPoint getSeedValues:scanner array:seedArray];
                break;
            case kCSMAsroidSprite:
                [CSMAstroidSprite getSeedValues:scanner array:seedArray];
                break;
            case kCSMEnemySprite:
                [CSMEnemySprite getSeedValues:scanner array:seedArray];
                break;
            case kCSMEnemyEgg:
                [CSMEnemyEgg getSeedValues:scanner array:seedArray];
                break;
            case kCSMEnemyArtilary:
                [CSMEnemyArtilary getSeedValues:scanner array:seedArray];
                break;
            case kCSMWormHoleSprite:
                [CSMWormHoleSprite getSeedValues:scanner array:seedArray];
                break;
            case kCSMNodeSprite:
                [CSMNodeSprite getSeedValues:scanner array:seedArray];
                break;
            default:
                NSLog(@"other thing");
                break;
        }
    }
    //add last level
    [self.seedDictionary setObject:[seedArray copy] forKey:[NSNumber numberWithInt:levelNumber]];
    
    //NSLog(@"seedDictionary level 1:\n%@", [self.seedDictionary objectForKey:[NSNumber numberWithInt:1]]);
    
    //NSLog(@"seedDictionary:%@\n", self.seedDictionary);
    
}


#pragma mark - Saving

-(void)saveLibraryToTextFile{
    NSString *filePath = [[CSMLevelsLibrary documentsDataFolderPath] stringByAppendingPathComponent:@"levels.txt"];
    
    
    [[self levelStringFromSeedDictionary] writeToFile:filePath atomically:YES
                                             encoding:NSUTF8StringEncoding error:nil];
   NSLog(@"\n%@", [self levelStringFromSeedDictionary]);
    
    
    /*
    NSString* tempPath = [[CSMLevelsLibrary documentsDataFolderPath] stringByAppendingPathComponent:@"temp.txt"];
    
    if([self.seedDictionary writeToFile:tempPath atomically:YES])
        NSLog(@"written to temp file");
    else
        NSLog(@"not written to temp file");
     */
    
}


@end

/*
 
 +(NSString*)dataFilePath{
 NSLog(@"!!");
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 
 // return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"data.archive"];
 
 return  [documentsDirectory stringByAppendingPathComponent:@"data.archive"];
 }
 
 -(id)initWithCoder:(NSCoder *)aDecoder{
 self = [super init];
 if(self)
 {
 self.levels = [aDecoder decodeObjectForKey:kLevelsKey];
 }
 return self;
 }
 
 -(void)encodeWithCoder:(NSCoder *)aCoder{
 [aCoder encodeObject:self.levels forKey:kLevelsKey];
 }
 */

/*
 -(id)copyWithZone:(NSZone *)zone{
 CSMLevelsLibrary *copy = [[[self class] allocWithZone:zone] init];
 NSMutableDictionary *levelsCopy = [NSMutableDictionary dictionary];
 for(CSMLevel* level in self.levels){
 [levelsCopy setObject:[level copyWithZone:zone] forKey:[[level getLevelNumber] copyWithZone:zone]];
 }
 copy.levels = levelsCopy;
 return copy;
 }
 */

/*
 +(CSMLevelsLibrary*)levelsLibraryFromKeyedArchive{
 CSMLevelsLibrary* library;
 // [self readTextFile];
 NSLog(@"!!loadLevelsLibrary");
 
 NSString *filePath = [self documentsDataFilePath];
 NSLog(@"%@", filePath);
 if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
 
 
 NSDictionary* atts = [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:NULL];
 NSLog(@"file exists; size = %@,", [atts objectForKey:NSFileSize]);
 
 NSData* data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
 NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
 library = [unarchiver decodeObjectForKey:kLevelsKey];
 [unarchiver finishDecoding];
 
 [library loadLevelsFromString:[library levelsString]];
 
 //return library;
 return nil;
 }
 else
 NSLog(@"loading levels library failed.");
 
 
 [library loadLevelsFromString:[library levelsString]];
 
 return nil;
 }
 */

/*
 -(void)saveLibraryInKeyedArchive{
 
 NSLog(@"saveLibrary with %lu levels", (unsigned long)[self.levels count]);
 
 
 NSString *filePath = [CSMLevelsLibrary documentsDataFilePath];
 
 //BIDFourLines *fourLines = [[BIDFourLines alloc] init];
 //fourLines.lines = [self.lineFields valueForKey:@"text"];
 
 NSMutableData *data = [[NSMutableData alloc] init];
 NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
 [archiver encodeObject:self forKey:kLevelsKey];
 [archiver finishEncoding];
 [data writeToFile:filePath atomically:YES];
 
 
 //write image to photo library
 UIImage* imagetosave = [UIImage imageNamed:@"astroid2.png"];
 NSLog(@"imagetosave=%@", imagetosave);
 
 UIImageWriteToSavedPhotosAlbum(imagetosave, nil, nil, nil);
 */

//and as an image
//UIImage* imageRecord = [UIImage imageWithData:data];

/*
 
 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
 [library writeImageDataToSavedPhotosAlbum:data metadata:NULL completionBlock:
 ^(NSURL *newURL, NSError *error) {
 if (error) {
 NSLog( @"Error writing image with metadata to Photo Library: %@", error );
 } else {
 NSLog( @"Wrote image with metadata to Photo Library");
 }
 }
 ];
 
 
 // UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
 
 
 
 }
 */