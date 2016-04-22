//
//  CSMPanelSprite.h
//  Cassam2
//
//  Created by The Cowans on 02/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CSMPanelSprite : SKNode
@property BOOL inUse;
@property CGSize size;

-(id)initWithColor:(UIColor *)color number:(int)num size:(CGSize)size open:(CGVector)openVect;
-(void)close;
-(void)open;


@end
