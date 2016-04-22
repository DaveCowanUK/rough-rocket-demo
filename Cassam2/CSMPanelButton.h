//
//  CSMPanelButton.h
//  Cassam2
//
//  Created by The Cowans on 23/07/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class CSMPanelSprite;

typedef enum {
    kPanelTop = 0,
    kPanelRight,
    kPanelBottom,
    kPanelLeft
} panelPosition;

@interface CSMPanelButton : SKSpriteNode

@property CSMPanelSprite* panel;

-(id)initWithColor:(UIColor *)color edge:(panelPosition)edge parentScene:(SKScene*)scene;

@end
