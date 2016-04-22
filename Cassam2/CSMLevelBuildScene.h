//
//  CSMLevelBuildScene.h
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//


#import "CSMTemplateScene.h"
@class CSMLevelsLibrary;
@class CSMLevel;
@class CSMGameData;

@interface CSMLevelBuildScene : CSMTemplateScene <UITextFieldDelegate>
+(id)sceneWithSize:(CGSize)size library:(CSMLevelsLibrary*)library level:(CSMLevel*)level; //old
+(id)sceneWithSize:(CGSize)size level:(CSMLevel*)level gameData:(CSMGameData*)gData; //new
-(id)initWithSize:(CGSize)size library:(CSMLevelsLibrary*)library level:(CSMLevel*)level;
-(BOOL)editMode;
-(void)displayImage:(CGImageRef)image;
@end

