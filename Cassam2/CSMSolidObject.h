//
//  CSMSolidObject.h
//  Cassam2
//
//  Created by The Cowans on 20/06/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMSpriteNode.h"
#import "GameConstants.h"

@interface CSMSolidObject : CSMSpriteNode
@property spriteType type;
//-(id)initWithImageNamed:(NSString *)name scene:(CSMTemplateScene*)scene;
-(id)initWithType:(spriteType)type scene:(CSMTemplateScene*)scene;
-(void)setScene:(CSMTemplateScene*)scene;
-(void)reshadow;
@end
