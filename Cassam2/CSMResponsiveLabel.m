//
//  CSMResponsiveLabel.m
//  Cassam2
//
//  Created by The Cowans on 10/04/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMResponsiveLabel.h"
#import "CSMResponsiveSKScene.h"


@implementation CSMResponsiveLabel{
    CSMResponsiveSKScene* parentScene;
    int number;
}

-(id)initWithScene:(CSMResponsiveSKScene *)scene{
    if([super init]){
        parentScene = scene;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(id)initWithNumber:(int)i scene:(CSMResponsiveSKScene *)scene{
    if([self initWithScene:scene]){
        number = i;
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [parentScene labelTouched:self.text];
}

-(void)clearReferences{
    parentScene = nil;
}

@end
