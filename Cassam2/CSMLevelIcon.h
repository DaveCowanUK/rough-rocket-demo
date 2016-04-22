//
//  CSMLevelIcon.h
//  Cassam2
//
//  Created by The Cowans on 01/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "ButtonSprite.h"
@class CSMMenuScene;

@interface CSMLevelIcon : ButtonSprite

-(id)initWithTexture:(SKTexture*)texture scene:(CSMMenuScene*)scene type:(ButtonType)use;
-(void)clearReferences;

@end
