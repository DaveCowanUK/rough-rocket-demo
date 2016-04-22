//
//  CSMEnemyArtilary.h
//  Cassam2
//
//  Created by The Cowans on 13/08/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMEnemySprite.h"



@interface CSMEnemyArtilary : CSMEnemySprite

@property CGFloat homeRotation;


-(id)initWithScene:(CSMTemplateScene *)scene rotation:(CGFloat)rotation;
//-(void)doPhysics;
@end
