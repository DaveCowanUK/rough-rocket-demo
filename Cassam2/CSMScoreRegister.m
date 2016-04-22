//
//  CSMScoreRegister.m
//  Cassam2
//
//  Created by The Cowans on 06/10/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMScoreRegister.h"

@interface CSMScoreRegister()
@property NSMutableDictionary* scores;

@end

@implementation CSMScoreRegister


+(CSMScoreRegister*)scoreRegister{
    return [[CSMScoreRegister alloc]init];
}

-(id)init{
    if([super init]){
        
        //check for file
        if([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]){
            self.scores = [[NSMutableDictionary alloc] initWithContentsOfFile:[self dataFilePath]];
            self.totalScore = [self addScores];
            //NSLog(@"scores loaded:\n%@", self.scores);
        }
        else{
            //NSLog(@"no scores file");
            self.scores = [[NSMutableDictionary alloc] initWithCapacity:10];
            self.totalScore = 0;
        }
        
    }
    return self;
}

-(NSString*)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"scores.data"];
}

-(void)saveRegister{
    
    if([self.scores writeToFile:[self dataFilePath] atomically:YES])
        //NSLog(@"file written");
        ;
    else
        NSLog(@"file not written");
    
    //check for file:
    if([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]])
       // NSLog(@"file found");
        ;
    else
        NSLog(@"file not found");
}


-(int)scoreForLevel:(int)levelNo{
    
    NSNumber* scoreRecord = [self.scores objectForKey:[[NSNumber numberWithInt:levelNo]stringValue]];
    int score = scoreRecord ? [scoreRecord intValue] : 0 ;
    
   // NSLog(@"retunring score %i for level %i", score, levelNo);
    
    return score;
}



-(void)setScore:(int)score forLevel:(int)levelNo{
    //NSLog(@"setting score %i for level %i", score, levelNo);
    
    [self.scores setObject:[NSNumber numberWithInt:score] forKey:[[NSNumber numberWithInt:levelNo]stringValue]];
    
    //[self.scores removeObjectForKey:[[NSNumber numberWithInt:levelNo]stringValue]];
    
    self.totalScore = [self addScores];
    
    //NSLog(@"total:%i", self.totalScore);
    
    [self saveRegister];
}

-(int)addScores{
    
    int total = 0;
    
    for(NSString* x in [self.scores allKeys]){
        total += [[self.scores objectForKey:x] intValue];
    }
    
    return total;
}

-(BOOL)allLevelsScoredUpTo:(int)toLevel{
    
    BOOL allScored = YES;
    
    for(int i=1; i<=toLevel; i++){
        NSNumber* scoreRecord = [self.scores objectForKey:[[NSNumber numberWithInt:i]stringValue]];
        if(!scoreRecord){
            allScored = NO;
        }
    }
    
    return allScored;
    
}


@end
