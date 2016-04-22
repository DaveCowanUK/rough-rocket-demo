//
//  CSMTestScene.m
//  Cassam2
//
//  Created by The Cowans on 25/10/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMTestScene.h"
#import <AVFoundation/AVFoundation.h>
#import "CSMGamePlayScene.h"
#import "CSMMenuScene.h"
#import "CSMLevel.h"
#import "CSMLevelsLibrary.h"
#import "CSMAstroidSprite.h"
#import "CSMEnemySpawnPoint.h"
#import "CSMWormHoleSprite.h"
#import "SpinControlSprite.h"
#import "ButtonSprite.h"
#import "CSMRocketSprite.h"
#import "CSMEnemySprite.h"
#import "Tools.h"
#import "CSMSpriteNode.h"
#import "CSMNodeSprite.h"
#import "CSMHealthIndicator.h"
#import "CSMEnemyArtilary.h"
#import "CSMEnemyEgg.h"
#import "CSMSolidObject.h"
#import "CSMGameData.h"
#import "CSMSpriteMove.h"


typedef enum : int {
    thumbRest = 0,
    thumbZoom,
    thumbSpin
} thumbAction;

#define targetEnemyPos CGPointMake(-350, 200)

@interface CSMTestScene () <SKPhysicsContactDelegate>
@property BOOL contentCreated;
@property CSMLevel* currentLevel;
@property CSMLevelsLibrary* levelsLibrary;
@property CSMGameData* gameData;
@property int score;
@property (nonatomic) NSArray *explosionTextures;
@property (nonatomic) NSArray *smallExplosionTextures;
@property (nonatomic) SKAction *explosionAnimation;
@property (nonatomic) SKAction *smallExplosionAnimation;
@property SKSpriteNode* rightThumb;
@property SKSpriteNode* leftThumb;
@end


@implementation CSMTestScene{
    
    Tools* tools;
    /*
     uint32_t bulletCategory ;
     uint32_t rocketCategory;
     uint32_t enemyCategory;
     uint32_t spriteHolderCategory;
     uint32_t edgeCategory;
     uint32_t astroidCategory;
     */
    struct scrollArea{
        CGFloat minX;
        CGFloat maxX;
        CGFloat minY;
        CGFloat maxY;
    };
    struct scrollArea scrollBoxTemplate;
    struct scrollArea scrollBoxScaled;
    CGFloat scaledMargin;
    CGPoint pinchTouches [4];
    //SKNode *spriteHolder;
    
    CGPoint lastRocketPosition;
    CSMHealthIndicator* healthIndicator;
    BOOL bNeedToScalePhysicsBodies;
    NSMutableArray* artilaryRegister;
    
    NSMutableArray* explosionActionSounds;
    NSMutableArray* splashActionSounds;
    NSMutableArray* explosionSounds;
    NSMutableArray* smallExplosionSounds;
    AVAudioPlayer* explosionPlayer;
    
    SKAction* shotSound;
    
    SKAction* thrustSound;
    BOOL soundingThrust;
    
    CGPoint rocketTarget;
    BOOL bSpinTouched;
    CSMEnemySprite* targetEnemy;
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
    
}

#pragma mark ============================= startup ===============================

+(id)sceneWithSize:(CGSize)size library:(CSMLevelsLibrary *)library level:(CSMLevel *)level{
    CSMTestScene* scene = [[CSMTestScene alloc]initWithSize:size library:library level:level];
    return scene;
}

+(id)sceneWithSize:(CGSize)size gameData:(CSMGameData *)gData{
    CSMTestScene* scene = [[CSMTestScene alloc]initWithSize:size level:nil gameData:gData];
    return scene;
}

-(id)initWithSize:(CGSize)size
{
    
    if (self = [super initWithSize:size])
    {
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        NSString *reqSysVer = @"7.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            bNeedToScalePhysicsBodies = NO;
        else
            bNeedToScalePhysicsBodies = YES;
        
    }
    return self;
}

-(id)initWithSize:(CGSize)size library:(CSMLevelsLibrary *)library level:(CSMLevel *)level{
    if (self = [self initWithSize:size]){
        self.currentLevel = level;
        self.levelsLibrary = library;
        artilaryRegister = [NSMutableArray arrayWithCapacity:5];
    }
    self.name = @"Testscene";
    return self;
}

-(id)initWithSize:(CGSize)size level:(CSMLevel *)level gameData:(CSMGameData*)gData{
    if(self = [self initWithSize:size library:nil level:level]){
        self.gameData = gData;
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
    
}

- (void)createSceneContents
{
    [super createSceneContents];
    
    self.backControl.hidden = YES;
    
    /*
    SKSpriteNode *rocketImage = [SKSpriteNode spriteNodeWithImageNamed:@"rocket2.0.png"];
    rocketImage.position = CGPointMake(0.0, 0.0);
    rocketImage.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:rocketImage];
    */
    
    /*
    [self loadSounds];
    
    self.enemyTexture = [SKTexture textureWithImageNamed:@"enemy1.png"];
    
    self.anchorPoint = CGPointMake (0.5,0.5);
    
    tools = [[Tools alloc]init];
    
    //create scrollbox to stop scrolling at edges of field
    scrollBoxTemplate.minX = self.size.width/2 - tools.kFieldSize.width/2 - kgameplaymargin;
    scrollBoxTemplate.maxX = tools.kFieldSize.width/2 - self.size.width/2 + kgameplaymargin;
    scrollBoxTemplate.minY = self.size.height/2 - tools.kFieldSize.height/2 - kgameplaymargin;
    scrollBoxTemplate.maxY = tools.kFieldSize.height/2 - self.size.height/2 + kgameplaymargin;
    
    //NSLog(@"scrollBox: %f, %f, %f, %f", scrollBox.minX, scrollBox.maxX, scrollBox.minY, scrollBox.maxY);
    
    
    //add edge
    self.spriteHolder.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.boundary];
    
    self.spriteHolder.xScale = startScale;
    self.spriteHolder.yScale = startScale;
    
    //[self addChild:self.spriteHolder];
    
    
    
    //load and position burning fuel
    self.rocketBurnTextures = [self getSprites:@"rocketFlare.png" frames:3];
    self.fuelBurnAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:self.rocketBurnTextures timePerFrame:animationFrameLength]];
    self.rocketBurnSprites = [NSArray arrayWithObjects:
                              [[SKSpriteNode alloc] initWithTexture:self.rocketBurnTextures[0]],
                              [[SKSpriteNode alloc] initWithTexture:self.rocketBurnTextures[0]],
                              [[SKSpriteNode alloc] initWithTexture:self.rocketBurnTextures[0]],
                              [[SKSpriteNode alloc] initWithTexture:self.rocketBurnTextures[0]],
                              nil];
    SKSpriteNode* rfBurn = (SKSpriteNode*) self.rocketBurnSprites[0];//
    rfBurn.position = rfburnPos;// setPosition:rfburnPos];
    SKSpriteNode* lfBurn = (SKSpriteNode*) self.rocketBurnSprites[1];//
    lfBurn.position = lfburnPos;
    //[self.rocketBurnSprites[1] setPosition:lfburnPos];
    //[self.rocketBurnSprites[2] setPosition:rrburnPos];
    //[self.rocketBurnSprites[3] setPosition:lrburnPos];
    
    [self.rocketBurnSprites[2] setZRotation:M_PI];
    [self.rocketBurnSprites[3] setZRotation:M_PI];
    
    for(int i=0; i<self.rocketBurnSprites.count; i++)
        [self.rocketBurnSprites[i] setZPosition:0.0];
    
    //load explosion animation
    self.explosionTextures = [self getSprites:@"explosion1.png" frames:6];
    
    self.explosionAnimation = [SKAction animateWithTextures:self.explosionTextures timePerFrame:animationFrameLength];
    
    
    
    self.smallExplosionTextures = [self getSprites:@"explosion2.png" frames:6];
    
    self.smallExplosionAnimation = [SKAction animateWithTextures:self.smallExplosionTextures timePerFrame:animationFrameLength];
    
    
    //add hud
    self.hud = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    self.hud.fontSize = 20;
    self.hud.fontColor = [UIColor iconBlue];
    self.hud.position = label1Pos;
    self.hud.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.hud.zPosition = kIcon1zPos;
    [self addChild:self.hud];
    
    
    //add controls
    SKTexture *spinControlTexture = [SKTexture textureWithImageNamed:@"rocketControl2.0.png"];
    self.spinControl = [[SpinControlSprite alloc]initWithTexture: spinControlTexture];
    self.spinControl.position = spinControlPos;
    self.spinControl.userInteractionEnabled = YES;
    self.spinControl.zPosition = kIcon1zPos;
    self.spinControl.alpha = kControlAlpha;
    [self addChild:self.spinControl];
    
    //health indicator
    healthIndicator = [[CSMHealthIndicator alloc]init];
    healthIndicator.position = healthIndicatorPos;
    healthIndicator.zPosition = kIcon1zPos;
    healthIndicator.alpha = kControlAlpha;
    [healthIndicator prepareAnimationforTest:self];
    [self addChild:healthIndicator];
    
    
    
    
    SKTexture *thrustForwardControlTexture = [SKTexture textureWithImageNamed:@"thrustForward.png"];
    self.thrustForwardControl = [[ButtonSprite alloc]initWithTexture: thrustForwardControlTexture scene:self type:kThrustForward];
    self.thrustForwardControl.position = thrustForwardPos;
    self.thrustForwardControl.userInteractionEnabled = YES;
    self.thrustForwardControl.zPosition = kIcon1zPos;
    self.thrustForwardControl.alpha = kControlAlpha;
    [self addChild:self.thrustForwardControl];
    
   
    
    SKTexture *fireControlTexture = [SKTexture textureWithImageNamed:@"fireControl2.0.png"];
    self.fireControl = [[ButtonSprite alloc]initWithTexture: fireControlTexture scene:self type:kFire];
    self.fireControl.position = fireButtonPos;
    self.fireControl.userInteractionEnabled = YES;
    self.fireControl.zPosition = kIcon1zPos;
    self.fireControl.alpha = kControlAlpha;
    [self addChild:self.fireControl];
    
    
    self.spriteHolder.physicsBody.categoryBitMask = categorySpriteHolder;//spriteHolderCategory;
    self.spriteHolder.physicsBody.contactTestBitMask = spriteHolderCollisions;
    
    //set control positions for larger screen
    if(self.frame.size.height > 700){
        self.spinControl.position = spinControlPos2;
        self.thrustForwardControl.position = thrustForwardPos2;
        self.fireControl.position = fireButtonPos2;
        healthIndicator.position = healthIndicatorPos2;
    }
    
    [self loadThumbs];
    [self loadDemo];
    */
    
}

-(void)placeRocket:(CGPoint)location{
    //add rocket
    self.rocket = [[CSMRocketSprite alloc]initWithScene:self];
    self.rocket.position = location;
    self.rocket.zPosition = kDrawing1zPos;
    [self.rocket providePhysicsBodyAndActions];
    //newRocket.userInteractionEnabled = YES; //for LevelBuildScene
    [self.spriteHolder addChild:self.rocket];
    //state = NORMAL; //for LevelBuildScene
}

#pragma mark sounds

-(void)loadSounds{
    
    
    /*
     NSString* path = [[NSBundle mainBundle] bundlePath];
     
     
     explosionPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:
     [path stringByAppendingPathComponent:@"CSMSoundsExplosion.wav"]]
     error:nil];
     
     explosionSounds = [NSMutableArray arrayWithCapacity:11];
     AVAudioPlayer* ap;
     
     //load up with 2 explosion sounds
     for(int i=0; i<10; i+=3){
     
     ap = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:
     [path stringByAppendingPathComponent:@"CSMSoundsExp1.wav"]]
     error:nil];
     ap.volume = 0.3;
     [explosionSounds addObject:ap];
     
     ap = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:
     [path stringByAppendingPathComponent:@"CSMSoundsExp2.wav"]]
     error:nil];
     ap.volume = 0.3;
     [explosionSounds addObject:ap];
     
     ap = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:
     [path stringByAppendingPathComponent:@"CSMSoundsExp3.wav"]]
     error:nil];
     ap.volume = 0.3;
     [explosionSounds addObject:ap];
     }
     */
    
    explosionActionSounds = [NSMutableArray arrayWithCapacity:3];
    [explosionActionSounds addObject:[SKAction playSoundFileNamed:@"CSMSoundsExp1.1.wav" waitForCompletion:NO]];
    [explosionActionSounds addObject:[SKAction playSoundFileNamed:@"CSMSoundsExp2.1.wav" waitForCompletion:NO]];
    [explosionActionSounds addObject:[SKAction playSoundFileNamed:@"CSMSoundsExp3.1.wav" waitForCompletion:NO]];
    
    splashActionSounds = [NSMutableArray arrayWithCapacity:4];
    [splashActionSounds addObject:[SKAction playSoundFileNamed:@"splashDrop.wav" waitForCompletion:NO]];
    [splashActionSounds addObject:[SKAction playSoundFileNamed:@"splashMedium.wav" waitForCompletion:NO]];
    [splashActionSounds addObject:[SKAction playSoundFileNamed:@"splashWet.wav" waitForCompletion:NO]];
    [splashActionSounds addObject:[SKAction playSoundFileNamed:@"splashQuick.wav" waitForCompletion:NO]];
    
    shotSound = [SKAction playSoundFileNamed:@"CSMSoundsShot4.wav" waitForCompletion:NO];
    
    smallExplosionSounds = [NSMutableArray arrayWithCapacity:3];
    [smallExplosionSounds addObject:[SKAction playSoundFileNamed:@"CSMRussle1.wav" waitForCompletion:NO]];
    [smallExplosionSounds addObject:[SKAction playSoundFileNamed:@"CSMRussle2.wav" waitForCompletion:NO]];
    [smallExplosionSounds addObject:[SKAction playSoundFileNamed:@"CSMRussle3.wav" waitForCompletion:NO]];
    
    thrustSound = [SKAction repeatActionForever:[SKAction playSoundFileNamed:@"CassamSoundsthrustloop.wav" waitForCompletion:YES]];
    
    //thrustSound = [SKAction playSoundFileNamed:@"CassamSoundsthrustloop.wav" waitForCompletion:NO];
    soundingThrust = NO;
    
    /*
     self.sThrustSoundAction = [SKAction playSoundFileNamed:@"CSMthrust.mp3" waitForCompletion:NO];
     self.sExplosionAction = [SKAction playSoundFileNamed:@"CSMSoundsExp1.wav" waitForCompletion:NO];
     self.sExplosionSmallAction = [SKAction playSoundFileNamed:@"CSMSoundsExp2.wav" waitForCompletion:NO];
     self.sFireSoundAction = [SKAction playSoundFileNamed:@"CSMfire.mp3" waitForCompletion:NO];
     */
    
    
}

-(void)soundShot{
    
    [self runAction:shotSound];
    
    /*
     static int i = 0;
     SKAction* sound = [shotActionSounds objectAtIndex:i];
     [self runAction:sound];
     i++;
     if(i>3)
     i = 0;
     */
}

-(void)soundExplosion{
    
    float f  = rand() / (float) RAND_MAX;
    
    int i = f * 3.0;
    //NSLog(@"i=%i", i);
    SKAction* sound = [explosionActionSounds objectAtIndex:i];
    [self runAction:sound];
    /*
     static int i = 0;
     SKAction* sound = [explosionActionSounds objectAtIndex:i];
     [self runAction:sound];
     i++;
     if(i>2)
     i = 0;
     */
    
    /*
     
     
     [smallExplosion runAction:self.smallExplosionAnimation];
     
     // [explosionPlayer play];
     
     static int i = 0;
     
     AVAudioPlayer* ap = [explosionSounds objectAtIndex:i];
     [ap stop];
     i++;
     if(i > 10)
     i=0;
     
     ap = [explosionSounds objectAtIndex:i];
     [ap play];
     */
    
}

-(void)soundSplash{
    ;
}

-(void)loadLevelForDemo{
    self.currentLevel = [self.gameData getDemoLevel];
    NSArray *sprites = [self.currentLevel getSprites];
    
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

#pragma mark Demo Methods

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
    self.rightThumb.zPosition = kIcon2zPos;
    self.rightThumb.alpha = 0.3;
    
    self.leftThumb = [SKSpriteNode spriteNodeWithTexture:thumbTextures[0]];
    //self.leftThumb.centerRect = CGRectMake(0.0, 0.2, 1.0, 0.8);
    self.leftThumb.anchorPoint = CGPointMake(0.5, 0.65);
    self.leftThumb.zRotation = -M_PI/4;
    self.leftThumb.zPosition = kIcon2zPos;
    self.leftThumb.alpha = 0.3;
    
    
    self.leftThumb.position = self.thrustForwardControl.position;// CGPointMake(-130, 0);
    self.rightThumb.position = self.spinControl.position; //CGPointMake(130, 0);
    [self addChild:self.leftThumb];
    [self addChild:self.rightThumb];
    
    rightThumbActions = [NSMutableArray arrayWithCapacity:3];
    leftThumbActions = [NSMutableArray arrayWithCapacity:3];
    
    
    
}

-(void)loadDemo{
    [self loadLevelForDemo];
    
    //deactivate all controls
    self.spinControl.userInteractionEnabled = NO;
    self.thrustForwardControl.userInteractionEnabled = NO;
    self.fireControl.userInteractionEnabled = NO;
    
    
    [self placeRocket:CGPointMake(0.0, 0.0)];
    [self positionSpriteHolder];
    
    
    //targetEnemy
    targetEnemy = [[CSMEnemySprite alloc]initWithScene:self];
    targetEnemy.position = targetEnemyPos;
    targetEnemy.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:targetEnemy];
    [targetEnemy providePhysicsBodyOnly];
    targetEnemy.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    
    /*
    //wormhole
    targetWormhole = [[CSMWormHoleSprite alloc]initWithSettings:[Tools CSMWormHoleSettingsMake:CGPointMake(-350, 200)] scene:self];
    targetWormhole.name = @"wormhole";
    targetWormhole.zPosition = kDrawing1zPos;
    [targetWormhole providePhysicsBodyAndActions];
    [self.spriteHolder addChild:targetWormhole];
    */
    
    //self.rightThumb.position = CGPointMake(100, 100);
    
    //[rightThumbActions addObject:[[CSMSpriteMove alloc]initCircularMoveFrom:self.rightThumb.position toAngle:(2*M_PI) around:CGPointMake(100, 0) duration:2.0]];
    
    //pause
    [rightThumbActions addObject:[SKAction waitForDuration:0.7]];
    [leftThumbActions addObject:[SKAction waitForDuration:0.7]];
    
    //zoom out
    [self demoZoom:0.6 setThumbs:YES];
    
    //zoom in
    [self demoZoom:3.3 setThumbs:YES];
    
    //pause
    [rightThumbActions addObject:[SKAction waitForDuration:0.5]];
    [leftThumbActions addObject:[SKAction waitForDuration:0.5]];
    
    //move right thumb to spinner, left to fire
    [rightThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.rightThumb
                                                             to:CGPointMake(
                                                                            self.spinControl.position.x,
                                                                            self.spinControl.position.y+40
                                                                            )
                                                       duration:0.5]
     ];
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb
                                                            to:self.thrustForwardControl.position
                                                      duration:1.0]
     ];
    
    
    //spin
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self animateTouch:self.rightThumb];
                                  }]];

    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self setRtAction:thumbSpin];
                                  }]
     ];
    
    [rightThumbActions addObject:[SKAction waitForDuration:3.0]];
    [leftThumbActions addObject:[SKAction runBlock:^
                                  {
                                      bRestLeftThumb = YES;
                                  }]
     ];
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self setRtAction:thumbRest];
                                  }]
     ];
    
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      [self animateRelease:self.rightThumb];
                                  }]
     ];
    
    
    //touch spinner
    [self spinTo:1.3 * M_PI];
    [self spinTo:0.2 * M_PI];
    [self spinTo:0.7 * M_PI];
    //[self spinTo:0.4 * M_PI];
    //[self spinTo:0.0 * M_PI];
    
    
    [rightThumbActions addObject:[SKAction runBlock:^
                                 {
                                     bRestLeftThumb = NO;
                                     bRestRightThumb = YES;
                                 }]];
    
    
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb
                                                            to:self.fireControl.position
                                                      duration:1.0]
     ];
    [self pressFire:0.7];


    //zoom out
    [leftThumbActions addObject:[SKAction runBlock:^
                                  {
                                      bRestRightThumb = NO;
                                  }]];
    
    [self demoZoom:0.6 setThumbs:YES];
    
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     bRestRightThumb = YES;
                                 }]];
    
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb
                                                            to:self.fireControl.position
                                                      duration:1.0]
     ];
    
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     bRestRightThumb = NO;
                                     bRestLeftThumb = YES;
                                 }]];
    
    //point to enemy
    //this only works if nothing has moved
    [self spinTo:[Tools getAngleFrom:self.rocket.position to:targetEnemy.position]];
    
    [rightThumbActions addObject:[SKAction runBlock:^
                                 {
                                     bRestRightThumb = YES;
                                     bRestLeftThumb = NO;
                                 }]];
    [self pressFire:0.7];
    
    [leftThumbActions addObject:[[CSMSpriteMove alloc]initNode:self.leftThumb
                                                            to:self.thrustForwardControl.position
                                                      duration:1.0]
     ];
    
    //thrust
    [leftThumbActions addObject:[SKAction runBlock:^
                                 {
                                     bRestRightThumb = NO;
                                     bRestLeftThumb = YES;
                                 }]];
    [self spinTo:[Tools getAngleFrom:self.rocket.position to:targetWormhole.position]];
    [rightThumbActions addObject:[SKAction runBlock:^
                                  {
                                      bRestRightThumb = YES;
                                      bRestLeftThumb = NO;
                                  }]];
    [self pressThrust:0.4];
    
    
    
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
    
    if(targetEnemy)
        targetEnemy.position = targetEnemyPos;
    
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
    
    
}

-(void)setRtAction:(int)newAction{
    rtAction = newAction;
}

-(void)demoZoom:(CGFloat)scaleChange setThumbs:(BOOL)set{
    
    //calculate move required
   
    //CGFloat scaleChange = newScale / self.spriteHolder.xScale;
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
    self.spinControl.target = targetAngle;
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



#pragma mark ============================= addding characters ===============================

-(void)addBullet:(CGPoint)position direction:(CGFloat)rotation{
    SKTexture* bulletTexture = [SKTexture textureWithImageNamed:@"bullet.png"];
    SKSpriteNode *bullet = [[SKSpriteNode alloc] initWithTexture:bulletTexture];
    bullet.name = @"bullet";
    bullet.zRotation = rotation;
    bullet.zPosition = kDrawing1zPos;
    // NSLog(@"rocket zRotation = %f", self.rocket.zRotation);
    bullet.position = CGPointMake(
                                  position.x + (kbulletPojection * -sinf(rotation)),
                                  position.y + (kbulletPojection * cosf(rotation))
                                  );
    
    bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: (bullet.size.width + bullet.size.height)/4];
    //bullet.physicsBody.dynamic = NO;
    bullet.physicsBody.friction = kFriction;
    bullet.physicsBody.linearDamping = kLinearDamping;
    bullet.physicsBody.angularDamping = kAngularDamping;
    
    bullet.physicsBody.velocity = self.rocket.physicsBody.velocity;
    
    //prepare for colisions
    bullet.physicsBody.categoryBitMask = categoryBullet;
    bullet.physicsBody.collisionBitMask = bulletCollisions;
    bullet.physicsBody.contactTestBitMask = bulletContacts;
    [self.spriteHolder addChild:bullet];
    
    [bullet.physicsBody applyImpulse: CGVectorMake(kMissileLaunchImpulse * self.spriteHolder.xScale * -sinf(rotation),
                                                   kMissileLaunchImpulse * self.spriteHolder.yScale * cosf(rotation))];
    
    //[bullet runAction:self.sFireSoundAction];
    [self soundShot];
    
    //NSLog(@"rocket %f, bullet %f", self.rocket.zRotation, bullet.zRotation);
}

-(void)addEnemy:(CGPoint)location{
    
    CSMEnemySprite *enemy = [[CSMEnemySprite alloc]initWithScene:self];
    enemy.position = location;
    enemy.zPosition = kDrawing1zPos;
    
    [self.spriteHolder addChild:enemy];
    [enemy providePhysicsBodyAndActions];
    //[self mark:enemy.position];
}

-(void)addEnemy:(CGPoint)location impulse:(CGVector)impulse{
    CSMEnemySprite *enemy = [[CSMEnemySprite alloc]initWithScene:self];
    enemy.position = location;
    enemy.zPosition = kDrawing1zPos;
    
    [self.spriteHolder addChild:enemy];
    [enemy providePhysicsBodyAndActions];
    [enemy.physicsBody applyImpulse:impulse];
    //[self mark:enemy.position];
}

-(void)addEnemyScud:(CGPoint)position velocity:(CGVector)vel direction:(CGFloat)rotation{
    SKTexture* scudTexture = [SKTexture textureWithImageNamed:@"enemyScud.png"];
    SKSpriteNode *bullet = [[SKSpriteNode alloc] initWithTexture:scudTexture];
    bullet.name = @"scud";
    bullet.zRotation = rotation;
    bullet.zPosition = kDrawing1zPos;
    // NSLog(@"rocket zRotation = %f", self.rocket.zRotation);
    bullet.position = CGPointMake(
                                  position.x + (kbulletPojection * -sinf(rotation)),
                                  position.y + (kbulletPojection * cosf(rotation))
                                  );
    
    bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:( ((bullet.size.width + bullet.size.height) / 4))];
    //bullet.physicsBody.dynamic = NO;
    bullet.physicsBody.friction = kFriction;
    bullet.physicsBody.linearDamping = kLinearDamping;
    bullet.physicsBody.angularDamping = kAngularDamping;
    
    bullet.physicsBody.velocity = vel;
    
    //prepare for colisions
    bullet.physicsBody.categoryBitMask = categoryScud;
    bullet.physicsBody.collisionBitMask = scudCollisions;
    bullet.physicsBody.contactTestBitMask = scudContacts;
    [self.spriteHolder addChild:bullet];
    
    [bullet.physicsBody applyImpulse: CGVectorMake(kEnemyMissileLaunchImpulse * 7 * self.spriteHolder.xScale * -sinf(rotation),
                                                   kEnemyMissileLaunchImpulse * 7 * self.spriteHolder.yScale * cosf(rotation))];
}

-(void)explosion:(CGPoint)location{
    // NSLog(@"[CSMGamePlayScene explosion]");
    SKSpriteNode* explosion = [[SKSpriteNode alloc]initWithTexture:self.explosionTextures[0]];
    explosion.position = location;
    explosion.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:explosion];
    [explosion runAction:self.explosionAnimation completion:^{
        [explosion removeFromParent];
    }];
    //NSLog(@"exp sound");
    [self runAction:self.sExplosionAction];
    
}

#pragma mark ============================= loop methods ===============================

-(void)update:(NSTimeInterval)currentTime{
    [self demoControl:currentTime];
    
    //set hud
    //self.hud.text = [NSString stringWithFormat:@":%i", self.score];
    self.hud.text = [NSString stringWithFormat:@" "];
    
    
    //set ticker
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTime;
    self.lastUpdateTime = currentTime;
    if (timeSinceLast > 0.1) { // more than a second since last update
        timeSinceLast = 0.1;
        self.lastUpdateTime = currentTime;
    }
    
    
    lastRocketPosition = self.rocket.position;
    
    
    //move enemies
    
    //static int intTic = 0;
    NSArray* sprites = [self.spriteHolder children];
    for(SKSpriteNode* sprite in sprites){
        //if([sprite.name isEqualToString:@"enemy"]){
        if([sprite isKindOfClass:[CSMEnemySprite class]]){
            CSMEnemySprite* es = (CSMEnemySprite*)sprite;
            if(!es.physicsBody){
                NSLog(@"adding pb");
                [es providePhysicsBodyAndActions];
            }
            
            [(CSMEnemySprite*)sprite doPhysics:timeSinceLast];
        }
        else if([sprite.name isEqualToString:@"astroid"]){
            [(CSMAstroidSprite*)sprite rotate:timeSinceLast];
        }
    }
    //physics for enemyArtilary
    for(CSMEnemyArtilary* ea in artilaryRegister)
        [ea doPhysics:timeSinceLast];
    //intTic++;
    
    
    //spin rocket
    //self.spinControl.zRotation = self.spinControl.target;
    if(bSpinTouched)
        [self.spinControl turn:timeSinceLast];
    
    self.rocket.zRotation = self.spinControl.zRotation;
    //self.thrustForwardControl.zRotation = self.rocket.zRotation;
    //self.thrustBackwardControl.zRotation = self.rocket.zRotation;
    
    //move & accelerate rocket
    if(self.rocket.bThrustForward){
        [self.rocket.physicsBody applyForce:CGVectorMake(
                                                         timeSinceLast * kRocketAcceleration * self.spriteHolder.xScale * -sinf(self.rocket.zRotation),
                                                         timeSinceLast * kRocketAcceleration * self.spriteHolder.yScale * cosf(self.rocket.zRotation))];
        
    }
    if(self.rocket.bThrustBackward){
        [self.rocket.physicsBody applyForce:CGVectorMake(
                                                         timeSinceLast * kRocketAcceleration * self.spriteHolder.xScale * sinf(self.rocket.zRotation),
                                                         timeSinceLast * kRocketAcceleration * self.spriteHolder.yScale * -cosf(self.rocket.zRotation))];
    }
    
    
    
    //fire
    static NSTimeInterval lastShotTime;
    if(self.rocket.bFire){
        // NSLog(@"bFire");
        CFTimeInterval timeSinceLastshot = currentTime - lastShotTime;
        if(timeSinceLastshot > kFireFrequency){
            [self addBullet:self.rocket.position direction:self.rocket.zRotation];
            lastShotTime = currentTime;
        }
    }
    
    
    
    //NSLog(@"rocket: %f, %f", self.rocket.position.x, self.rocket.position.y);
    
    
    if(bScaling){
        [self simulatedTouchesMoved];
    }
    
}

-(void)didSimulatePhysics
{
    CGFloat newX = self.spriteHolder.position.x;
    CGFloat newY = self.spriteHolder.position.y;
    
    if( (self.rocket.position.x > scrollBoxScaled.minX) && (self.rocket.position.x < scrollBoxScaled.maxX) )
        newX = -self.rocket.position.x * self.spriteHolder.xScale;
    if( (self.rocket.position.y > scrollBoxScaled.minY) && (self.rocket.position.y < scrollBoxScaled.maxY) )
        newY = -self.rocket.position.y * self.spriteHolder.yScale;
    
    self.spriteHolder.position = CGPointMake(newX, newY);
    
    
}

-(void)positionSpriteHolder{
    
    scaledMargin = kgameplaymargin / self.spriteHolder.xScale;
    
    scrollBoxScaled.minX = ((self.size.width/2) /self.spriteHolder.xScale) - tools.kFieldSize.width/2 - scaledMargin;
    scrollBoxScaled.maxX = tools.kFieldSize.width/2 + scaledMargin - ((self.size.width/2) /self.spriteHolder.xScale);
    scrollBoxScaled.minY = ((self.size.height/2) /self.spriteHolder.yScale) - tools.kFieldSize.height/2 - scaledMargin;
    scrollBoxScaled.maxY = tools.kFieldSize.height/2 + scaledMargin - ((self.size.height/2) /self.spriteHolder.yScale);
    
    CGFloat shX = 0.0;
    CGFloat shY = 0.0;
    
    if(self.rocket.position.x < scrollBoxScaled.minX)
        shX = -scrollBoxScaled.minX * self.spriteHolder.xScale;
    else if(self.rocket.position.x > scrollBoxScaled.maxX)
        shX = -scrollBoxScaled.maxX * self.spriteHolder.xScale;
    
    
    if(self.rocket.position.y < scrollBoxScaled.minY)
        shY = -scrollBoxScaled.minY * self.spriteHolder.yScale;
    else if (self.rocket.position.y > scrollBoxScaled.maxY)
        shY = -scrollBoxScaled.maxY * self.spriteHolder.yScale;
    
    self.spriteHolder.position = CGPointMake(shX, shY);
    
}


- (void)didBeginContact:(SKPhysicsContact *)contact{
    
    
    //NSLog(@"CONTACT %@ with %@", contact.bodyA.node.name, contact.bodyB.node.name);
    //NSLog(@"%i with %i", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask);
    
    
    //bullet collisions
    if (contact.bodyA.categoryBitMask & categoryBullet || contact.bodyB.categoryBitMask & categoryBullet)
    {
        SKPhysicsBody *bulletBody = (contact.bodyA.categoryBitMask & categoryBullet) ? contact.bodyA : contact.bodyB;
        SKPhysicsBody *otherSpriteBody = (contact.bodyA.categoryBitMask & categoryBullet) ? contact.bodyB : contact.bodyA;
        
        //enemies explode
        if(otherSpriteBody.categoryBitMask & (categoryEnemy | categoryEnemyArtilary)){
            self.score += 1;
            SKSpriteNode* explosion = [[SKSpriteNode alloc]initWithTexture:self.explosionTextures[0]];
            if(otherSpriteBody.categoryBitMask & categoryEnemyArtilary){
                CGPoint artilPos = [otherSpriteBody.node.parent convertPoint:otherSpriteBody.node.position toNode:self.spriteHolder];
                explosion.position = CGPointMake(
                                                 (bulletBody.node.position.x + artilPos.x) / 2,
                                                 (bulletBody.node.position.y + artilPos.y) / 2
                                                 );
            }
            else{
                explosion.position = CGPointMake(
                                                 (contact.bodyA.node.position.x + contact.bodyB.node.position.x)/2,
                                                 (contact.bodyA.node.position.y + contact.bodyB.node.position.y)/2
                                                 );
            }
            explosion.zPosition = kDrawing1zPos;
            [self.spriteHolder addChild:explosion];
            [explosion runAction:self.explosionAnimation completion:^{
                [explosion removeFromParent];
            }];
            //[self runAction:self.sExplosionAction];
            [self soundExplosion];
            [otherSpriteBody.node removeFromParent];
            //[self soundSplash];
            //remove enemyartilary from rigister
            if(otherSpriteBody.categoryBitMask & categoryEnemyArtilary){
                //NSLog(@"removing ea, register length:%li", [artilaryRegister count]);
                //NSLog(@"ea:\n%@", otherSpriteBody);
                [artilaryRegister removeObject:otherSpriteBody.node];
                //NSLog(@"register lenght:%li", [artilaryRegister count]);
                //NSLog(@"register contents:\n%@", artilaryRegister);
            }
            //NSLog(@"explosion.position: %f, %f", explosion.position.x, explosion.position.y);
        }
        else if(otherSpriteBody.categoryBitMask & categoryEnemyEgg){
            CSMEnemyEgg* egg = (CSMEnemyEgg*)otherSpriteBody.node;
            [self soundSplash];
            [egg hit];
        }
        
        else{
            SKSpriteNode* smallExplosion = [[SKSpriteNode alloc]initWithTexture:self.smallExplosionTextures[0]];
            smallExplosion.position = CGPointMake(
                                                  bulletBody.node.position.x,
                                                  bulletBody.node.position.y
                                                  );
            smallExplosion.zPosition = kDrawing1zPos;
            [self.spriteHolder addChild:smallExplosion];
            //[self runAction:self.sExplosionSmallAction];
            [self soundExplosion];
            //[self soundSplash];
            [smallExplosion runAction:self.smallExplosionAnimation completion:^{
                [smallExplosion removeFromParent];
            }];
            
            //NSLog(@"small explosion.position: %f, %f", smallExplosion.position.x, smallExplosion.position.y);
        }
        [bulletBody.node removeFromParent];
    }
    //scud collisions
    else if (contact.bodyA.categoryBitMask & categoryScud || contact.bodyB.categoryBitMask & categoryScud)
    {
        //NSLog(@"1");
        SKPhysicsBody *bulletBody = (contact.bodyA.categoryBitMask & categoryScud) ? contact.bodyA : contact.bodyB;
        SKPhysicsBody *otherSpriteBody = (contact.bodyA.categoryBitMask & categoryScud) ? contact.bodyB : contact.bodyA;
        
        //enemies explode
        if(otherSpriteBody.categoryBitMask & (categoryEnemy)){
            //self.score += 10;
            SKSpriteNode* explosion = [[SKSpriteNode alloc]initWithTexture:self.explosionTextures[0]];
            explosion.position = CGPointMake(
                                             (contact.bodyA.node.position.x + contact.bodyB.node.position.x)/2,
                                             (contact.bodyA.node.position.y + contact.bodyB.node.position.y)/2
                                             );
            explosion.zPosition = kDrawing1zPos;
            [self.spriteHolder addChild:explosion];
            [explosion runAction:self.explosionAnimation completion:^{
                [explosion removeFromParent];
            }];
            [otherSpriteBody.node removeFromParent];
        }
        else{
            //NSLog(@"2");
            SKSpriteNode* smallExplosion = [[SKSpriteNode alloc]initWithTexture:self.smallExplosionTextures[0]];
            //NSLog(@"parent:%@", bulletBody.node.parent);
            smallExplosion.position = CGPointMake(
                                                  bulletBody.node.position.x,
                                                  bulletBody.node.position.y
                                                  );
            smallExplosion.zPosition = kDrawing1zPos;
            [self.spriteHolder addChild:smallExplosion];
            [smallExplosion runAction:self.smallExplosionAnimation completion:^{
                [smallExplosion removeFromParent];
            }];
        }
        [bulletBody.node removeFromParent];
    }
    
    //wormhole
    if (contact.bodyA.categoryBitMask & categoryWormhole || contact.bodyB.categoryBitMask & categoryWormhole){
        if(contact.bodyA.categoryBitMask & categoryWormhole)
            [self levelCompleted:contact.bodyA.node.position];
        else
            [self levelCompleted:contact.bodyB.node.position];
    }
    
    //rocket
    else if (contact.bodyA.categoryBitMask & categoryRocket || contact.bodyB.categoryBitMask & categoryRocket){
        [self.rocket addtoHealth:-10];
        [self.rocket showDistress];
        [healthIndicator reduceHealthTo:((CGFloat)[self.rocket getHealth] / 100.0)];
        if([self.rocket getHealth ] <= 0){
            SKSpriteNode* explosion = [[SKSpriteNode alloc]initWithTexture:self.explosionTextures[0]];
            explosion.position = self.rocket.position;
            [self.spriteHolder addChild:explosion];
            [explosion runAction:self.explosionAnimation completion:^{
                [explosion removeFromParent];
            }];
            
            // self.rocket.alpha = 0.0;
            [self.rocket removeFromParent];
            [self levelFailed];
            
        }
    }
    
}

#pragma mark ============================= game steps ===============================

-(void)levelCompleted:(CGPoint)location{
    
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
    
    SKSpriteNode* tick = [SKSpriteNode spriteNodeWithImageNamed:@"bigtick.png"];
    //tick.position = tickPos;
    
    
    
    ButtonSprite* playButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconPlay.png"]
                                                              scene:self
                                                               type:kPlayNextLevel];
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

-(void)levelFailed{
    
    
    SKSpriteNode* levelCompleteDisplay = [[SKSpriteNode alloc] initWithColor:[[SKColor alloc]initWithWhite:1.0 alpha:0.5]
                                                                        size:CGSizeMake(300, 180)];
    levelCompleteDisplay.position = CGPointMake(0, 30);
    levelCompleteDisplay.zPosition = kIcon1zPos;
    
    
    SKLabelNode* levelCompletedText1 = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    levelCompletedText1.fontSize = 25;
    levelCompletedText1.fontColor = [UIColor iconBlue];
    levelCompletedText1.text = [NSString stringWithFormat:@"Level Failed!"];
    
    SKLabelNode* levelCompletedText2 = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    levelCompletedText2.fontSize = 25;
    levelCompletedText2.fontColor = [UIColor iconBlue];
    levelCompletedText2.text = [NSString stringWithFormat:@"score: %i", self.score];
    
    ButtonSprite* playButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconReplay.png"]
                                                              scene:self
                                                               type:kReplayLevel];
    ButtonSprite* menuButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconMenu.png"]
                                                              scene:self
                                                               type:kLevelMenu];
    
    levelCompletedText1.position = CGPointMake(0, 60);
    levelCompletedText2.position = CGPointMake(0, 20);
    menuButton.position = CGPointMake(-30, -30);
    playButton.position = CGPointMake(30, -30);
    
    [levelCompleteDisplay addChild:levelCompletedText1];
    [levelCompleteDisplay addChild:levelCompletedText2];
    [levelCompleteDisplay addChild:menuButton];
    [levelCompleteDisplay addChild:playButton];
    
    
    SKAction* zoom = [SKAction scaleTo:1.0 duration:0.25];
    levelCompleteDisplay.xScale = 0.05;
    levelCompleteDisplay.yScale = 0.05;
    [self addChild:levelCompleteDisplay];
    //[levelCompleteDisplay runAction:zoom];
    [levelCompleteDisplay runAction:[SKAction sequence:@[
                                                         [SKAction waitForDuration:1.0],
                                                         zoom
                                                         ]]
     ];
    
    
}

-(void)nextLevel{
    
    int currentLevelNo = [[self.currentLevel getLevelNumber] intValue];
    //[self.gameData openGamePlayLevel:++currentLevelNo fromScene:self];
    [self.gameData openGamePlayLevel:currentLevelNo fromScene:self];
}

-(void)reloadLevel{
    
    [self.gameData openGamePlayLevel:[[self.currentLevel getLevelNumber] intValue] fromScene:self];
}


#pragma mark ============================= User input ===============================

-(void)buttonTouched:(ButtonType)button{
    switch (button) {
        case kThrustForward:
            [self animateThrust:YES];
            self.rocket.bThrustForward = YES;
            break;
        case (kThrustReverse):
            [self animateThrust:NO];
            self.rocket.bThrustBackward = YES;
            break;
        case(kFire):
            self.rocket.bFire = YES;
            break;
        default:
            break;
            
    }
}

-(void)buttonReleased:(ButtonType)button{
    switch (button) {
        case kThrustForward:
            [self stopThrustAnimation:YES];
            self.rocket.bThrustForward = NO;
            break;
        case (kThrustReverse):
            [self stopThrustAnimation:NO];
            self.rocket.bThrustBackward = NO;
            break;
        case(kFire):
            self.rocket.bFire = NO;
            break;
        case(kBack):
            [self openMenu];
            break;
        case(kUtility):
            [self utilityPressed];
            break;
        case kPlayNextLevel:
            [self nextLevel];
            break;
        case kReplayLevel:
            [self reloadLevel];
            break;
        case kLevelMenu:
            [self openMenu];
            break;
        case kPlayDemo:
            [self.gameData openDemoLevelFromScene:self];
        default:
            NSLog(@"unrecognised button released: %i", button);
            break;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    
    //check for pinch
    if([allTouches count] == 2){
        int i=0;
        for(UITouch *touch in [allTouches allObjects]){
            pinchTouches[i] = [touch locationInNode:self.spriteHolder];
            i++;
        }
        //place marker in the midddle of the thouch
        //self.marker.position = [Tools getMidPoint:pinchTouches[0] and:pinchTouches[1]];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    
    //check for pinch
    if([allTouches count] == 2){
        //NSLog(@"2 touches moved...");
        int i=2;
        for(UITouch *touch in [allTouches allObjects]){
            pinchTouches[i] = [touch locationInNode:self.spriteHolder];
            i++;
        }
        
        CGFloat startPinch = [Tools getDistanceBetween:pinchTouches[0] and:pinchTouches[1]];
        CGFloat endPinch = [Tools getDistanceBetween:pinchTouches[2] and:pinchTouches[3]];
        CGFloat scaleChange = endPinch / startPinch;
        
        CGFloat newScale = self.spriteHolder.xScale * scaleChange;
        [self rescaleScene:newScale];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved:touches withEvent:event];
}

-(void)utilityPressed{
}

#pragma mark ========================== helpers ================

-(void)animateThrust:(BOOL)forward{
    if(forward){
        [self.rocket addChild:self.rocketBurnSprites[0]];
        [self.rocket addChild:self.rocketBurnSprites[1]];
        [self.rocketBurnSprites[0] runAction:self.fuelBurnAnimation];
        //delay one rocket a moment
        [self.rocketBurnSprites[1] runAction:[SKAction sequence:@[[SKAction waitForDuration:animationFrameLength], self.fuelBurnAnimation]]];
        
    }
    else{
        [self.rocket addChild:self.rocketBurnSprites[2]];
        [self.rocket addChild:self.rocketBurnSprites[3]];
        [self.rocketBurnSprites[2] runAction:self.fuelBurnAnimation];
        //delay one rocket a moment
        [self.rocketBurnSprites[3] runAction:[SKAction sequence:@[[SKAction waitForDuration:animationFrameLength], self.fuelBurnAnimation]]];
    }
}

-(void)stopThrustAnimation:(BOOL)forward{
    if(forward){
        [self.rocketBurnSprites[0] removeFromParent];
        [self.rocketBurnSprites[1] removeFromParent];
    }
    else{
        [self.rocketBurnSprites[2] removeFromParent];
        [self.rocketBurnSprites[3] removeFromParent];
    }
    // [self.rocketBurn removeFromParent];
}

-(void)rescaleScene:(CGFloat)newScale{
    
    if(
       newScale < self.minScale
       ||
       newScale > maxScale
       )
        return;
    
    
    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
    // class is used as fallback when it isn't available.
    /*
     NSString *reqSysVer = @"3.1";
     NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
     if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
     displayLinkSupported = TRUE;
     */
    
    if (!bNeedToScalePhysicsBodies){
        // NSLog(@"no need to scale physics bodies");
        
        
        //NSLog(@"scaling...");
        for(CSMSpriteNode* sprite in [self.spriteHolder children]){
            if(sprite.physicsBody){
                sprite.physicsBody.velocity = CGVectorMake(
                                                           sprite.physicsBody.velocity.dx * newScale/self.spriteHolder.xScale,
                                                           sprite.physicsBody.velocity.dy * newScale/self.spriteHolder.yScale
                                                           );
            }
        }
    }
    else{
        NSLog(@"scale physics bodies");
        for(CSMSpriteNode* sprite in [self.spriteHolder children]){
            if(sprite.physicsBody){
                NSLog(@"rescale %@", sprite.name);
                CGFloat mass = sprite.physicsBody.mass;
                CGVector vel = sprite.physicsBody.velocity;
                if([sprite isKindOfClass:[CSMSpriteNode class]]){
                    NSLog(@"1");
                    [sprite providePhysicsBodyToScale:self.spriteHolder.xScale];
                }
                else{
                    NSLog(@"2");
                    SKPhysicsBody* oldBody = sprite.physicsBody;
                    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(sprite.size.width/2 * self.spriteHolder.xScale)];
                    
                    
                    sprite.physicsBody.friction = kFriction;
                    sprite.physicsBody.linearDamping = kLinearDamping;
                    sprite.physicsBody.angularDamping = kAngularDamping;
                    
                    sprite.physicsBody.velocity = oldBody.velocity;
                    //sprite.physicsBody.mass = oldBody.mass;
                    
                    //prepare for colisions
                    sprite.physicsBody.categoryBitMask = oldBody.categoryBitMask;
                    sprite.physicsBody.collisionBitMask = oldBody.collisionBitMask;
                    sprite.physicsBody.contactTestBitMask = oldBody.contactTestBitMask;
                    
                    
                    
                }
                sprite.physicsBody.mass = mass;
                sprite.physicsBody.velocity = vel;
            }
        }
        
        
        
    }
    self.spriteHolder.xScale = newScale;
    self.spriteHolder.yScale = newScale;
    
    
    [self positionSpriteHolder];
    
    
    
}


#pragma mark ========================== interactions =============

-(void)openMenu{
    [self.gameData openMenuFromScene:self];
    /*
     SKScene *menuScene  = [[CSMMenuScene alloc] initWithSize:self.size pos:CSMOriginalLevelsPos];
     SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
     [self.view presentScene:menuScene transition:doors];
     */
}

#pragma mark ========================== utilities ================

-(void)addRect:(SKNode*)node rect:(CGRect)rect{
    NSLog(@"addingRect at %f, %f", rect.origin.x, rect.origin.y);
    SKShapeNode* rectNode = [SKShapeNode node];
    UIBezierPath* bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y)];
    [bezierPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [bezierPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    [bezierPath addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    [bezierPath addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y)];
    rectNode.path = bezierPath.CGPath;
    rectNode.lineWidth = 10.0;
    rectNode.strokeColor = [UIColor redColor];
    rectNode.antialiased = NO;
    [node addChild:rectNode];
}

-(NSArray*)getSprites:(NSString*)fileName frames:(int)frames{
    
    SKTexture *texture = [SKTexture textureWithImageNamed:fileName];
    NSMutableArray* sprites = [[NSMutableArray alloc]initWithCapacity:frames];
    
    CGFloat frameW = 1.0 / frames;
    
    for(int i=0; i<frames; i++){
        sprites[i] = [SKTexture textureWithRect:CGRectMake(frameW*i, 0.0, frameW, 1) inTexture:texture];
    }
    
    return  [NSArray arrayWithArray: sprites];
}

/*
 static inline CGFloat skRand(CGFloat low, CGFloat high) {
 return skRandf() * (high - low) + low;
 }
 
 static inline CGFloat skRandf() {
 return rand() / (CGFloat) RAND_MAX;
 }
 */


@end
