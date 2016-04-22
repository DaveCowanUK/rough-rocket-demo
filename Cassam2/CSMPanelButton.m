//
//  CSMPanelButton.m
//  Cassam2
//
//  Created by The Cowans on 23/07/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMPanelButton.h"
#import "CSMPanelSprite.h"

@implementation CSMPanelButton{
    CGVector openVector;
    BOOL isOpen;
}

-(id)initWithColor:(UIColor *)color edge:(panelPosition)edge parentScene:(SKScene *)scene{
    if([super initWithColor:color size:CGSizeMake(20, scene.frame.size.height/5)]){
        
        self.anchorPoint = CGPointMake(1, 0);
        self.alpha = 0.7;
        isOpen = NO;
        
        //prepare panel
        CGSize panelSize = CGSizeMake(80, scene.frame.size.height);
        openVector = CGVectorMake(-68, 0);
        self.panel = [[CSMPanelSprite alloc]initWithColor:[SKColor grayColor] number:0 size:panelSize open:openVector];
        self.panel.position = CGPointMake((scene.frame.size.width/2), -scene.frame.size.height/2);
        [scene addChild:self.panel];
        
        
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"%@ touchesEnded", self.name);
    if(isOpen)
        [self close];
    else
        [self open];
}

-(void)open{
    NSLog(@"[self.panel open] - %@", self.panel.name);
    [self.panel open];
    [self runAction:[SKAction moveBy:openVector duration:0.2]];
    isOpen = YES;
}

-(void)close{
    [self.panel close];
    [self runAction:[SKAction moveBy:CGVectorMake(-openVector.dx, -openVector.dy) duration:0.2]];
    isOpen = NO;
}


@end
