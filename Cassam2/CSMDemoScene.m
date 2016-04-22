//
//  CSMDemoScene.m
//  Cassam
//
//  Created by The Cowans on 29/01/2015.
//  Copyright (c) 2015 RNC. All rights reserved.
//

#import "CSMDemoScene.h"
#import "CSMLevel.h"
#import "CSMGameData.h"
#import "CSMSpriteMove.h"
#import "CSMEnemySprite.h"
#import "CSMWormHoleSprite.h"
#import "Tools.h"
#import "SpinControlSprite.h"
#import "CSMHealthIndicator.h"
#import "CSMRocketSprite.h"
#import "ButtonSprite.h"
#import "CSMSpriteMove.h"

typedef enum : int {
    thumbRest = 0,
    thumbZoom,
    thumbSpin
} thumbAction;


#define targetEnemyPos1 CGPointMake(370, 270)
#define targetEnemyPos2 CGPointMake(60, 250)
#define enemyPos3 CGPointMake(-430, 170);
#define leftThumbRestPoint CGPointMake(-self.frame.size.width/2 - 100, -self.frame.size.height + 100)
#define rightThumbRestPoint CGPointMake(self.frame.size.width/2 + 100, -self.frame.size.height + 100)
#define progressBarPos CGPointMake(0, -self.frame.size.height/2 + 30)

@interface CSMDemoScene ()
@property SKSpriteNode* rightThumb;
@property SKSpriteNode* leftThumb;
@end

@implementation CSMDemoScene{
    
    CGPoint rocketTarget;
    BOOL bSpinTouched;
    CSMEnemySprite* targetEnemy;
    CSMEnemySprite* targetEnemy2;
    CSMEnemySprite* targetEnemy3;
    CSMWormHoleSprite* targetWormhole;
    
    BOOL bScaling;
    CGPoint lastltpos;
    CGPoint lastrtpos;
    thumbAction rtAction;
    
    CSMSpriteMove* rtMove;
    
    NSMutableArray* rightThumbActions;
    NSMutableArray* leftThumbActions;
    
    
    NSArray* touchThumbTextures;
    NSArray* thumbTextures;
    SKAction* touchAnimation;
    SKAction* thumbDownAnimation;
    SKAction* thumbUpAnimation;
    
    BOOL bRestLeftThumb;
    BOOL bRestRightThumb;
    
    CGPoint weypoint;
    BOOL bGotoWeypoint;
    
    SKSpriteNode* deviceImage;
    
    CSMSpriteMove* spritemove;
    CSMSpriteMove* spritemove2;
    int demoStage;
    
    CGPoint posSpinControl, posHealthIndicator, posFireControl, posThrustControl;
   // CSMHealthIndicator* progressBar;
    
    SKSpriteNode* progressBarFrame;
    SKSpriteNode* progressBarFill;
    
}

+(id)sceneWithSize:(CGSize)size gameData:(CSMGameData *)gData{
    CSMDemoScene* scene = [[CSMDemoScene alloc]initWithSize:size gameData:gData];
    return scene;
}

-(id)initWithSize:(CGSize)size gameData:(CSMGameData*)gData{
    if(self = [super initWithSize:size level:[gData getDemoLevel] gameData:gData]){
        self.name = @"Demoscene";
    }
    return self;
}

-(id)initWithSize:(CGSize)size gameData:(CSMGameData *)gData stage:(int)stage{
    if(self = [self initWithSize:size gameData:gData]){
        demoStage = stage;
    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    
    SKTexture *fforwardTexture = [SKTexture textureWithImageNamed:@"fforward.png"];
    ButtonSprite* fforwardControl = [[ButtonSprite alloc]initWithTexture: fforwardTexture scene:self type:kPlayFirstLevel];
    fforwardControl.position = topRightLabelPos;
    fforwardControl.userInteractionEnabled = YES;
    fforwardControl.alpha = 1.0;
    fforwardControl.zPosition = kIcon1zPos;
    fforwardControl.name = @"fforwardControl";
    [self addChild:fforwardControl];
    
    //progress indicator
    progressBarFrame = [SKSpriteNode spriteNodeWithImageNamed:@"progressBarFrame.png"];
    progressBarFrame.centerRect = CGRectMake(0.33, 0.0, 0.33, 1.0);
    progressBarFrame.xScale = 10;
    progressBarFrame.yScale = 0.7;
    progressBarFrame.zPosition = kIcon1zPos;
    progressBarFrame.position = progressBarPos;
    
    [self addChild:progressBarFrame];
    
    progressBarFill = [SKSpriteNode spriteNodeWithImageNamed:@"progressBarFill.png"];
    progressBarFill.centerRect = CGRectMake(0.33, 0.0, 0.33, 1.0);
    progressBarFill.anchorPoint = CGPointMake(0.0, 0.5);
    progressBarFill.zPosition = kIcon1zPos;
    
    progressBarFill.position = CGPointMake(-progressBarFrame.size.width/2, progressBarFrame.position.y);
    progressBarFill.xScale = 0.5;
    progressBarFill.yScale = 0.7;
    [self addChild:progressBarFill];
    
    progressBarFill.alpha = 0.01;
    progressBarFrame.alpha = 0.01;
    
    if(demoStage == 2){
        
        NSLog(@"10");
        
        progressBarFrame.alpha = 0.7;
        progressBarFill.alpha = 0.7;
        progressBarFill.xScale = 5;
        [progressBarFill runAction:[SKAction scaleXTo:10 duration:28]];
        
        [super prepareSceneForLoading];
        [super backgroundOnly];
        [self showDeviceImage];
        [self loadThumbs];
        
        
        [self runAction:
         [SKAction sequence:@[
                              [SKAction waitForDuration:2.5],//2.5
                              [SKAction runBlock:^{ [self loadLevelForDemo]; }],
                              [SKAction runBlock:^{ [self loadControls]; [self fadeinControls]; }],
                              [SKAction runBlock:^{ [self loadDemo2]; }]                              ]
          ]
         ];
   
    }
    
    else{
        
        SKAction* pausefade = [SKAction sequence:@[[SKAction waitForDuration:1.0],
                                                   [SKAction fadeAlphaTo:0.7 duration:1.0]]];
        
        [progressBarFill runAction:[SKAction group:@[[SKAction scaleXTo:5 duration:32],
                                                     pausefade]]];
        [progressBarFrame runAction:pausefade];
        
        [super prepareSceneForLoading];
        [super backgroundOnly];
        [self loadThumbs];
        
        [self loadControls];
        
        [self loadDemo];
    }
    
    
}


#pragma mark Demo Methods

-(void)update:(NSTimeInterval)currentTime{
    if(spritemove){
        spritemove.nde.position = [spritemove currentPointPos:currentTime];
        if(spritemove.complete)
            spritemove = nil;
    }
    if(spritemove2){
        spritemove2.nde.position = [spritemove2 currentPointPos:currentTime];
        if(spritemove2.complete)
            spritemove2 = nil;
    }
    
    [self demoControl:currentTime];
    [super update:currentTime];
}

-(void)loadThumbs{
    bRestRightThumb = NO;
    bRestLeftThumb = NO;
    
    thumbTextures = [self getSprites:@"thumbStraightAnimation.png" frames:5];
    thumbDownAnimation = [SKAction animateWithTextures:thumbTextures timePerFrame:animationFrameLength];
    thumbUpAnimation = [thumbDownAnimation reversedAction];
    
    
    touchThumbTextures = [self getSprites:@"touchPoint.png" frames:6];
    touchAnimation = [SKAction animateWithTextures:touchThumbTextures timePerFrame:animationFrameLength];
    
    
    
    
    self.rightThumb = [SKSpriteNode spriteNodeWithTexture:thumbTextures[0]];
    //self.rightThumb.xScale = -1;
    //self.rightThumb.centerRect = CGRectMake(0.0, 0.2, 1.0, 0.8);
    self.rightThumb.anchorPoint = CGPointMake(0.5, 0.65);
    self.rightThumb.zRotation = M_PI/4;
    self.rightThumb.zPosition = kTopPos;
    self.rightThumb.alpha = 0.3;
    
    self.leftThumb = [SKSpriteNode spriteNodeWithTexture:thumbTextures[0]];
    //self.leftThumb.centerRect = CGRectMake(0.0, 0.2, 1.0, 0.8);
    self.leftThumb.anchorPoint = CGPointMake(0.5, 0.65);
    self.leftThumb.zRotation = -M_PI/4;
    self.leftThumb.zPosition = kTopPos;
    self.leftThumb.alpha = 0.3;
    
    
    self.leftThumb.position = leftThumbRestPoint;
    self.rightThumb.position = rightThumbRestPoint;
    [self addChild:self.leftThumb];
    [self addChild:self.rightThumb];
    
    rightThumbActions = [NSMutableArray arrayWithCapacity:3];
    leftThumbActions = [NSMutableArray arrayWithCapacity:3];
    
    
    
}

-(void)showDeviceImage{
    if(super.bLargeScreen){
        deviceImage = [SKSpriteNode spriteNodeWithImageNamed:@"holdingipad.png"];
    }
    else{
        deviceImage = [SKSpriteNode spriteNodeWithImageNamed:@"holdingiphone.png"];
    }
    deviceImage.zPosition = kIcon1zPos;
    deviceImage.alpha = 0.0;
    //show device image
    [self addChild:deviceImage];
    [deviceImage runAction:[SKAction sequence:@[
                                                [SKAction waitForDuration:0.25],
                                                [SKAction fadeInWithDuration:0.25],
                                                [SKAction waitForDuration:1.75],
                                                [SKAction fadeOutWithDuration:0.25]
                                                ]]];
   
}

-(void)loadLevelForDemo{
    super.currentLevel = [super.gameData getDemoLevel];
    NSArray *sprites = [super.currentLevel getSprites];
    
    for(CSMSpriteNode* spriteRecord in sprites){
        if([spriteRecord.name isEqualToString:@"astroid"] || [spriteRecord.name isEqualToString:@"wormhole"]){
            
            CSMSpriteNode* sprite = [spriteRecord copy];
            [sprite setScene:self];
            [sprite providePhysicsBodyAndActions];
            [self.spriteHolder addChild:sprite];
            
            if([sprite.name isEqualToString:@"wormhole"])
                targetWormhole = (CSMWormHoleSprite*)sprite;
        }
        /*
         //register artilary
         if([sprite.name isEqualToString:@"enemyartilary"])
         [artilaryRegister addObject:sprite];
         */
        
        
    }
    
    //pick up all children
    
    for(CSMSpriteNode *sprite in [self.spriteHolder children]){
        if([sprite isKindOfClass:[CSMSpriteNode class]]){
            [sprite pickupChildren];
        }
    }
    
    
    //[self positionSpriteHolder];
    
    //[self rescaleScene:startScale];
    //self.spriteHolder.xScale = startScale;
    //self.spriteHolder.yScale = startScale;
    
}

-(void)loadDemo{
    //[self loadLevelForDemo];
    
    //targetEnemy
    /*
    targetEnemy = [[CSMEnemySprite alloc]initWithScene:self];
    targetEnemy.position = targetEnemyPos1;
    targetEnemy.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:targetEnemy];
    [targetEnemy providePhysicsBodyOnly];
    targetEnemy.physicsBody.velocity = CGVectorMake(0.0, 0.0);
     */
    
    
    //reveal rocket and spin control
    CGPoint spinControlTempPos = CGPointMake(150, 0);
    self.spinControl.position = spinControlTempPos; //for setting actions
    [leftThumbActions addObject:[SKAction runBlock:^{ self.spinControl.position = spinControlTempPos; }]];
    [leftThumbActions addObject:[SKAction runBlock:^ {bRestLeftThumb = YES; }]];
    [rightThumbActions addObject:[SKAction runBlock:^{ [self.rocket runAction:[SKAction fadeInWithDuration:0.7]]; }]];
    [rightThumbActions addObject:[SKAction waitForDuration:0.8]];
    [rightThumbActions addObject:[SKAction runBlock:^{ [self.spinControl runAction:[SKAction fadeInWithDuration:0.7]];  }]];
    [rightThumbActions addObject:[SKAction waitForDuration:0.8]];
    

    
    //demonstrate spin
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb to:CGPointMake( spinControlTempPos.x, spinControlTempPos.y+40) duration:1.0] ];
    [rightThumbActions addObject:[SKAction runBlock:^ {[self animateTouch:self.rightThumb]; }]];
    [rightThumbActions addObject:[SKAction runBlock:^ { [self setRtAction:thumbSpin]; }]];
    [rightThumbActions addObject:[SKAction waitForDuration:3.0]];
    [rightThumbActions addObject:[SKAction runBlock:^ { [self setRtAction:thumbRest]; }] ];
    [rightThumbActions addObject:[SKAction runBlock:^ { [self animateRelease:self.rightThumb];}]];
    [self spinTo:1.3 * M_PI];
    //[self spinTo:0.2 * M_PI];
    //[self spinTo:0.7 * M_PI];
    //[rightThumbActions addObject:[SKAction runBlock:^ {[self animateTouch:self.rightThumb]; }]];
    //[rightThumbActions addObject:[SKAction runBlock:^ { [self setRtAction:thumbSpin]; }]];
    //[rightThumbActions addObject:[SKAction waitForDuration:1.5]];
    //[rightThumbActions addObject:[SKAction runBlock:^ { [self setRtAction:thumbRest]; }] ];
    //[rightThumbActions addObject:[SKAction runBlock:^ { [self animateRelease:self.rightThumb]; }]];
    [self spinTo:0.0 * M_PI];
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb to:rightThumbRestPoint duration:1.5] ];
    
    /*
    //return spin control to corner
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb to:rightThumbRestPoint duration:1.5]];
    //[rightThumbActions addObject:[SKAction waitForDuration:0.7]];
    [rightThumbActions addObject:[SKAction runBlock:^{ spritemove = [[CSMSpriteMove alloc]initNode:self.spinControl to:posSpinControl duration:1.0];  }]];
    [rightThumbActions addObject:[SKAction waitForDuration:1.2]];
        
    self.spinControl.position = posSpinControl; //for setting actions
     */
     
    
    //release left thumb
    [rightThumbActions addObject:[SKAction runBlock:^ {bRestLeftThumb = NO; }]];
    [leftThumbActions addObject:[SKAction runBlock:^ {bRestRightThumb = YES; }]];
    
    //reveal thrust control
    CGPoint thrustControlTempPos = CGPointMake(-150, 0);
    self.thrustForwardControl.position = thrustControlTempPos;
    [leftThumbActions addObject:[SKAction runBlock:^{ [self.thrustForwardControl runAction:[SKAction fadeInWithDuration:0.7]]; }]];
    [leftThumbActions addObject:[SKAction waitForDuration:1.0]];
    
    //demonstrate thrust control
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb to:CGPointMake( thrustControlTempPos.x, thrustControlTempPos.y) duration:1.5] ];
    [self pressThrust:0.2];
    [leftThumbActions addObject:[SKAction waitForDuration:0.5]];
    [leftThumbActions addObject:[SKAction runBlock:^{bRestRightThumb = NO; }]];
    [leftThumbActions addObject:[SKAction runBlock:^{bRestLeftThumb = YES; }]];
    [self spinTo:M_PI];
    [rightThumbActions addObject:[SKAction runBlock:^{bRestLeftThumb = NO; }]];
    [self pressThrust: 0.4];
    [leftThumbActions addObject:[SKAction waitForDuration:1.5]];
    [rightThumbActions addObject:[SKAction waitForDuration:0.3]];
    [self spinTo:0.0];
    [self pressThrust: 0.2];
    [leftThumbActions addObject:[SKAction runBlock:^{ self.rocket.physicsBody.velocity = CGVectorMake(0.0, 0.0);  }]];
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb to:leftThumbRestPoint duration:1.0] ];
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb to:rightThumbRestPoint duration:1.0] ];
    
    //return thrust and spin controls to corners
    //[leftThumbActions addObject:[SKAction waitForDuration:0.4]];
    [rightThumbActions addObject:[SKAction waitForDuration:0.7]];
    //[rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb to:rightThumbRestPoint duration:1.5]];
    [rightThumbActions addObject:[SKAction runBlock:^{ spritemove = [[CSMSpriteMove alloc]initNode:self.spinControl to:posSpinControl duration:1.0];
        spritemove2 = [[CSMSpriteMove alloc]initNode:self.thrustForwardControl to:posThrustControl duration:1.0];}]];
    [rightThumbActions addObject:[SKAction runBlock:^{ bRestRightThumb = YES; }]];
    //[leftThumbActions addObject:[SKAction runBlock:^{ spritemove2 = [[CSMSpriteMove alloc]initNode:self.thrustForwardControl to:posThrustControl duration:1.0];  }]];
    [leftThumbActions addObject:[SKAction waitForDuration:1.2]];
    
    self.spinControl.position = posSpinControl; //for setting actions
    
    //reveal fire control
    CGPoint fireControlTempPos = CGPointMake(-150, 0);
    self.fireControl.position = fireControlTempPos;
    [leftThumbActions addObject:[SKAction runBlock:^{ [self.fireControl runAction:[SKAction fadeInWithDuration:0.7]];  }]];
    [leftThumbActions addObject:[SKAction waitForDuration:0.8]];
    
    //demonstrate fire control
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb to:fireControlTempPos duration:1.0] ];
    [self pressFire:0.7];
    [leftThumbActions addObject:[SKAction waitForDuration:0.5]];
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb to:leftThumbRestPoint duration:1.0] ];
    
    //return fire control to corner
    [leftThumbActions addObject:[SKAction waitForDuration:0.7]];
    [leftThumbActions addObject:[SKAction runBlock:^{ spritemove = [[CSMSpriteMove alloc]initNode:self.fireControl to:posFireControl duration:1.0];   }]];
    [leftThumbActions addObject:[SKAction waitForDuration:1.2]];
   
    
    //new scene for next stage of demo
    [leftThumbActions addObject:[SKAction runBlock:^{
        SKScene* nextScene = [[CSMDemoScene alloc]initWithSize:self.size gameData:self.gameData stage:2];
        SKTransition *fade = [SKTransition crossFadeWithDuration:0.5];
        [self.view presentScene:nextScene transition:fade];
    }]];
     
    
    
    //--------------------------------------
    
    
   
    
}

-(void)loadDemo2{
    
    //deactivate all controls
    self.spinControl.userInteractionEnabled = NO;
    self.thrustForwardControl.userInteractionEnabled = NO;
    self.fireControl.userInteractionEnabled = NO;
    
    //targetEnemies
    targetEnemy = [[CSMEnemySprite alloc]initWithScene:self];
    targetEnemy.position = targetEnemyPos1;
    targetEnemy.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:targetEnemy];
    [targetEnemy providePhysicsBodyOnly];
    //targetEnemy.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    [self addRockSpriteAction:targetEnemy];
    targetEnemy.rocketDirection = [Tools getAngleFrom:targetEnemy.position to:self.rocket.position];
    
    targetEnemy2 = [[CSMEnemySprite alloc]initWithScene:self];
    targetEnemy2.position = targetEnemyPos2;
    targetEnemy2.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:targetEnemy2];
    [targetEnemy2 providePhysicsBodyOnly];
    //targetEnemy2.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    [self addRockSpriteAction:targetEnemy2];
    targetEnemy2.rocketDirection = [Tools getAngleFrom:targetEnemy2.position to:self.rocket.position];
    //targetEnemy2.physicsBody.mass = 1000000;
    
    targetEnemy3 = [[CSMEnemySprite alloc]initWithScene:self];
    targetEnemy3.position = enemyPos3;
    targetEnemy3.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:targetEnemy3];
    [targetEnemy3 providePhysicsBodyOnly];
    //enemy3.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    [self addRockSpriteAction:targetEnemy3];
    targetEnemy3.rocketDirection = [Tools getAngleFrom:targetEnemy3.position to:self.rocket.position];
    
    
    
    
    //pause
    [rightThumbActions addObject:[SKAction waitForDuration:0.7]];
    [leftThumbActions addObject:[SKAction waitForDuration:0.7]];
    
    //zoom out
    if(self.bLargeScreen){
        [self demoZoom:0.6 setThumbs:YES];
    }
    else{
        [self demoZoom:0.35 setThumbs:YES];
    }
    [leftThumbActions addObject:[SKAction runBlock:^ {bRestRightThumb = YES; }]];
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb to:self.fireControl.position  duration:1.0] ];
    [leftThumbActions addObject:[SKAction runBlock:^ {
        bRestRightThumb = NO;
        bRestLeftThumb = YES;
        //[progressBar increaseHealthTo:0.6];
    }]];
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb to:self.spinControl.position  duration:1.0] ];
    
    
    //demonstrate aim of game
    SKSpriteNode* aimArrow = [[SKSpriteNode alloc]initWithImageNamed:@"ArrowLeft.png"];
    aimArrow.zPosition = kIcon1zPos;
    aimArrow.alpha = 0.0;
    aimArrow.xScale = 3.0;
    aimArrow.yScale = 3.0;
    [rightThumbActions addObject:[SKAction runBlock:^{
        CGFloat dir = [Tools getAngleFrom:self.rocket.position to:targetWormhole.position];
        //CGFloat distToHole = [Tools getDistanceBetween:self.rocket.position and:targetWormhole.position];
        CGPoint arrowDestination = CGPointMake(
                                               targetWormhole.position.x + (80 * sinf(dir)),
                                               targetWormhole.position.y + (80 * -cosf(dir))
                                               );
        //CGFloat arrowStepDist = distToHole / 4;
        aimArrow.position = CGPointMake(
                                        self.rocket.position.x + (80 * -sinf(dir)),
                                        self.rocket.position.y + (80 * cosf(dir))
                                        );
        aimArrow.zRotation = dir - M_PI/2;
        [self.spriteHolder addChild:aimArrow];
        
        [aimArrow runAction:[SKAction sequence:@[
                                                 [SKAction repeatAction: [SKAction sequence:@[
                                                                                              [SKAction fadeAlphaTo:1.0 duration:0.5],
                                                                                              [SKAction fadeAlphaTo:0.3 duration: 0.5]
                                                                                              ]]
                                                                  count:16],
                                                 [SKAction fadeAlphaTo:0.0 duration: 0.5]
                                                 ]]];
        
        spritemove = [[CSMSpriteMove alloc]initNode:aimArrow to:arrowDestination duration:3.0];
    }]];
    [rightThumbActions addObject:[SKAction waitForDuration:4.0]];
    
    
    //point to enemy
    //this only works if nothing has moved
    //first enemy
    [self spinTo:[Tools getAngleFrom:self.rocket.position to:targetEnemy.position]];
    [rightThumbActions addObject:[SKAction runBlock:^{
        bRestRightThumb = YES;
        bRestLeftThumb = NO;
    }]];
    [self pressFire:0.5];
    //second enemy
    [leftThumbActions addObject:[SKAction runBlock:^ {
        bRestRightThumb = NO;
        bRestLeftThumb = YES;
    }]];
    [self spinTo:[Tools getAngleFrom:self.rocket.position to:targetEnemy2.position]];
    [rightThumbActions addObject:[SKAction runBlock:^{
        bRestRightThumb = YES;
        bRestLeftThumb = NO;
    }]];
    [self pressFire:0.5];
    
    
    //thrust
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb to:self.thrustForwardControl.position duration:1.0]];
    [leftThumbActions addObject:[SKAction runBlock:^{
                                     bRestRightThumb = NO;
                                     bRestLeftThumb = YES;
                                 }]];
    [self spinTo:[Tools getAngleFrom:self.rocket.position to:targetWormhole.position]];
    [rightThumbActions addObject:[SKAction runBlock:^{
                                      bRestRightThumb = YES;
                                      bRestLeftThumb = NO;
                                  }]];
    [self pressThrust:0.8];

}

-(void)addRockSpriteAction:(SKSpriteNode*)sprite{
    CGFloat angleToRocket = [Tools getAngleFrom:sprite.position to:self.rocket.position];
    SKAction* action = [SKAction sequence:@[
                                            [SKAction waitForDuration:((float)rand() / RAND_MAX)],
                                            [SKAction repeatActionForever:
                                             [SKAction sequence:@[
                                                                  [SKAction moveTo:CGPointMake(
                                                                                               sprite.position.x + (10 * sinf(angleToRocket)),
                                                                                               sprite.position.y + (10 * -cosf(angleToRocket)))
                                                                          duration:0.5],
                                                                  [SKAction moveTo:sprite.position duration:0.5]
                                                                  ]]
                                             ]]];
    [sprite runAction:action];
}

-(void)loadControls{
    [super loadControls];
    [super placeRocket:CGPointMake(0.0, 0.0)];
    [super rescaleScene:1.0]; //to ensure scrollbox is set for scrolling
    //deactivate all controls
    self.spinControl.userInteractionEnabled = NO;
    self.thrustForwardControl.userInteractionEnabled = NO;
    self.fireControl.userInteractionEnabled = NO;
    
    //hide
    self.spinControl.alpha = 0.0;
    self.thrustForwardControl.alpha = 0.0;
    self.fireControl.alpha = 0.0;
    //self.healthIndicator.alpha = 0.0;
    [self.healthIndicator removeFromParent];
    self.rocket.alpha = 0.0;
    
    if(self.bLargeScreen){
        posSpinControl = spinControlPos2;
        posThrustControl = thrustForwardPos2;
        posFireControl = fireButtonPos2;
        posHealthIndicator = healthIndicatorPos2;
        self.healthIndicator.position = posHealthIndicator;
    }
    else{
        posSpinControl = spinControlPos;
        posThrustControl = thrustForwardPos;
        posFireControl = fireButtonPos;
        posHealthIndicator = healthIndicatorPos;
        self.healthIndicator.position = posHealthIndicator;
    }
}

-(void)fadeinControls{
    SKAction* fadein = [SKAction fadeAlphaTo:kControlAlpha duration:1.5];
    [self.spinControl runAction:fadein];
    [self.thrustForwardControl runAction:fadein];
    [self.fireControl runAction:fadein];
    //[self.healthIndicator runAction:fadein];
    [self.rocket runAction:fadein];
}

-(void)demoSpin{
    
    [self runAction:[SKAction sequence:@[
                                         [SKAction runBlock:^{ spritemove = [[CSMSpriteMove alloc]initNode:self.spinControl to:CGPointMake(150, 0) duration:1.0];  }],
                                         [SKAction waitForDuration:1.5],
                                         
                                         [SKAction runBlock:^{ spritemove = [[CSMSpriteMove alloc]initNode:self.spinControl to:spinControlPos duration:1.0];  }],
                                         ]]];
    
                                                            
        
                                                            
                                                            /*
        [rightThumbActions addObject:[SKAction runBlock:^ { [self setRtAction:thumbSpin]; }]];
        
    }],
                                         [SKAction waitForDuration:3.0],
                                         [SKAction runBlock:^{
        [rightThumbActions addObject:[SKAction runBlock:^
                                      {
                                          [self setRtAction:thumbRest];
                                          NSLog(@"thumbrest");
                                      }]
         ];
        
        [rightThumbActions addObject:[SKAction runBlock:^
                                       {
                                           [self animateRelease:self.rightThumb];
                                       }]
          ];
    }],
                                         
                                         
                                         //touch spinner
                                         [SKAction runBlock:^{
        [self spinTo:1.3 * M_PI];
    }],
                                         [SKAction runBlock:^{
        [self spinTo:0.2 * M_PI];
    }],
                                         [SKAction runBlock:^{
        [self spinTo:10.7* M_PI];
    }]
                                         
                                         
                                         ]]];
    
    
    */
    
    
}

-(void)demoControl:(CFTimeInterval)currentTime{
    /*
     static int tic = 0;
     tic++;
     if(tic % 30 == 0){
     NSLog(@"enemy vel:%f, %f", targetEnemy.physicsBody.velocity.dx, targetEnemy.physicsBody.velocity.dy);
     NSLog(@"gravity: %f, %f", self.physicsWorld.gravity.dx, self.physicsWorld.gravity.dy);
     }
     */
    
    //NSLog(@"target = %f", self.spinControl.target);
    
    /*
    if(targetEnemy)
        targetEnemy.position = targetEnemyPos1;
    if(targetEnemy2)
        targetEnemy2.position = targetEnemyPos2;
    */
    
    if(![self.rightThumb hasActions] && (!bRestRightThumb)){
        if([rightThumbActions count]){
            if([[rightThumbActions objectAtIndex:0]isKindOfClass:[CSMSpriteMove class]]){
                CSMSpriteMove* move = (CSMSpriteMove*)[rightThumbActions objectAtIndex:0];
                self.rightThumb.position = [move currentPointPos:currentTime];
                if(move.complete)
                    [rightThumbActions removeObjectAtIndex:0];
            }
            else if ([[rightThumbActions objectAtIndex:0]isKindOfClass:[SKAction class]]){
                [self.rightThumb runAction:[rightThumbActions objectAtIndex:0]];
                [rightThumbActions removeObjectAtIndex:0];
            }
            else{
                NSLog(@"unrecognised action for rightThumb");
            }
        }
    }
    
    if(![self.leftThumb hasActions] && (!bRestLeftThumb)){
        if([leftThumbActions count]){
            if([[leftThumbActions objectAtIndex:0]isKindOfClass:[CSMSpriteMove class]]){
                CSMSpriteMove* move = (CSMSpriteMove*)[leftThumbActions objectAtIndex:0];
                self.leftThumb.position = [move currentPointPos:currentTime];
                if(move.complete)
                    [leftThumbActions removeObjectAtIndex:0];
            }
            else if ([[leftThumbActions objectAtIndex:0]isKindOfClass:[SKAction class]]){
                [self.leftThumb runAction:[leftThumbActions objectAtIndex:0]];
                [leftThumbActions removeObjectAtIndex:0];
            }
            else{
                NSLog(@"unrecognised action for leftThumb");
            }
        }
    }
    
    //self.rightThumb.position = [rtMove currentPos:currentTime];
    
    
    targetEnemy.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    targetEnemy2.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    targetEnemy3.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    
    static CFTimeInterval lastUpdateTime = 0;
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTime;
    lastUpdateTime = currentTime;
    
    //static CGFloat totalTurn = 0.0;
    //static BOOL reverse = NO;
    
    if(bSpinTouched){
        self.spinControl.target = [Tools getAngleFrom:self.spinControl.position to:self.rightThumb.position];
        //bSpinTouched = NO;
    }
    
    if( rtAction == thumbSpin ){//&& (totalTurn < (2*M_PI))){
        static CGFloat timeToSpin = 1.7;
        CGFloat angleStep =  2* M_PI / (  timeToSpin / timeSinceLast);
        //totalTurn += angleStep;
        CGFloat newAngle = self.rocket.zRotation + angleStep;
        self.spinControl.target = newAngle;
        //NSLog(@"angleStep:%f, newAngle:%f",  angleStep/M_PI, newAngle/M_PI);
        self.spinControl.zRotation = newAngle;
        //self.rocket.zRotation = newAngle;
        CGFloat radius = 40;
        
        CGPoint spinPoint = CGPointMake(
                                        radius * sinf(newAngle),
                                        radius * cosf(newAngle)
                                        );
        
        CGPoint touchPoint = CGPointMake(
                                         - spinPoint.x + self.spinControl.position.x,
                                         spinPoint.y + self.spinControl.position.y
                                         );
        self.rightThumb.position = touchPoint;
        //NSLog(@"thumbpos:%f, %f", self.rightThumb.position.x, self.rightThumb.position.y);
        //bSpinTouched = YES;
        
    }
    
    static BOOL timeToThrust = YES;
    static CFTimeInterval wpLastUpdateTime = 0;
    
    if(bGotoWeypoint){
        CFTimeInterval wpTimeSinceLast = currentTime - wpLastUpdateTime;
        
        if(wpTimeSinceLast > 0.5){
            wpLastUpdateTime = currentTime;
            if(timeToThrust){
                timeToThrust = NO;
                
                CGFloat targetDir = [Tools getAngleFrom:self.rocket.position to:weypoint];
                [self spinTo:targetDir];
                
                //targetdX
                CGFloat targetDx = (self.rocket.position.x - weypoint.x) / 50.0;
                CGFloat targetDy = (self.rocket.position.y - weypoint.y) / 50.0;
                
                if( (self.rocket.physicsBody.velocity.dx < targetDx) || (self.rocket.physicsBody.velocity.dy < targetDy) ){
                    
                    [self pressThrust:0.7];
                }
            }
            else{
                timeToThrust = YES;
            }
            
        }
    }
    
    if(bScaling){
        [self simulatedTouchesMoved];
    }
    
}

-(void)setRtAction:(int)newAction{
    rtAction = newAction;
}

-(void)demoZoom:(CGFloat)scaleChange setThumbs:(BOOL)set{
    
    //calculate move required
    
    //CGFloat scaleChange = newScale / self.spriteHolder.xScale;
    //NSLog(@"scalechange: %f", scaleChange);
    CGFloat startThumbSpace = 0.0;
    
    if(scaleChange < 1)
        startThumbSpace = 260;
    else
        startThumbSpace = 135;
    
    CGFloat newThumbSpace = startThumbSpace * scaleChange;
    
    if(set){
        //get thumbs to start point
        [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb
                                                                 to:CGPointMake(startThumbSpace/2, 0)
                                                           duration:1.0]
         ];
        
        
        //move left thumb right
        [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb
                                                                to:CGPointMake(-startThumbSpace/2, 0)
                                                          duration:1.0]
         ];
    }
    
    
    //touch
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self animateTouch:self.rightThumb];
                                  }]];
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     [self animateTouch:self.leftThumb];
                                 }]];
    
    
    //start zoom response
    [rightThumbActions addObject:[SKAction performSelector:@selector(startZoom) onTarget:self]];
    
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb
                                                             to:CGPointMake(newThumbSpace/2, 0)
                                                       duration:1.0]
     ];
    
    
    //move left thumb right
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb
                                                            to:CGPointMake(-newThumbSpace/2, 0)
                                                      duration:1.0]
     ];
    
    //end zoom response
    
    [rightThumbActions addObject:[SKAction performSelector:@selector(endZoom) onTarget:self]];
    
    //lift thumbs
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self animateRelease:self.rightThumb];
                                  }]];
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     [self animateRelease:self.leftThumb];
                                 }]];
    
}

-(void)startZoom{
    lastrtpos = self.rightThumb.position;
    lastltpos = self.leftThumb.position;
    bScaling = YES;
}

-(void)endZoom{
    bScaling = NO;
}

-(void)simulatedTouchesMoved{
    
    CGFloat startPinch = [Tools getDistanceBetween:lastltpos and:lastrtpos];
    CGFloat endPinch = [Tools getDistanceBetween:self.rightThumb.position and:self.leftThumb.position];
    CGFloat scaleChange = endPinch / startPinch;
    lastrtpos = self.rightThumb.position;
    lastltpos = self.leftThumb.position;
    CGFloat newScale = self.spriteHolder.xScale * scaleChange;
    [self rescaleScene:newScale];
    
}

-(void)prepareActions{
    
}

-(void)spinTo:(CGFloat)targetAngle{
    //NSLog(@"spinTo:%f", targetAngle/M_PI);
    //calculate position
    //targetAngle = 0.75 * M_PI;
    //self.spinControl.target = targetAngle;
    CGFloat radius = 40;
    
    CGPoint spinPoint = CGPointMake(
                                    radius * sinf(targetAngle),
                                    radius * cosf(targetAngle)
                                    );
    
    CGPoint touchPoint = CGPointMake(
                                     - spinPoint.x + self.spinControl.position.x,
                                     spinPoint.y + self.spinControl.position.y
                                     );
    
    //SKAction* moveToPosition = [SKAction moveTo:touchPoint duration:0.3];
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb
                                                             to:touchPoint
                                                       duration:0.5]
     ];
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self animateTouch:self.rightThumb];
                                  }]];
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      bSpinTouched = YES;
                                  }]];
    [rightThumbActions addObject:[SKAction waitForDuration:0.4]];
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self animateRelease:self.rightThumb];
                                      bSpinTouched = NO;
                                  }]];
    /*
     
     SKAction* touch = [SKAction runBlock:^
     {
     [self animateTouch:self.rightThumb];
     bSpinTouched = YES;
     }];
     
     //SKAction* instruct = [SKAction performSelector:@selector(thrustOn) onTarget:self];
     SKAction* seq = [SKAction sequence:@[moveToPosition, touch]];
     
     [self.rightThumb runAction:seq];
     */
    //[self.spinControl spin:spinPoint];
}

-(void)pressThrust:(CGFloat)duration{
    
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     [self animateTouch:self.leftThumb];
                                 }]];
    [leftThumbActions addObject:[SKAction performSelector:@selector(thrustOn) onTarget:self]];
    [leftThumbActions addObject:[SKAction waitForDuration:duration]];
    [leftThumbActions addObject:[SKAction performSelector:@selector(thrustOff) onTarget:self]];
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     [self animateRelease:self.leftThumb];
                                 }]];
}

-(void)pressThrust{
    //NSLog(@"pressThurst");
    SKAction* moveToThrustButton = [SKAction moveTo:self.thrustForwardControl.position duration:0.2];
    
    SKAction* touch = [SKAction runBlock:^
                       {
                           [self animateTouch:self.leftThumb];
                       }];
    
    SKAction* instruct = [SKAction performSelector:@selector(thrustOn) onTarget:self];
    SKAction* seq = [SKAction sequence:@[moveToThrustButton, touch, instruct]];
    [self.leftThumb runAction:seq];
    
    
}

-(void)pressFire{
    //NSLog(@"pressThurst");
    SKAction* moveToFireButton = [SKAction moveTo:self.fireControl.position duration:0.2];
    
    SKAction* touch = [SKAction runBlock:^
                       {
                           [self animateTouch:self.leftThumb];
                       }];
    
    SKAction* instruct = [SKAction performSelector:@selector(fireOn) onTarget:self];
    SKAction* seq = [SKAction sequence:@[moveToFireButton, touch, instruct]];
    [self.leftThumb runAction:seq];
}

-(void)pressFire:(CGFloat)duration{
    
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     [self animateTouch:self.leftThumb];
                                 }]];
    [leftThumbActions addObject:[SKAction performSelector:@selector(fireOn) onTarget:self]];
    [leftThumbActions addObject:[SKAction waitForDuration:duration]];
    [leftThumbActions addObject:[SKAction performSelector:@selector(fireOff) onTarget:self]];
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     [self animateRelease:self.leftThumb];
                                 }]];
    
    /*
     SKAction* pause = [SKAction waitForDuration:duration];
     SKAction* startFire = [SKAction performSelector:@selector(pressFire) onTarget:self];
     SKAction* stopFire = [SKAction performSelector:@selector(releaseFire) onTarget:self];
     SKAction* seq = [SKAction sequence:@[startFire, pause, stopFire]];
     [self runAction:seq];
     */
}

-(void)fireOn{
    self.rocket.bFire = YES;
}

-(void)fireOff{
    self.rocket.bFire = NO;
}

-(void)releaseFire{
    //NSLog(@"releaseThrust");
    SKAction* liftTouch = [SKAction runBlock:^
                           {
                               [self animateRelease:self.leftThumb];
                           }];
    SKAction* instruct = [SKAction performSelector:@selector(fireOff) onTarget:self];
    SKAction* seq = [SKAction sequence:@[liftTouch, instruct]];
    [self.leftThumb runAction:seq];
}

-(void)releaseThrust{
    //NSLog(@"releaseThrust");
    SKAction* liftTouch = [SKAction runBlock:^
                           {
                               [self animateRelease:self.leftThumb];
                           }];
    SKAction* instruct = [SKAction performSelector:@selector(thrustOff) onTarget:self];
    SKAction* seq = [SKAction sequence:@[liftTouch, instruct]];
    [self.leftThumb runAction:seq];
    
    
    //self.rocket.bThrustForward = NO;
    //[self stopThrustAnimation:YES];
}

-(void)thrustOn{
    if(self.rocket.bThrustForward == NO){
        [self animateThrust:YES];
        self.rocket.bThrustForward = YES;
    }
}

-(void)animateTouch:(SKSpriteNode*)sprite{
    SKAction* touch = [SKAction fadeInWithDuration:0.5];
    
    
    SKSpriteNode* touchSprite = [SKSpriteNode spriteNodeWithTexture:touchThumbTextures[0]];
    //[sprite addChild:touchSprite];
    touchSprite.alpha = 0.7;
    
    [sprite runAction:[SKAction sequence:@[
                                           [SKAction group:@[touch, thumbDownAnimation]],
                                           [SKAction runBlock:^{
        [sprite addChild:touchSprite];
        [touchSprite runAction:touchAnimation];
    }]
                                           ]]];
    
}

-(void)animateRelease:(SKSpriteNode*)sprite{
    SKAction* release = [SKAction fadeAlphaTo:0.3 duration:0.5];
    [sprite runAction:[SKAction group:@[release, thumbUpAnimation]]];
    [sprite removeAllChildren];
}

-(void)thrustOff{
    if(self.rocket.bThrustForward == YES){
        [self stopThrustAnimation:YES];
        self.rocket.bThrustForward = NO;
    }
}


-(void)levelCompleted:(CGPoint)location{
    
    self.gameData.demoWatched = YES;
    
    //spin rocket out -------------------------------------------------------------------------------
    self.rocket.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    
    SKSpriteNode* rocketAvatar = [[SKSpriteNode alloc]initWithImageNamed:@"rocket2.0.png"];
    rocketAvatar.position = CGPointMake(self.rocket.position.x, self.rocket.position.y);
    rocketAvatar.zRotation = self.rocket.zRotation;
    rocketAvatar.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:rocketAvatar];
    
    SKAction* move = [SKAction moveTo:location duration:0.3];
    SKAction* spin = [SKAction rotateByAngle:M_PI*6 duration:3.0];
    SKAction* vanish = [SKAction scaleTo:0.0 duration:3.0];
    //SKAction* remove = [SKAction removeFromParent];
    
    SKAction* group = [SKAction group:@[move, spin, vanish]];
    //SKAction* sequence = [SKAction sequence:@[group, remove]];
    //[rocketAvatar runAction:sequence];
    [rocketAvatar runAction:group completion:^{
        [rocketAvatar removeFromParent];
    }];
    [self.rocket removeFromParent];

    
    //level complete display -----------------------------------------------------------------------
    
    //drop level number so next level is level 1
    [self.currentLevel setLevelNumber:0];
    
    CGPoint tickPos = CGPointMake(-30, 0);
    
    
    CGPoint menuButtonPos = CGPointMake(55, -45);//(10, -45);
    CGPoint playButtonPos = CGPointMake(100, -45);//(45, -10);
    CGPoint replayButtonPos = CGPointMake(100, 0);
    
    SKSpriteNode* levelCompleteDisplay = [[SKSpriteNode alloc] initWithColor:[[SKColor alloc]initWithWhite:1.0 alpha:0.5]
                                                                        size:CGSizeMake(250, 150)];
    /*
     SKSpriteNode* levelCompleteDisplay = [[SKSpriteNode alloc] initWithColor:[[SKColor alloc]initWithWhite:1.0 alpha:0.7]                                                                        size:CGSizeMake(self.frame.size.width, self.frame.size.height + 60)];
     */
    levelCompleteDisplay.position = CGPointMake(0, 30);
    levelCompleteDisplay.zPosition = kIcon1zPos;
    
    ButtonSprite *tick = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"bigtick.png"]
                                                        scene:self
                                                         type:kPlayFirstLevel];
    //SKSpriteNode* tick = [SKSpriteNode spriteNodeWithImageNamed:@"bigtick.png"];
    //tick.position = tickPos;
    
    
    
    ButtonSprite* playButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconPlay.png"]
                                                              scene:self
                                                               type:kPlayFirstLevel];
    ButtonSprite* menuButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconMenu.png"]
                                                              scene:self
                                                               type:kLevelMenu];
    ButtonSprite* replayButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconReplay.png"]
                                                                scene:self
                                                                 type:kPlayDemo];
    playButton.position = playButtonPos;
    menuButton.position = menuButtonPos;
    replayButton.position = replayButtonPos;
    menuButton.xScale = 0.8;
    menuButton.yScale = 0.8;
    
    
    [levelCompleteDisplay addChild:tick];
    [levelCompleteDisplay addChild:menuButton];
    [levelCompleteDisplay addChild:playButton];
    [levelCompleteDisplay addChild:replayButton];
    
    
    SKAction* zoom = [SKAction scaleTo:1.0 duration:0.5];
    levelCompleteDisplay.xScale = 0.05;
    levelCompleteDisplay.yScale = 0.05;
    [self addChild:levelCompleteDisplay];
    [levelCompleteDisplay runAction:zoom];
    
    
    tick.position = tickPos;
    [self.backControl runAction:[SKAction fadeOutWithDuration:0.7]];
    
    
}



@end
