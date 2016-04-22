//
//  CSMScoreRegister.h
//  Cassam2
//
//  Created by The Cowans on 06/10/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSMScoreRegister : NSObject

@property (nonatomic)  int totalScore;

+(CSMScoreRegister*)scoreRegister;
-(int)scoreForLevel:(int)levelNo;
-(int)totalScore;
-(void)setScore:(int)score forLevel:(int)levelNo;
-(BOOL)allLevelsScoredUpTo:(int)toLevel;

@end
