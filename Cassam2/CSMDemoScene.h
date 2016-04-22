//
//  CSMDemoScene.h
//  Cassam
//
//  Created by The Cowans on 29/01/2015.
//  Copyright (c) 2015 RNC. All rights reserved.
//

#import "CSMGamePlayScene.h"

@interface CSMDemoScene : CSMGamePlayScene

+(id)sceneWithSize:(CGSize)size gameData:(CSMGameData *)gData;
-(id)initWithSize:(CGSize)size gameData:(CSMGameData*)gData;
//-(void)showGame;
@end
