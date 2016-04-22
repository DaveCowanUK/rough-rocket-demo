//
//  CSMResponsiveSKScene.m
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMResponsiveSKScene.h"

@implementation CSMResponsiveSKScene

-(void)buttonTouched:(ButtonType)button{
    //for subclasses
}


-(void)buttonReleased:(ButtonType)button{
    //for subclasses
}

-(void)createSceneContents{
    //for subclass
}

-(void)labelTouched:(NSString*)labelText{}

-(void)clearReferences{
    self.paused = YES;
    [self removeAllActions];
    
    for(SKNode* childNode in [self children]){
        [childNode removeAllActions];
        if([childNode isKindOfClass:[CSMSpriteNode class]]){
            [(CSMSpriteNode*)childNode removeReferences];
        }
    }
    [self removeAllChildren];
}




@end
