//
//  CSMLevelIcon.m
//  Cassam2
//
//  Created by The Cowans on 01/05/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMLevelIcon.h"
#import "CSMMenuScene.h"
#import "Tools.h"

@implementation CSMLevelIcon{
    CSMMenuScene* menScene;
    CGPoint touchStart;
    CGPoint touchEnd;
    BOOL triggerWhenReleased;
}

-(id)initWithTexture:(SKTexture *)texture scene:(CSMMenuScene *)scene type:(ButtonType)use{
    if(self = [super initWithTexture:texture]){
        menScene = scene;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //record position of touch
    NSSet* allTouches = [event allTouches];
    touchStart = [[allTouches anyObject] locationInNode:self];
    triggerWhenReleased = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //scroll parent scene
    NSSet *allTouches = [event allTouches];
    touchEnd = [[allTouches anyObject] locationInNode:self];
    
    //switch off response if we think scroll rather than touch expected
    if([Tools getDistanceBetween:touchStart and:touchEnd] > 10){
        triggerWhenReleased = NO;
    }
    [menScene scrollFrom:touchStart to:touchEnd];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(triggerWhenReleased){
        SKLabelNode* label = (SKLabelNode*)[self childNodeWithName:@"label"];
        [menScene labelTouched:label.text];
    }
}

-(void)clearReferences{
    menScene = nil;
}

@end
