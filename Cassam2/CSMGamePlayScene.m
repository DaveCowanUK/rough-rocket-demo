//
//  CSMGamePlayScene.m
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

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




@interface CSMGamePlayScene () <SKPhysicsContactDelegate>
@property BOOL contentCreated;
@property SKLabelNode* levelLabel;
@property CSMLevelsLibrary* levelsLibrary;
@property int score;
@property (nonatomic) NSArray *explosionTextures;
@property (nonatomic) NSArray *smallExplosionTextures;
@property (nonatomic) SKAction *explosionAnimation;
@property (nonatomic) SKAction *smallExplosionAnimation;
@end


@implementation CSMGamePlayScene {
    
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
    
    
    BOOL bNeedToScalePhysicsBodies;
    NSMutableArray* artilaryRegister;
    NSMutableArray* feelerRegister;
    
    NSMutableArray* explosionActionSounds;
    NSMutableArray* splashActionSounds;
    NSMutableArray* explosionSounds;
    NSMutableArray* smallExplosionSounds;
    AVAudioPlayer* explosionPlayer;
    
    NSMutableArray* glassSounds;
    
    SKAction* shotSound;
    SKAction* damageSound;
    SKAction* whistleupSound;
    
    ButtonSprite* pauseButton;
    
    //SKAction* backgroundMusic;
    
    SKAction* thrustSound;
    BOOL soundingThrust;
    
    BOOL gameOver;
    
#ifdef traceMovement
    SKAction* traceSpriteAction;
#endif
    
#ifdef constantThrust
    BOOL firstTimeThrust;
#endif
}



#pragma mark ============================= startup ===============================

+(id)sceneWithSize:(CGSize)size library:(CSMLevelsLibrary *)library level:(CSMLevel *)level{
    CSMGamePlayScene* scene = [[CSMGamePlayScene alloc]initWithSize:size library:library level:level];
    return scene;
}

+(id)sceneWithSize:(CGSize)size level:(CSMLevel *)level gameData:(CSMGameData *)gData{
    CSMGamePlayScene* scene = [[CSMGamePlayScene alloc]initWithSize:size level:level gameData:gData];
    return scene;
}

-(id)initWithSize:(CGSize)size
{
    
    if (self = [super initWithSize:size])
    {
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        self.bLargeScreen = NO;
        
        
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
        feelerRegister = [NSMutableArray arrayWithCapacity:5];
    }
    self.name = @"gameplayscene";
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

-(void)backgroundOnly{
    [super createSceneContents];
}

- (void)createSceneContents
{
    [self prepareSceneForLoading];
    [self loadLabels];
    [self loadControls];
    [self loadLevel];
    
#ifdef frameRateSwitches
    [self loadFrameRateSwitches];
#endif
#ifdef constantThrust
    firstTimeThrust = YES;
#endif
    
    if([[self.currentLevel getLevelNumber] intValue] < 4){
        [self addQueryButton];
    }
    
    self.view.multipleTouchEnabled = YES;
    
    //backgroundMusic =  [SKAction repeatActionForever:[SKAction playSoundFileNamed:@"tuneSoundLike.wav" waitForCompletion:YES]];
    //[self runAction:backgroundMusic];
    
    
}

-(void)loadFrameRateSwitches{
    ButtonSprite* fpsUp = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"playControl.png"] scene:self type:kFpsUp];
    fpsUp.zRotation = M_PI/2;
    fpsUp.xScale = 0.5;
    fpsUp.yScale = 0.5;
    fpsUp.position = CGPointMake(30, self.frame.size.height/2 -30);
    fpsUp.zPosition = kIcon1zPos;
    [self.gameNode addChild:fpsUp];
    
    ButtonSprite* fpsDown = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"playControl.png"] scene:self type:kFpsDown];
    fpsDown.zRotation = -M_PI/2;
    fpsDown.xScale = 0.5;
    fpsDown.yScale = 0.5;
    fpsDown.position = CGPointMake(-30, self.frame.size.height/2 -30);
    fpsDown.zPosition = kIcon1zPos;
    [self.gameNode addChild:fpsDown];
}

-(void)changeFps:(BOOL)increase{
    NSInteger newFps = 0;
    if(increase){
        newFps = self.view.frameInterval - 1;
        if(newFps < 1){
            newFps = 1;
        }
    }
    else{
        newFps = self.view.frameInterval + 1;
    }
    
    self.view.frameInterval = newFps;
    NSLog(@"newFps:%li", (long)self.view.frameInterval);
}

-(void)prepareSceneForLoading{
    if(self.frame.size.height > 700)
        self.bLargeScreen = YES;
    
    [super createSceneContents];
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
    SKSpriteNode* rfBurn = (SKSpriteNode*) self.rocketBurnSprites[0];
    rfBurn.position = rfburnPos;
    SKSpriteNode* lfBurn = (SKSpriteNode*) self.rocketBurnSprites[1];
    lfBurn.position = lfburnPos;
    
    [self.rocketBurnSprites[2] setZRotation:M_PI];
    [self.rocketBurnSprites[3] setZRotation:M_PI];
    
    for(int i=0; i<self.rocketBurnSprites.count; i++)
        [self.rocketBurnSprites[i] setZPosition:0.0];
    
    //load explosion animation
    self.explosionTextures = [self getSprites:@"explosion1.png" frames:6];
    self.explosionAnimation = [SKAction animateWithTextures:self.explosionTextures timePerFrame:animationFrameLength];
    
    
    
    self.smallExplosionTextures = [self getSprites:@"explosion2.png" frames:6];
    self.smallExplosionAnimation = [SKAction animateWithTextures:self.smallExplosionTextures timePerFrame:animationFrameLength];
    
    self.spriteHolder.physicsBody.categoryBitMask = categorySpriteHolder;//spriteHolderCategory;
    self.spriteHolder.physicsBody.contactTestBitMask = spriteHolderCollisions;
}

-(void)loadLabels{
    //level label
    self.levelLabel = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    self.levelLabel.fontSize = 20;
    self.levelLabel.fontColor = [UIColor iconBlue];
    self.levelLabel.position = label1Pos;
    self.levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.levelLabel.zPosition = kIcon1zPos;
    self.levelLabel.text = [NSString stringWithFormat:@"l:%i", [[self.currentLevel getLevelNumber] intValue]];
    [self.gameNode addChild:self.levelLabel];
    
    
    //add hud
    self.hud = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    self.hud.fontSize = 20;
    self.hud.fontColor = [UIColor iconBlue];
    self.hud.position = label2Pos;
    self.hud.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.hud.zPosition = kIcon1zPos;
    [self.gameNode addChild:self.hud];
    self.hud.alpha = 0.0;
    
    
    self.hud.text = [NSString stringWithFormat:@":%i", self.score];
}

-(void)loadControls{
    
    //pauseButton
    SKTexture *pauseIconTexture = [SKTexture textureWithImageNamed:@"IconPause.png"];
    pauseButton = [[ButtonSprite alloc]initWithTexture: pauseIconTexture scene:self type:kPause];
    pauseButton.position = pauseButtonPos;
    pauseButton.userInteractionEnabled = YES;
    pauseButton.alpha = 0.9;
    pauseButton.zPosition = kIcon1zPos;
    //self.playControl.hidden = YES;
    [self addChild:pauseButton];
    
    //prepare control textures
    SKTexture* spinControlTexture, *thrustForwardControlTexture, *fireControlTexture;
    
    spinControlTexture = [SKTexture textureWithImageNamed:@"rocketControl2.0.png"];
    thrustForwardControlTexture = [SKTexture textureWithImageNamed:@"thrustForward.png"];
    fireControlTexture = [SKTexture textureWithImageNamed:@"fireControl2.0.png"];
    
    //add controls
    
    //spin control
    self.spinControl = [[SpinControlSprite alloc]initWithTexture: spinControlTexture];
    self.spinControl.position = spinControlPos;
    self.spinControl.userInteractionEnabled = YES;
    self.spinControl.zPosition = kIcon1zPos;
    self.spinControl.alpha = kControlAlpha;
    [self.gameNode addChild:self.spinControl];
    /*
     NSLog(@"SPINCONTROL FRAME: %f, %f, %f, %f", self.spinControl.frame.origin.x, self.spinControl.frame.origin.y, self.spinControl.frame.size.width, self.spinControl.frame.size.height);
     */
    
    //health indicator
    self.healthIndicator = [[CSMHealthIndicator alloc]init];
    self.healthIndicator.position = healthIndicatorPos;
    self.healthIndicator.zPosition = kIcon1zPos;
    self.healthIndicator.alpha = kControlAlpha;
    [self.healthIndicator prepareAnimation:self];
    [self.gameNode addChild:self.healthIndicator];
    
    
    //thrust
    self.thrustForwardControl = [[ButtonSprite alloc]initWithTexture: thrustForwardControlTexture scene:self type:kThrustForward];
    self.thrustForwardControl.position = thrustForwardPos;
    self.thrustForwardControl.userInteractionEnabled = YES;
    self.thrustForwardControl.zPosition = kIcon1zPos;
    self.thrustForwardControl.alpha = kControlAlpha;
    [self.gameNode addChild:self.thrustForwardControl];
    
    //fire
    self.fireControl = [[ButtonSprite alloc]initWithTexture: fireControlTexture scene:self type:kFire];
    self.fireControl.position = fireButtonPos;
    self.fireControl.userInteractionEnabled = YES;
    self.fireControl.zPosition = kIcon1zPos;
    self.fireControl.alpha = kControlAlpha;
    [self.gameNode addChild:self.fireControl];
    
    //set control positions for larger screen
    if(self.bLargeScreen){
        self.spinControl.position = spinControlPos2;
        self.thrustForwardControl.position = thrustForwardPos2;
        self.fireControl.position = fireButtonPos2;
        self.healthIndicator.position = healthIndicatorPos2;
    }
    
    //to resolve iOS9 bug
    /*
     self.fireControl.userInteractionEnabled = NO;
     self.spinControl.userInteractionEnabled = NO;
     self.thrustForwardControl.userInteractionEnabled = NO;
     */
    
    
}

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
    
    damageSound = [SKAction playSoundFileNamed:@"damage.wav" waitForCompletion:NO];
    
    whistleupSound = [SKAction playSoundFileNamed:@"whistleup.wav" waitForCompletion:NO];
    
    smallExplosionSounds = [NSMutableArray arrayWithCapacity:3];
    [smallExplosionSounds addObject:[SKAction playSoundFileNamed:@"CSMRussle1.wav" waitForCompletion:NO]];
    [smallExplosionSounds addObject:[SKAction playSoundFileNamed:@"CSMRussle2.wav" waitForCompletion:NO]];
    [smallExplosionSounds addObject:[SKAction playSoundFileNamed:@"CSMRussle3.wav" waitForCompletion:NO]];
    
    glassSounds = [NSMutableArray arrayWithCapacity:3];
    [glassSounds addObject:[SKAction playSoundFileNamed:@"glassLow.wav" waitForCompletion:NO]];
    [glassSounds addObject:[SKAction playSoundFileNamed:@"glassMedium.wav" waitForCompletion:NO]];
    [glassSounds addObject:[SKAction playSoundFileNamed:@"glassHigh.wav" waitForCompletion:NO]];
    
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
    [self.gameNode runAction:shotSound];
}

-(void)soundWistleup{
    [self.gameNode runAction:whistleupSound];
}

-(void)soundDamange{
    [self.gameNode runAction:damageSound];
}

-(void)soundExplosion{
    
    float f  = rand() / (float) RAND_MAX;
    
    int i = f * 3.0;
    //NSLog(@"i=%i", i);
    SKAction* sound = [explosionActionSounds objectAtIndex:i];
    [self.gameNode runAction:sound];
    
}

-(void)soundSmallExplosion{
    
    float f  = rand() / (float) RAND_MAX;
    
    int i = f * 3.0;
    SKAction* sound = [smallExplosionSounds objectAtIndex:i];
    [self.gameNode runAction:sound];
}

-(void)soundSplash{
    float f  = rand() / (float) RAND_MAX;
    
    int i = f * 4.0;
    //NSLog(@"i=%i", i);
    SKAction* sound = [splashActionSounds objectAtIndex:i];
    [self.gameNode runAction:sound];
}

-(void)soundGlass{
    float f  = rand() / (float) RAND_MAX;
    
    int i = f * 3.0;
    //NSLog(@"i=%i", i);
    SKAction* sound = [glassSounds objectAtIndex:i];
    [self.gameNode runAction:sound];
}

-(void)loadLevel{
    [super addBackground:self.spriteHolder Size:self.currentLevel.fieldSize];
    gameOver = NO;
    
    self.score = [[self.currentLevel getLevelNumber] intValue];
    
    //add rocket
    [self placeRocket:CGPointMake([self.currentLevel getRocketPosition].x, [self.currentLevel getRocketPosition].y)];
    
    NSArray *sprites = [self.currentLevel getSprites];
    
    for(CSMSpriteNode* spriteRecord in sprites){
        
        //NSLog(@"%@", spriteRecord);
        
        CSMSpriteNode* sprite = [spriteRecord copy];
        [sprite setScene:self];
        [sprite providePhysicsBodyAndActions];
        [self.spriteHolder addChild:sprite];
        
        //register artilary
        if([sprite.name isEqualToString:@"enemyartilary"])
            [artilaryRegister addObject:sprite];
        
    }
    
    //pick up all children
    for(CSMSpriteNode *sprite in [self.spriteHolder children]){
        if([sprite isKindOfClass:[CSMSpriteNode class]]){
            [sprite pickupChildren];
        }
    }
    
    [self positionSpriteHolder];
    
    [self rescaleScene:startScale];
    //self.spriteHolder.xScale = startScale;
    //self.spriteHolder.yScale = startScale;
    
}

-(void)addQueryButton{
    //NSLog(@"addQueryButton");
    SKTexture* queryTexture = [SKTexture textureWithImageNamed:@"queryControl.png"];
    ButtonSprite* query = [[ButtonSprite alloc]initWithTexture: queryTexture scene:self type:kPlayDemo];
    query.position = queryPos;
    query.userInteractionEnabled = YES;
    query.zPosition = kIcon1zPos;
    query.alpha = kControlAlpha;
    query.xScale = 0.5;
    query.yScale = 0.5;
    [self.gameNode addChild:query];
}

-(void)placeRocket:(CGPoint)location{
    //add rocket
    self.rocket = [[CSMRocketSprite alloc]initWithScene:self];
    self.rocket.position = location;
    self.rocket.zPosition = kDrawing2zPos;
    [self.rocket providePhysicsBodyAndActions];
    //newRocket.userInteractionEnabled = YES; //for LevelBuildScene
    [self.spriteHolder addChild:self.rocket];
    //state = NORMAL; //for LevelBuildScene
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
    if(bNeedToScalePhysicsBodies){
        CGFloat mass = bullet.physicsBody.mass;
        bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: ((bullet.size.width + bullet.size.height)/4) * self.spriteHolder.xScale];
        bullet.physicsBody.mass = mass;
    }
    
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
    
    
    /*
     CGFloat enemyDirection = ((float)rand() / RAND_MAX) * 2 * M_PI;
     [self addEnemy:location impulse:CGVectorMake(
     kEnemyAcceleration / 15 * self.spriteHolder.xScale * -sinf(enemyDirection),
     kEnemyAcceleration / 15 * self.spriteHolder.yScale * cosf(enemyDirection)
     )];
     */
    //[self mark:enemy.position];
}

-(void)addEnemy:(CGPoint)location impulse:(CGVector)impulse{
    CSMEnemySprite *enemy = [[CSMEnemySprite alloc]initWithScene:self];
    enemy.position = location;
    enemy.zPosition = kDrawing1zPos;
    
    [self.spriteHolder addChild:enemy];
    [enemy providePhysicsBodyAndActions];
    if(bNeedToScalePhysicsBodies)
        [enemy providePhysicsBodyToScale:self.spriteHolder.xScale];
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
    
    bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: (bullet.size.width + bullet.size.height)/4];
    if(bNeedToScalePhysicsBodies){
        CGFloat mass = bullet.physicsBody.mass;
        bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: ((bullet.size.width + bullet.size.height)/4) * self.spriteHolder.xScale];
        bullet.physicsBody.mass = mass;
    }
    
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
    
    SKSpriteNode* explosion = [[SKSpriteNode alloc]initWithTexture:self.explosionTextures[0]];
    explosion.position = location;
    explosion.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:explosion];
    [explosion runAction:self.explosionAnimation completion:^{
        [explosion removeFromParent];
    }];
    
    if([Tools getDistanceBetween:location and:self.rocket.position] < kSoundDistance)
        [self soundExplosion];
    
    //fading explosion
    /*
     SKSpriteNode* fadingExplosion = [[SKSpriteNode alloc] initWithTexture:self.explosionTextures[3]];
     fadingExplosion.position = location;
     fadingExplosion.zPosition = kDrawing1zPos - 1;
     fadingExplosion.alpha = 0.6;
     [self.spriteHolder addChild:fadingExplosion];
     [fadingExplosion runAction:[SKAction group:@[
     [SKAction fadeAlphaTo:0.0 duration:2.0],
     [SKAction scaleTo:2.0 duration:2.0]]]
     completion:^{
     [fadingExplosion removeFromParent];
     }];
     */
}

-(void)smallExplosion:(CGPoint)location{
    
    SKSpriteNode* smallExplosion = [[SKSpriteNode alloc]initWithTexture:self.smallExplosionTextures[0]];
    smallExplosion.position = location;
    smallExplosion.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:smallExplosion];
    [smallExplosion runAction:self.smallExplosionAnimation completion:^{
        [smallExplosion removeFromParent];
    }];
    
    if([Tools getDistanceBetween:location and:self.rocket.position] < kSoundDistance)
        [self soundSmallExplosion];
}

#pragma mark ============================= loop methods ===============================

-(void)update:(NSTimeInterval)currentTime{
    
    if([self.gameNode isPaused]){
        return;
    }
    
    //set ticker
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTime;
    self.lastUpdateTime = currentTime;
    if (timeSinceLast > 0.1) { // more than a second since last update
        timeSinceLast = 0.1;
        self.lastUpdateTime = currentTime;
    }
    
    /*
     static int i = 0;
     static CFTimeInterval totalUpdate = 0.0;
     totalUpdate += timeSinceLast;
     i++;
     if(i % 100 == 0){
     //NSLog(@"average fps: %f", 1/(totalUpdate/i));
     NSLog(@"average timeSinceLast: %f", totalUpdate/i);
     }
     */
    
    //move enemies
    NSArray* sprites = [self.spriteHolder children];
    for(SKSpriteNode* sprite in sprites){
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
    
#ifdef traceMovement
    static int traceMovementCounter = 0;
    traceMovementCounter ++;
    traceSpriteAction = [SKAction fadeOutWithDuration:0.5];
    if(traceMovementCounter % 1 == 0){
        for(SKSpriteNode* sprite in sprites){
            if(
               //[sprite isKindOfClass:[CSMEnemySprite class]] ||
               //[sprite isKindOfClass:[CSMRocketSprite class]] ||
               (sprite.physicsBody.categoryBitMask & categoryBullet) ||
               (sprite.physicsBody.categoryBitMask & categoryScud)
               ){
                //add fading trace
                SKSpriteNode* traceNode = [SKSpriteNode spriteNodeWithTexture:sprite.texture];
                traceNode.alpha = 0.05;
                traceNode.zPosition = sprite.zPosition;
                traceNode.zRotation = sprite.zRotation;
                traceNode.position = sprite.position;
                [self.spriteHolder addChild:traceNode];
                [traceNode runAction:traceSpriteAction completion:^{[traceNode removeFromParent];}];
            }
            
            
            /*
             else if ([sprite isKindOfClass:[CSMNodeSprite class]]){
             for(SKSpriteNode* spriteChild in [sprite children]){
             //add fading trace
             SKSpriteNode* traceNode = [SKSpriteNode spriteNodeWithTexture:spriteChild.texture];
             traceNode.alpha = 0.05;
             traceNode.zPosition = spriteChild.zPosition;
             traceNode.zRotation = sprite.zRotation + spriteChild.zRotation;
             traceNode.position = [sprite convertPoint:spriteChild.position toNode:self.spriteHolder];
             [self.spriteHolder addChild:traceNode];
             [traceNode runAction:[SKAction fadeOutWithDuration:0.5] completion:^{[traceNode removeFromParent];}];
             }
             }
             */
            
        }
        //trace burn
        //if(self.rocket.bThrustForward){
        for(SKSpriteNode* sprite in [self.rocket children]){
            //add fading trace
            SKSpriteNode* traceNode = [SKSpriteNode spriteNodeWithTexture:sprite.texture];
            traceNode.alpha = 0.25;
            traceNode.zPosition = kDrawing1zPos;
            traceNode.zRotation = self.rocket.zRotation;
            traceNode.anchorPoint = sprite.anchorPoint;
            traceNode.position = [self.rocket convertPoint:sprite.position toNode:self.spriteHolder];
            [self.spriteHolder addChild:traceNode];
            [traceNode runAction:[SKAction fadeOutWithDuration:1.0] completion:^{[traceNode removeFromParent];}];
        }
        // }
    }
    
    
#endif
    
    //physics for enemyArtilary
    for(CSMEnemyArtilary* ea in artilaryRegister)
        [ea doPhysics:timeSinceLast];
    
    //turn rocket
    [self.spinControl turn:timeSinceLast];
    self.rocket.zRotation = self.spinControl.zRotation;
    
    //move & accelerate rocket
    if(self.rocket.bThrustForward){
        /*
         [self.rocket.physicsBody applyForce:CGVectorMake(
         timeSinceLast * kRocketAcceleration * self.spriteHolder.xScale * -sinf(self.rocket.zRotation),
         timeSinceLast * kRocketAcceleration * self.spriteHolder.yScale * cosf(self.rocket.zRotation))];
         */
        
        [self.rocket.physicsBody applyForce:CGVectorMake(
                                                         0.017 * kRocketAcceleration * self.spriteHolder.xScale * -sinf(self.rocket.zRotation),
                                                         0.017 * kRocketAcceleration * self.spriteHolder.yScale * cosf(self.rocket.zRotation))];
        
    }
    
    
    
    //fire
    static NSTimeInterval lastShotTime;
#ifdef constantFire
    if(true){
#endif
#ifndef constantFire
        if(self.rocket.bFire){
#endif
            CFTimeInterval timeSinceLastshot = currentTime - lastShotTime;
            if(timeSinceLastshot > kFireFrequency){
                [self addBullet:self.rocket.position direction:self.rocket.zRotation];
                lastShotTime = currentTime;
            }
        }
    }
    
    -(void)didSimulatePhysics
    {
        
        CGFloat newX = self.spriteHolder.position.x;
        CGFloat newY = self.spriteHolder.position.y;
        
        if( (self.rocket.position.x > scrollBoxScaled.minX) && (self.rocket.position.x < scrollBoxScaled.maxX) ){
            newX = -self.rocket.position.x * self.spriteHolder.xScale;
        }
        if( (self.rocket.position.y > scrollBoxScaled.minY) && (self.rocket.position.y < scrollBoxScaled.maxY) ){
            newY = -self.rocket.position.y * self.spriteHolder.yScale;
        }
        
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
    
    -(void)didBeginContact:(SKPhysicsContact *)contact{
        
        //NSLog(@"CONTACT %@ with %@", contact.bodyA.node, contact.bodyB.node);
        //NSLog(@"%i with %i", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask);
        
        //bullet collisions
        if (contact.bodyA.categoryBitMask & categoryBullet || contact.bodyB.categoryBitMask & categoryBullet)
        {
            
            SKPhysicsBody *bulletBody = (contact.bodyA.categoryBitMask & categoryBullet) ? contact.bodyA : contact.bodyB;
            SKPhysicsBody *otherSpriteBody = (contact.bodyA.categoryBitMask & categoryBullet) ? contact.bodyB : contact.bodyA;
            
            //enemies explode
            if(otherSpriteBody.categoryBitMask & (categoryEnemy | categoryEnemyArtilary)){
                
                //self.score += 1;
                [self.rocket addtoHealth:2];
                if([self.healthIndicator increaseHealthTo:((CGFloat)[self.rocket getHealth] / 100.0)]){
                    [self soundGlass];
                }
                
                if(otherSpriteBody.categoryBitMask & categoryEnemyArtilary){
                    otherSpriteBody.node.position = [otherSpriteBody.node.parent convertPoint:otherSpriteBody.node.position toNode:self.spriteHolder];
                    [self handleDestruction:bulletBody with:otherSpriteBody];
                    [artilaryRegister removeObject:otherSpriteBody.node];
                }
                else{
                    [self handleDestruction:bulletBody with:otherSpriteBody];
                }
                
            }
            
            else if(otherSpriteBody.categoryBitMask & categoryEnemyEgg){
                
                CSMEnemyEgg* egg = (CSMEnemyEgg*)otherSpriteBody.node;
                [self soundSplash];
                [egg hit];
                [bulletBody.node removeFromParent];
            }
            
            else{
                
                [self smallExplosion:bulletBody.node.position];
                [bulletBody.node removeFromParent];
            }
            
        }
        
        //scud collisions
        else if (contact.bodyA.categoryBitMask & categoryScud || contact.bodyB.categoryBitMask & categoryScud)
        {
            
            SKPhysicsBody *bulletBody = (contact.bodyA.categoryBitMask & categoryScud) ? contact.bodyA : contact.bodyB;
            SKPhysicsBody *otherSpriteBody = (contact.bodyA.categoryBitMask & categoryScud) ? contact.bodyB : contact.bodyA;
            //NSLog(@"bulletBody: %@", bulletBody.node.name);
            //NSLog(@"otherSpriteBody: %@", otherSpriteBody.node.name);
            //if(!otherSpriteBody)
            //  NSLog(@"otherSpriteBody: %@", otherSpriteBody.node);
            
            
            //enemies explode
            if(otherSpriteBody.categoryBitMask & (categoryEnemy)){
                
                [self handleDestruction:bulletBody with:otherSpriteBody];
            }
            else{
                
                [self smallExplosion:CGPointMake(
                                                 bulletBody.node.position.x,
                                                 bulletBody.node.position.y
                                                 )
                 ];
                [bulletBody.node removeFromParent];
            }
            
        }
        
        
        //rocket
        if (contact.bodyA.categoryBitMask & categoryRocket || contact.bodyB.categoryBitMask & categoryRocket){
            //wormhole
            if (contact.bodyA.categoryBitMask & categoryWormhole || contact.bodyB.categoryBitMask & categoryWormhole){
                [self soundWistleup];
                if(contact.bodyA.categoryBitMask & categoryWormhole)
                    [self levelCompleted:[contact.bodyA.node.parent convertPoint:contact.bodyA.node.position toNode:self.spriteHolder]];
                else
                    [self levelCompleted:[contact.bodyB.node.parent convertPoint:contact.bodyB.node.position toNode:self.spriteHolder]];
            }
            else{
                [self.rocket addtoHealth:-10];
                [self.rocket showDistress];
                [self soundDamange];
                [self.healthIndicator reduceHealthTo:((CGFloat)[self.rocket getHealth] / 100.0)];
                if([self.rocket getHealth] <= 0){
                    [self explosion:self.rocket.position];
                    [self.rocket removeFromParent];
                    [self levelFailed];
                    
                }
            }
        }
        
        self.hud.text = [NSString stringWithFormat:@":%i", self.score];
        
    }
    
    
#pragma mark ============================= game steps ===============================
    
    -(void)levelCompleted:(CGPoint)location{
        
        if(gameOver)
            return;
        
        gameOver = YES;
        self.rocket.bFire = NO;
        
        //check if this is last level
        BOOL bLastLevel = NO;
        if([[self.currentLevel getLevelNumber] intValue] == [self.gameData numberOfLevels]){
            bLastLevel = YES;
        }
        
        
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
        
        CGPoint scorePos = CGPointMake(55, 5);
        //CGPoint plusPos = CGPointMake(-30, 30);
        CGPoint bonusPos = CGPointMake(55, 5);;
        CGPoint totalScorePos = CGPointMake(55, 5);
        CGPoint tickPos = CGPointMake(-30, 0);
        
        
        CGPoint menuButtonPos = CGPointMake(55, -45);//(10, -45);
        CGPoint playButtonPos = CGPointMake(100, -45);//(45, -10);
        CGPoint gameCenterButtonPos = CGPointMake(10, -45);
        
        SKSpriteNode* levelCompleteDisplay = [[SKSpriteNode alloc] initWithColor:[[SKColor alloc]initWithWhite:1.0 alpha:0.5]
                                                                            size:CGSizeMake(250, 150)];
        /*
         SKSpriteNode* levelCompleteDisplay = [[SKSpriteNode alloc] initWithColor:[[SKColor alloc]initWithWhite:1.0 alpha:0.7]                                                                        size:CGSizeMake(self.frame.size.width, self.frame.size.height + 60)];
         */
        levelCompleteDisplay.position = CGPointMake(0, 30);
        levelCompleteDisplay.zPosition = kIcon1zPos;
        
        ButtonSprite *tick;
        if(bLastLevel){
            tick = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"bigtick.png"]
                                                  scene:self
                                                   type:kLevelMenu];
        }
        else{
            tick = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"bigtick.png"]
                                                  scene:self
                                                   type:kPlayNextLevel];
        }
        // SKSpriteNode* tick = [SKSpriteNode spriteNodeWithImageNamed:@"bigtick.png"];
        //tick.position = tickPos;
        
        //main score
        SKLabelNode* mainScoreLabel = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
        // mainScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        mainScoreLabel.fontSize = 25;
        mainScoreLabel.fontColor = [UIColor iconBlue];
        mainScoreLabel.text = [NSString stringWithFormat:@"%i", self.score];
        mainScoreLabel.position = [self convertPoint:label2Pos toNode:levelCompleteDisplay];
        mainScoreLabel.alpha = 0.0;
        
        
        SKSpriteNode* mainScoreBackground = [SKSpriteNode spriteNodeWithImageNamed:@"whitespot.png"];
        //mainScoreBackground.position = CGPointMake(7, 10);
        if(self.score > 9){
            mainScoreBackground.xScale = 2.0;
            //mainScoreBackground.position = CGPointMake(mainScoreBackground.position.x+10, mainScoreBackground.position.y);
        }
        if(self.score > 99){
            mainScoreBackground.xScale = 3.0;
            // mainScoreBackground.position = CGPointMake(mainScoreBackground.position.x+20, mainScoreBackground.position.y);
        }
        [mainScoreLabel addChild:mainScoreBackground];
        mainScoreBackground.zPosition = -1;
        
        
        ButtonSprite* playButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconPlay.png"]
                                                                  scene:self
                                                                   type:kPlayNextLevel];
        ButtonSprite* menuButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconMenu.png"]
                                                                  scene:self
                                                                   type:kLevelMenu];
        
        
        playButton.position = playButtonPos;
        menuButton.position = menuButtonPos;
        menuButton.xScale = 0.8;
        menuButton.yScale = 0.8;
        
        
        [levelCompleteDisplay addChild:tick];
        [levelCompleteDisplay addChild:mainScoreLabel];
        [levelCompleteDisplay addChild:menuButton];
        if(!bLastLevel){
            [levelCompleteDisplay addChild:playButton];
        }
        
        
        if([self.gameData gameCenterEnabled]){
            ButtonSprite* gameCenterButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"gameCenterControlSmall.png"]
                                                                            scene:self
                                                                             type:kGameCenter];
            gameCenterButton.position = gameCenterButtonPos;
            [levelCompleteDisplay addChild:gameCenterButton];
        }
        
        
        SKAction* zoom = [SKAction scaleTo:1.0 duration:0.5];
        levelCompleteDisplay.xScale = 0.05;
        levelCompleteDisplay.yScale = 0.05;
        [self addChild:levelCompleteDisplay];
        [levelCompleteDisplay runAction:zoom];
        
        //bonus animation
        
        //life bonus
        //int lifeBonus = [self.rocket getHealth] * [[self.currentLevel getLevelNumber] intValue] / 100;
        int lifeBonus = [self.rocket getHealth] / 5;
        SKLabelNode* lifeBonusText = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
        lifeBonusText.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        lifeBonusText.fontSize = 25;
        lifeBonusText.fontColor = [UIColor iconBlue];
        lifeBonusText.text = [NSString stringWithFormat:@"%i", lifeBonus];
        lifeBonusText.zPosition = kIcon2zPos;
        lifeBonusText.position = lifeBonusNodePos;
        lifeBonusText.xScale = 0.0;
        lifeBonusText.yScale = 0.0;
        
        SKSpriteNode* lifeBonusBackground = [SKSpriteNode spriteNodeWithImageNamed:@"whitespot.png"];
        lifeBonusBackground.position = CGPointMake(7, 10);
        if(lifeBonus > 9){
            lifeBonusBackground.xScale = 2.0;
            lifeBonusBackground.position = CGPointMake(lifeBonusBackground.position.x+10, lifeBonusBackground.position.y);
        }
        if(lifeBonus > 99){
            lifeBonusBackground.xScale = 3.0;
            lifeBonusBackground.position = CGPointMake(lifeBonusBackground.position.x+20, lifeBonusBackground.position.y);
        }
        [lifeBonusText addChild:lifeBonusBackground];
        lifeBonusBackground.zPosition = -1;
        [levelCompleteDisplay addChild:lifeBonusText];
        
        
        //plus
        /*
         SKLabelNode* plusNode = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
         plusNode.fontSize = 40;
         plusNode.fontColor = [UIColor iconBlue];
         plusNode.text = [NSString stringWithFormat:@"+"];
         plusNode.zPosition = kIcon2zPos;
         plusNode.position = plusPos;
         plusNode.xScale = 0.0;
         plusNode.yScale = 0.0;
         [levelCompleteDisplay addChild:plusNode];
         */
        
        
        //total score
        int totalScore = self.score + lifeBonus;
        [self.gameData completedlevel:[[self.currentLevel getLevelNumber] intValue]  withScore:totalScore];
        SKLabelNode* totalScoreNode = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
        totalScoreNode.fontSize = 40;
        totalScoreNode.fontColor = [UIColor iconBlue];
        totalScoreNode.text = [NSString stringWithFormat:@"%i", totalScore];
        totalScoreNode.zPosition = kIcon2zPos;
        totalScoreNode.position = totalScorePos;
        totalScoreNode.xScale = 0.0;
        totalScoreNode.yScale = 0.0;
        [levelCompleteDisplay addChild:totalScoreNode];
        
        
        [lifeBonusText runAction:[SKAction sequence:@[
                                                      [SKAction waitForDuration:0.5],
                                                      [SKAction scaleTo:1.0 duration:0.5],
                                                      [SKAction waitForDuration:0.3],
                                                      [SKAction moveTo:bonusPos duration:0.7],
                                                      [SKAction group:@[[SKAction fadeOutWithDuration:0.2],
                                                                        [SKAction scaleTo:0.0 duration:0.2]
                                                                        ]
                                                       ]
                                                      ]]];
        [lifeBonusBackground runAction:[SKAction sequence:@[
                                                            [SKAction waitForDuration:1.3],
                                                            [SKAction fadeOutWithDuration:0.7]
                                                            ]]
         ];
        
        /*
         [plusNode runAction:[SKAction sequence:@[
         [SKAction waitForDuration:1.3],
         [SKAction scaleTo:1.0 duration:0.7],
         [SKAction waitForDuration:1.5],
         [SKAction fadeOutWithDuration:1.5]
         ]]
         ];
         */
        
        [self.hud runAction:[SKAction sequence:@[
                                                 [SKAction waitForDuration:0.5],
                                                 [SKAction fadeOutWithDuration:0.5]
                                                 ]
                             ]
         ];
        
        [mainScoreLabel runAction:[SKAction sequence:@[
                                                       [SKAction waitForDuration:0.5],
                                                       [SKAction fadeInWithDuration:0.5],
                                                       [SKAction waitForDuration:0.3],
                                                       [SKAction moveTo:scorePos duration:0.7],
                                                       [SKAction group:@[[SKAction fadeOutWithDuration:0.2],
                                                                         [SKAction scaleTo:0.0 duration:0.2]
                                                                         ]
                                                        
                                                        ]
                                                       ]]];
        [mainScoreBackground runAction:[SKAction sequence:@[
                                                            [SKAction waitForDuration:1.3],
                                                            [SKAction fadeOutWithDuration:0.7]
                                                            ]]
         ];
        
        [totalScoreNode runAction:[SKAction sequence:@[
                                                       [SKAction waitForDuration:2.0],
                                                       [SKAction scaleTo:1.0 duration:0.3]
                                                       ]]
         ];
        
        tick.position = tickPos;
        [self.backControl runAction:[SKAction fadeOutWithDuration:0.7]];
        
        [self fadeControls];
        
        ///celebrate game completion
        if([self.gameData gameComplete]){
            [self celebrate];
            /*
             SKAction* celebrate = [SKAction sequence:@[
             [SKAction waitForDuration:1.0],
             
             [SKAction repeatActionForever:[SKAction sequence:@[
             [SKAction runBlock:^{ [self nextExplosion:levelCompleteDisplay]; }],
             [SKAction waitForDuration:0.07]
             ]]],
             ]];
             [levelCompleteDisplay runAction:celebrate];
             */
        }
        
        
    }
    
    -(void)levelFailed{
        
        if(gameOver)
            return;
        
        gameOver = YES;
        self.rocket.bFire = NO;
        
        
        CGPoint crossPos = CGPointMake(-30, 0);
        CGPoint menuButtonPos = CGPointMake(100, 0);//(10, -45);
        CGPoint playButtonPos = CGPointMake(100, -45);//(45, -10);
        CGPoint gameCenterButtonPos = CGPointMake(100, 45);
        
        
        SKSpriteNode* levelCompleteDisplay = [[SKSpriteNode alloc] initWithColor:[[SKColor alloc]initWithWhite:1.0 alpha:0.5]
                                                                            size:CGSizeMake(300, 180)];
        levelCompleteDisplay.position = CGPointMake(0, 30);
        levelCompleteDisplay.zPosition = kIcon1zPos;
        
        ButtonSprite *cross = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"bigcross.png"]
                                                             scene:self
                                                              type:kReplayLevel];
        //SKSpriteNode* cross = [SKSpriteNode spriteNodeWithImageNamed:@"bigcross.png"];
        
        ButtonSprite* playButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconReplay.png"]
                                                                  scene:self
                                                                   type:kReplayLevel];
        ButtonSprite* menuButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconMenu.png"]
                                                                  scene:self
                                                                   type:kLevelMenu];
        
        
        menuButton.position = menuButtonPos;
        playButton.position = playButtonPos;
        cross.position = crossPos;
        
        [levelCompleteDisplay addChild:cross];
        [levelCompleteDisplay addChild:menuButton];
        [levelCompleteDisplay addChild:playButton];
        
        if([self.gameData gameCenterEnabled]){
            ButtonSprite* gameCenterButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"gameCenterControlSmall.png"]
                                                                            scene:self
                                                                             type:kGameCenter];
            gameCenterButton.position = gameCenterButtonPos;
            [levelCompleteDisplay addChild:gameCenterButton];
        }
        
        
        SKAction* zoom = [SKAction scaleTo:1.0 duration:0.25];
        levelCompleteDisplay.xScale = 0.0;
        levelCompleteDisplay.yScale = 0.0;
        [self addChild:levelCompleteDisplay];
        //[levelCompleteDisplay runAction:zoom];
        
        
        
        [levelCompleteDisplay runAction:[SKAction sequence:@[
                                                             [SKAction waitForDuration:0.5],
                                                             zoom
                                                             ]]
         ];
        
        [self fadeControls];
        
        
    }
    
    -(void)nextLevel{
        
        int currentLevelNo = [[self.currentLevel getLevelNumber] intValue];
        [self.gameData openGamePlayLevel:++currentLevelNo fromScene:self];
    }
    
    -(void)reloadLevel{
        
        [self.gameData openGamePlayLevel:[[self.currentLevel getLevelNumber] intValue] fromScene:self];
    }
    
    -(void)pauseGame{
        
        static BOOL p = NO;
        
        
        if(self.spriteHolder.paused == YES){
            self.gameNode.paused = NO;
            //self.view.paused = NO;
            //p = NO;
            pauseButton.texture = [SKTexture textureWithImageNamed:@"IconPause.png"];
            //self.spriteHolder.paused = NO;
            
        }
        else{
            self.gameNode.paused = YES;
            //self.view.paused = YES;
            p = YES;
            pauseButton.texture = [SKTexture textureWithImageNamed:@"IconPlay.png"];
            //self.spriteHolder.paused = YES;
        }
        
        [self.view setNeedsDisplay];
        
        //[self.gameData pauseGame];
    }
    
#pragma mark ============================= User input ===============================
    
    -(void)buttonTouched:(ButtonType)button{
        switch (button) {
            case kThrustForward:
                [self animateThrust:YES];
                self.rocket.bThrustForward = YES;
                if(!soundingThrust){
                    //[self.rocket runAction:thrustSound];
                    soundingThrust = YES;
                }
                break;
            case(kFire):
                self.rocket.bFire = YES;
                break;
            default:
                break;
                
        }
    }
    
    -(void)buttonReleased:(ButtonType)button{
        NSLog(@"\n\n\n\nGamePlayScene button released :%i", button);
        
        switch (button) {
            case kThrustForward:
                [self stopThrustAnimation:YES];
                self.rocket.bThrustForward = NO;
                //[self.rocket removeAllActions];
                soundingThrust = NO;
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
            case kPlayFirstLevel:
                self.gameData.demoWatched = YES;
                [self.gameData openGamePlayLevel:1 fromScene:self];
                break;
            case kReplayLevel:
                [self reloadLevel];
                break;
            case kLevelMenu:
                [self openMenu];
                break;
            case kGameCenter:
                //NSLog(@"gameCenter control released");
                [self.gameData showLeaderboard];
                break;
            case kPlayDemo:
                [self.gameData openDemoLevelFromScene:self];
                break;
            case kFpsUp:
                [self changeFps:YES];
                break;
            case kFpsDown:
                [self changeFps:NO];
                break;
            case kPause:
                [self pauseGame];
                break;
            default:
                NSLog(@"unrecognised button released: %i", button);
                break;
        }
    }
    
    -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
        
        //to resolve iOS9 bug
        // [self checkForButtonTouchesBegan:touches withEvent:event];
        
        NSSet *allTouches = [event allTouches];
        
        //NSLog(@"%lu SCENE TOUCHES", (unsigned long)[allTouches count]);
        
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
        
        //to resolve iOS9 bug
        // [self checkForButtonTouchesMoved:touches withEvent:event];
        
        [self touchesMovedActions:touches withEvent:event];
    }
    
    -(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
        //[self checkForButtonTouchesEnded:touches withEvent:event];
        [self touchesMovedActions:touches withEvent:event];
    }
    
    -(void)touchesMovedActions:(NSSet *)touches withEvent:(UIEvent *)event{
        NSSet *allTouches = [event allTouches];
        
        //NSLog(@"%lu SCENE TOUCHES", (unsigned long)[allTouches count]);
        
        //check for pinch
        if(([allTouches count] == 2) && !( self.rocket.bThrustForward || self.rocket.bFire || self.spinControl.bTouch ) ){
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
    
    -(void)checkForButtonTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
        
        NSLog(@"checkforButtonTouchesBegan");
        
        [self printTouches:touches withEvent:event];
        NSSet *allTouches = [event allTouches];
        
        for(UITouch *touch in [allTouches allObjects]){
            if( CGRectContainsPoint(self.spinControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"touch began on spinControl");
                /*
                 for(UITouch *touch in [allTouches allObjects]){
                 CGPoint p = [touch locationInNode:self];
                 if(( ((p.x * p.x) + (p.y * p.y)) <= controlRadius * controlRadius)){
                 NSSet *touchSet = [[NSSet alloc]initWithObjects:touch, nil];
                 [self processTouches:touchSet withEvent:event];
                 }
                 }
                 */
                [self.spinControl touchesBegan:touches withEvent:event];
            }
            if ( CGRectContainsPoint(self.thrustForwardControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"touch began on thrustControl");
                [self buttonTouched:kThrustForward];
            }
            if ( CGRectContainsPoint(self.fireControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"touch began on fireControl");
                [self buttonTouched:kFire];
            }
        }
    }
    
    -(void)checkForButtonTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
        [self printTouches:touches withEvent:event];
        NSSet *allTouches = [event allTouches];
        
        for(UITouch *touch in [allTouches allObjects]){
            if( CGRectContainsPoint(self.spinControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"touch moved on spinControl");
                [self.spinControl touchesMoved:touches withEvent:event];
            }
        }
    }
    
    -(void)checkForButtonTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
        [self printTouches:touches withEvent:event];
        NSSet *allTouches = [event allTouches];
        
        for(UITouch *touch in [allTouches allObjects]){
            if( CGRectContainsPoint(self.spinControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"touch ended on spinControl");
                [self.spinControl touchesEnded:touches withEvent:event];
            }
            if ( CGRectContainsPoint(self.thrustForwardControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"touch ended on thrustControl");
                [self buttonReleased:kThrustForward];
            }
            if ( CGRectContainsPoint(self.fireControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"touch ended on fireControl");
                [self buttonReleased:kFire];
            }
        }
    }
    
    -(void)printTouches:(NSSet *)touches withEvent:(UIEvent *)event{
        
        NSLog(@"----------------------Touches---------------");
        
        NSSet *allTouches = [event allTouches];
        NSLog(@"%lu TOUCHES", (unsigned long)[allTouches count]);
        
        for(UITouch *touch in [allTouches allObjects]){
            if( CGRectContainsPoint(self.spinControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"spinControl");
            }
            if ( CGRectContainsPoint(self.thrustForwardControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"thrustControl");
            }
            if ( CGRectContainsPoint(self.fireControl.frame, [touch locationInNode:self] ) ){
                NSLog(@"fireControl");
            }
        }
        
        NSLog(@"------------------------------------------------");
    }
    
    
    
    
    -(void)utilityPressed{
    }
    
#pragma mark ========================== helpers ================
    
    -(void)animateThrust:(BOOL)forward{
#ifdef constantThrust
        
        if(forward && firstTimeThrust){
            firstTimeThrust = NO;
#endif
#ifndef constantThrust
            if(forward){
#endif
                [self.rocket addChild:self.rocketBurnSprites[0]];
                [self.rocket addChild:self.rocketBurnSprites[1]];
                [self.rocketBurnSprites[0] runAction:self.fuelBurnAnimation];
                //delay one rocket a moment
                [self.rocketBurnSprites[1] runAction:[SKAction sequence:@[[SKAction waitForDuration:animationFrameLength], self.fuelBurnAnimation]]];
                
            }
            /*
             else{
             [self.rocket addChild:self.rocketBurnSprites[2]];
             [self.rocket addChild:self.rocketBurnSprites[3]];
             [self.rocketBurnSprites[2] runAction:self.fuelBurnAnimation];
             //delay one rocket a moment
             [self.rocketBurnSprites[3] runAction:[SKAction sequence:@[[SKAction waitForDuration:animationFrameLength], self.fuelBurnAnimation]]];
             }
             */
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
            
            
            if (bNeedToScalePhysicsBodies){
                [self rescalePhysicsBodies:newScale];
            }
            else{
                for(CSMSpriteNode* sprite in [self.spriteHolder children]){
                    if(sprite.physicsBody){
                        sprite.physicsBody.velocity = CGVectorMake(
                                                                   sprite.physicsBody.velocity.dx * newScale/self.spriteHolder.xScale,
                                                                   sprite.physicsBody.velocity.dy * newScale/self.spriteHolder.yScale
                                                                   );
                    }
                }
                
            }
            self.spriteHolder.xScale = newScale;
            self.spriteHolder.yScale = newScale;
            
            
            [self positionSpriteHolder];
            
            
            
        }
        
        -(void)rescalePhysicsBodies:(CGFloat)newScale{
            //NSLog(@"rescalePhysicsBodies");
            
            CGFloat scaleChange = newScale / self.spriteHolder.xScale;
            
            
            for(CSMSpriteNode* sprite in [self.spriteHolder children]){
                
                sprite.physicsBody.velocity = CGVectorMake(
                                                           sprite.physicsBody.velocity.dx * scaleChange,
                                                           sprite.physicsBody.velocity.dy * scaleChange
                                                           );
                
                if(sprite.physicsBody){
                    //NSLog(@"rescale %@", sprite.name);
                    CGFloat mass = sprite.physicsBody.mass;
                    CGVector vel = sprite.physicsBody.velocity;
                    if([sprite isKindOfClass:[CSMSpriteNode class]]){
                        //NSLog(@"1");
                        [sprite providePhysicsBodyToScale:newScale];
                    }
                    else{
                        //NSLog(@"2");
                        SKPhysicsBody* oldBody = sprite.physicsBody;
                        sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(sprite.size.width/2 * scaleChange)];
                        
                        
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
            
            //resize boundary
            CGRect newBoundary = CGRectMake(
                                            -tools.kFieldSize.width/2 * newScale,
                                            -tools.kFieldSize.height/2 * newScale,
                                            tools.kFieldSize.width * newScale,
                                            tools.kFieldSize.height * newScale
                                            );
            
            self.spriteHolder.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:newBoundary];
            self.spriteHolder.physicsBody.categoryBitMask = categorySpriteHolder;//spriteHolderCategory;
            self.spriteHolder.physicsBody.contactTestBitMask = spriteHolderCollisions;
            
            
        }
        
        -(void)fadeControls{
            CGFloat fadeDuration = 0.7;
            [self.spinControl runAction:[SKAction fadeOutWithDuration:fadeDuration]];
            [self.thrustForwardControl runAction:[SKAction fadeOutWithDuration:fadeDuration]];
            [self.fireControl runAction:[SKAction fadeOutWithDuration:fadeDuration]];
            self.spinControl.userInteractionEnabled = NO;
            self.thrustForwardControl.userInteractionEnabled = NO;
            self.fireControl.userInteractionEnabled = NO;
        }
        
        -(void)handleDestruction:(SKPhysicsBody*)a with:(SKPhysicsBody*)b{
            
            //some contacts have null nodes. Check for null nodes before calculation explosion position.
            
            CGPoint p = (a.node && b.node) ? CGPointMake(
                                                         (a.node.position.x + b.node.position.x)/2,
                                                         (a.node.position.y + b.node.position.y)/2
                                                         )
            :
            ( a.node ? a.node.position : b.node.position );
            
            [self explosion:p];
            
            [a.node removeFromParent];
            [b.node removeFromParent];
        }
        /*
         -(void)nextExplosion:(SKSpriteNode*)displayNode{
         
         static BOOL firstTime = YES;
         static CGPoint pos;
         //static int edge = 0;
         
         if (firstTime){
         //NSLog(@"1");
         pos = CGPointMake(0.0, displayNode.size.height/2);
         firstTime = NO;
         }
         else if(pos.y == displayNode.size.height/2){
         //NSLog(@"2");
         if ( (pos.x + 20) <= (displayNode.size.width/2) ){
         pos = CGPointMake(pos.x+20, pos.y);
         }
         else{
         pos = CGPointMake(displayNode.size.width/2, displayNode.size.height/2-1);
         }
         }
         //right edge
         else if (pos.x == displayNode.size.width/2){
         //NSLog(@"3");
         if( (pos.y - 20) >= -displayNode.size.height/2){
         pos = CGPointMake(pos.x, pos.y - 20);
         }
         else{
         pos = CGPointMake(displayNode.size.width/2-1, -displayNode.size.height/2);
         }
         }
         //bottom edge
         else if(pos.y == -displayNode.size.height/2){
         //NSLog(@"4");
         if( (pos.x - 20) >= (-displayNode.size.width/2)){
         pos = CGPointMake(pos.x-20, pos.y);
         }
         else{
         pos = CGPointMake(-displayNode.size.width/2, -displayNode.size.height/2+1);
         }
         }
         //left edge
         else if(pos.x == -displayNode.size.width/2){
         //NSLog(@"5");
         if( (pos.y + 20) <= displayNode.size.height/2){
         pos = CGPointMake(pos.x, pos.y + 20);
         }
         else{
         pos = CGPointMake(-displayNode.size.width/2+1, displayNode.size.height/2);
         }
         }
         
         //NSLog(@"pos: %f, %f", pos.x, pos.y);
         
         //add explosion
         SKSpriteNode* explosion = [[SKSpriteNode alloc]initWithTexture:self.smallExplosionTextures[0]];
         explosion.position = pos;
         //explosion.zPosition = kDrawing1zPos;
         [displayNode addChild:explosion];
         [explosion runAction:self.explosionAnimation completion:^{
         [explosion removeFromParent];
         }];
         
         //[self soundExplosion];
         
         }
         */
        -(void)celebrate{
            NSLog(@"celebrate");
            SKAction* celebrate = [SKAction sequence:@[
                                                       [SKAction waitForDuration:1.0],
                                                       
                                                       [SKAction repeatActionForever:[SKAction sequence:@[
                                                                                                          [SKAction runBlock:^{
                
                SKSpriteNode* explosion = [[SKSpriteNode alloc]initWithTexture:self.smallExplosionTextures[0]];
                explosion.position = CGPointMake(
                                                 ( ((float)rand() / RAND_MAX) * self.frame.size.width ) - self.frame.size.width/2,
                                                 ( ((float)rand() / RAND_MAX) * self.frame.size.height ) - self.frame.size.height/2
                                                 );
                explosion.zPosition = kDrawing3zPos;
                [self.gameNode addChild:explosion];
                [explosion runAction:self.explosionAnimation completion:^{
                    [explosion removeFromParent];
                }];
            }],
                                                                                                          [SKAction waitForDuration:0.005]
                                                                                                          ]]],
                                                       ]];
            [self.gameNode runAction:celebrate];
        }
        
#pragma mark ========================== interactions =============
        
        -(void)openMenu{
            [self.gameData openMenuFromScene:self];
            
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
        
        -(void)clearReferences{
            [super clearReferences];
            
            self.spinControl = nil;
            self.fuelBurnAnimation = nil;
            self.rocketBurnTextures = nil;
            self.thrustForwardControl = nil;
            self.fireControl = nil;
            self.rocketBurnSprites = nil;
            self.enemyTexture = nil;
            self.hud = nil;
            
            self.currentLevel = nil;
            self.gameData = nil;
            
            self.sThrustSoundAction = nil;
            self.sFireSoundAction = nil;
            self.sExplosionAction = nil;
            self.sExplosionSmallAction = nil;
            self.healthIndicator = nil;
            self.levelLabel = nil;
            self.levelsLibrary = nil;
            self.explosionTextures = nil;
            self.smallExplosionTextures = nil;
            self.explosionAnimation = nil;
            self.smallExplosionAnimation = nil;
        }
        
        
        @end
