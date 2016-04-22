//
//  CSMNodeSprite.h
//  Cassam2
//
//  Created by The Cowans on 04/07/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMSpriteNode.h"
#import "GameConstants.h"

@interface CSMNodeSprite : CSMSpriteNode <NSCoding, NSCopying>


@property CGFloat angularVelocity;

-(id)initWithNumber:(int)num scene:(CSMTemplateScene*)scene;
//-(void)highlightNode;
//-(void)removeHighlight;

-(void)hide;

@end
