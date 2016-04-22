//
//  Tools.m
//  Cassam2
//
//  Created by The Cowans on 28/01/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "Tools.h"



@implementation Tools

-(id)init{
    if(self = [super init]){
        self.kFieldSize = CGSizeMake(2400, 1600);
        
    }
    return  self;
}

+(void)addTilesWithTexture:(SKTexture *)texture to:(SKNode *)node area:(CGRect)rect zPos:(CGFloat)zPos{
    SKSpriteNode* tileNode;
    //int count = 0;
    
    //int maxI = rect.size.width/texture.size.width;
    //int maxJ = rect.size.height/texture.size.height;
    
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat textureWidth = 1.0;
    CGFloat textureHeight = 1.0;
    
    
    while(x < rect.size.width)
    {
        if( (rect.size.width - x) < texture.size.width){
            textureWidth = ( rect.size.width - x ) / texture.size.width ;
        }
        else
            textureWidth = 1.0;
        
        while (y < rect.size.height)
        {
            if( (rect.size.height - y) < texture.size.height){
                textureHeight =  ( rect.size.height - y ) / texture.size.height;
            }
            else
                textureHeight = 1.0;
            
            if(textureHeight * textureWidth){
                tileNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture
                                                                  textureWithRect:CGRectMake(0.0, 0.0, textureWidth, textureHeight)
                                                                  inTexture:texture]];                tileNode.name = @"tile";
                tileNode.anchorPoint = CGPointMake(0.0, 0.0);
                tileNode.position = CGPointMake((rect.origin.x + x), (rect.origin.y + y));
                tileNode.physicsBody.dynamic = NO;
                tileNode.zPosition = zPos;
                tileNode.name = @"tile";
                //tileNode.alpha = 0.3;
                //NSLog(@"adding tilet at %f, %f", tileNode.position.x, tileNode.position.y);
                [node addChild:tileNode];
                y += textureHeight * texture.size.height;
            }
        }
        
        x += textureWidth * texture.size.width;
        y = 0.0;
        
        
        
    }
    
    /*
    
    for(int j=0; j<=maxJ; j++)
        for(int i=0; i<=maxI; i++){
     
            if(i == maxI){
                textureWidth = fmodf(rect.size.width, texture.size.width) / texture.size.width;
                NSLog(@"texture width = %f", textureWidth);
            }
            if(j == maxJ) {
                textureHeight = fmodf(rect.size.height, texture.size.height) / texture.size.height;
                NSLog(@"texture hieght = %f", textureHeight);
            }
     
            tileNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture
                                                              textureWithRect:CGRectMake(0.0, 0.0, textureWidth, textureHeight)
                                                              inTexture:texture]];
            tileNode.name = @"tile";
            tileNode.anchorPoint = CGPointMake(0.0, 0.0);
            tileNode.position = CGPointMake((rect.origin.x + i * texture.size.width), (rect.origin.y + j * texture.size.height));
            tileNode.physicsBody.dynamic = NO;
            tileNode.zPosition = zPos;
            //NSLog(@"adding tilet at %f, %f", tileNode.position.x, tileNode.position.y);
            [node addChild:tileNode];
            count++;
        }
*/
    /*
    //add surface
    SKTexture* surfaceTexture = [SKTexture textureWithImageNamed:@"surface.jpg"];
    
    //top edge
    for(int i=0; i<(rect.size.width/surfaceTexture.size.width+1); i++){
        tileNode = [[SKSpriteNode alloc] initWithTexture:surfaceTexture];
        tileNode.name = @"tile";
        tileNode.anchorPoint = CGPointMake(0.0, 0.0);
        tileNode.position = CGPointMake(
                                        rect.origin.x - surfaceTexture.size.width + i * surfaceTexture.size.width,
                                        rect.origin.y - surfaceTexture.size.height
                                        );
        tileNode.physicsBody.dynamic = NO;
        tileNode.zPosition = 20;
        [node addChild:tileNode];
    }
     */
}

+(CGFloat)getDistanceBetween:(CGPoint)pointA and:(CGPoint)pointB{
    CGFloat distance = sqrtf(
                             ( (pointA.x - pointB.x) * (pointA.x - pointB.x) ) +
                             ( (pointA.y - pointB.y) * (pointA.y - pointB.y) )
                             );
    return distance;
}

+(CGPoint)getMidPoint:(CGPoint)pointA and:(CGPoint)pointB{
    return CGPointMake(
                       (pointA.x + pointB.x) / 2 ,
                       (pointA.y + pointB.y) / 2
                       );
    
    
}

+(CGFloat)getAngleFrom:(CGPoint)pointA to:(CGPoint)pointB{
    
    
    CGFloat angle = 0.0;
    
    
    //CGFloat angle = -atan2f(pointB.x - pointA.x, pointB.y - pointA.y);
    
    //NSLog(@"A: %2.0f, %2.0f; B: %2.0f, %2.0f", pointA.x, pointA.y, pointB.x, pointB.y);
    
    
    //convert pointB to a point relative to pointA
    pointB = CGPointMake(
                         pointB.x - pointA.x,
                         pointB.y - pointA.y
                         );
    //NSLog(@"B relative to A: %2.0f, %2.0f", pointB.x, pointB.y);
    
    if(pointB.y > 0 && pointB.x > 0){
        angle = (2 * M_PI) - atanf( (pointB.x) / (pointB.y));
        //NSLog(@"1");
    }
    else if(pointB.y == 0){
        angle = pointB.x > 0 ? (M_PI * 1.5) : (M_PI * 0.5);
        //NSLog(@"2");
    }
    else if(pointB.x == 0){
        angle = pointB.y > 0 ? 0.0 : M_PI ;
    }
    else if(pointB.y < 0 && pointB.x > 0){
        angle = M_PI - atanf( pointB.x / pointB.y);
        //NSLog(@"3");
    }
    else if(pointB.y < 0 && pointB.x < 0){
        angle = M_PI - atanf( (pointB.x) / (pointB.y));
        //NSLog(@"4");
    }
    else if(pointB.y > 0 && pointB.x < 0){
        angle = - atanf( (pointB.x) / (pointB.y));
        //NSLog(@"5");
    }
    
    //NSLog(@"angle: %f pi", angle/M_PI);
    
    
    
    //angle = - atan2f(pointB.x, pointB.y);
    
    
    return angle;
    
}

+(CGFloat)turnToward:(CGFloat)targetAngle from:(CGFloat)currentAngle step:(CGFloat)spinAmount{
    
    
    //correct zRotation if its over 2PI or less than 0
    if(currentAngle > (2 * M_PI))
        currentAngle -= (2 * M_PI);
    if(currentAngle < 0)
        currentAngle += (2*M_PI);
    
    //check if need to turn at all
    if(targetAngle == currentAngle){
        return currentAngle;
    }
    
    //if target is less than one step different just set zRotation
    if( fabs(targetAngle - currentAngle) < (spinAmount) ){
        return targetAngle;
    }
    
    //decide on clockwise or anticlockwise turn
    CGFloat spinVal;
    //NSLog(@"target: %f, current: %f", targetAngle/M_PI, currentAngle/M_PI);
    CGFloat theta = targetAngle > currentAngle ? (targetAngle - currentAngle) : (currentAngle - targetAngle);
    //NSLog(@"theta: %f", theta/M_PI);
    if(theta < M_PI){
        spinVal = targetAngle > currentAngle ? (spinAmount) : (-spinAmount);
        //NSLog(@"clockwise");
    }
    else{
        spinVal = targetAngle < currentAngle ? (spinAmount) : (-spinAmount);
        //NSLog(@"anti-clockwise");
    }
    
    //move the zRotation one step on
    currentAngle += spinVal;
    
    //correct zRotation if its over 2PI or less than 0
    if(currentAngle > (2 * M_PI))
        currentAngle -= (2 * M_PI);
    if(currentAngle < 0)
        currentAngle += (2*M_PI);
    //NSLog(@"zRotation: %f, headgin: %f, adding %f", currentAngle, target, (spinVal / M_PI));
    //NSLog(@"returning %f", currentAngle / M_PI);
    return currentAngle;
    //currentAngle = target;
    //NSLog(@"%f", (currentAngle / M_PI) );
}

+(CSMEnemySettings)CSMEnemySettingsMake:(CGPoint)position WithRot:(CGFloat)rotation{
    CSMEnemySettings settings;
    settings.position = position;
    settings.rotation = rotation;
    return  settings;
}

+(CSMEnemySpawnPointSettings)CSMEnemySpawnPointSettingsMake:(CGPoint)position WithRot:(CGFloat)spawnRate{
    CSMEnemySpawnPointSettings settings;
    settings.position = position;
    settings.spawnRate = spawnRate;
    return settings;
}

+(CSMAstroidSettings)CSMAstroidSettingsMake:(CGRect)rect WithRotation:(CGFloat)rotation WithSpin:(CGFloat)spinRate{
    CSMAstroidSettings settings;
    settings.rect = rect;
    settings.rotation = rotation;
    settings.spinRate = spinRate;
    return settings;
}

+(CSMRocketSettings)CSMRocketSettingsMake:(CGPoint)position WithRot:(CGFloat)rotation{
    CSMRocketSettings settings;
    settings.position = position;
    settings.rotation = rotation;
    return settings;
}

+(CSMWormHoleSettings)CSMWormHoleSettingsMake:(CGPoint)position{
    CSMWormHoleSettings settings;
    settings.position = position;
    return settings;
}

@end
