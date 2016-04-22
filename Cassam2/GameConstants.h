//
//  GameConstants.h
//  Cassam2
//
//  Created by The Cowans on 17/12/2013.
//  Copyright (c) 2013 RNC. All rights reserved.
//


//reset atlas - life indicator

//music control -volControl -off


//-----------------------------
//define for the game
#define traceMovement YES
//#define compileWithGameKit YES
//#define levelsLocked YES

//-----------------------------
//define for testing and development
//#define compileWithBuildModule YES
//#define frameRateSwitches YES
//#define constantThrust YES
//#define constantFire YES
//#define highlightTouches YES


#ifndef Cassam2_GameConstants_h
#define Cassam2_GameConstants_h

#define utilityButtonPos CGPointMake( self.frame.size.width/2 - 50 , 0);

//template scene
#define settingsButtonPos CGPointMake(-self.frame.size.width/2 + 30, self.frame.size.height/2 - 30);
#define topRightLabelPos CGPointMake(self.frame.size.width/2 - 30, self.frame.size.height/2 - 30);
#define iconBlue colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0
#define kStandardFieldSize CGSizeMake(2400, 1600)

static CGFloat kControlAlpha = 0.9;
static CGFloat kSurfacezPos = 10;
static CGFloat kPaperzPos = 20;
static CGFloat kDrawing1zPos = 30;
static CGFloat kDrawing2zPos = 40;
static CGFloat kDrawing3zPos = 50;
static CGFloat kSolidObjzPos = 60;
static CGFloat kIcon1zPos = 70;
static CGFloat kIcon2zPos = 80;
static CGFloat kIcon3zPos = 90;
static CGFloat kTopPos = 100;

#define SCENE_CHANGE_DURATION 0.6


//MenuScene
#define levelRows 3
#define outerMargin 50
#define iconSpace 80
#define levelIconSpace 80

#define MUSIC_ACKNO_STRING @"music by Hugh Mitchell"
#define MUSIC_LINK_URL_STRING @"http://www.hughmitchell.co.uk"
#define GAME_ACKNO_STRING @"game by Dave Cowan"
//#define MUSIC_LINK_URL_STRING @"http://www.roughrocket.com"


static CGFloat kRocketAcceleration = 1000.0;
static CGFloat kFireFrequency = 0.2;
static CGFloat kMissileLaunchImpulse = 1.0;
static CGFloat kEnemyMissileLaunchImpulse = 0.3;
static CGFloat kFriction = 0.0;
static CGFloat kLinearDamping = 0.0;
static CGFloat kAngularDamping = 0.0;
static CGFloat kbulletPojection = 50.0;

//GamePlay scene
#define kgameplaymargin 80.0

#define pauseButtonPos CGPointMake( self.frame.size.width/2 - 100 , self.frame.size.height/2 -20)

#define spinControlPos CGPointMake( self.frame.size.width/2 - 50 , -self.frame.size.height/2 + 50)
#define thrustForwardPos CGPointMake( -self.frame.size.width/2 + 45 , -self.frame.size.height/2 + 45)
#define fireButtonPos CGPointMake( -self.frame.size.width/2 + 45 , -self.frame.size.height/2 + 135)

#define spinControlPos2 CGPointMake( self.frame.size.width/2 - 60 , -self.frame.size.height/8)
#define thrustForwardPos2 CGPointMake( -self.frame.size.width/2 + 60 , -self.frame.size.height/8)
#define fireButtonPos2 CGPointMake( -self.frame.size.width/2 + 60 , -self.frame.size.height/8 + 85)

#define controlRadius 80.0

#define healthIndicatorPos CGPointMake( self.frame.size.width/2 - 30 , self.frame.size.height/2 - 80)
//#define healthIndicatorPos2 CGPointMake( self.frame.size.width/2 - 40 , self.frame.size.height/8 -80)//+ 200)
#define healthIndicatorPos2 CGPointMake( self.frame.size.width/2 - 40 , self.frame.size.height/2 -80)//+ 200)
#define queryPos CGPointMake( self.frame.size.width/2 - 70 , self.frame.size.height/2 -30 )

#define lifeBonusNodePos CGPointMake( self.frame.size.width/2 - 44 , -self.frame.size.height/2 + 140)
#define label1Pos CGPointMake( self.frame.size.width/2 - 10 , self.frame.size.height/2 -20)
#define label2Pos CGPointMake( self.frame.size.width/2 - 10 , self.frame.size.height/2 -50)
#define startScale 0.5
#define rfburnPos CGPointMake(16, -32)
#define lfburnPos CGPointMake(-16, -32)
#define rrburnPos CGPointMake(16, 13)
#define lrburnPos CGPointMake(-20, 13)
#define animationFrameLength 0.1
#define spinStep M_PI * 4
#define maxScale 1.0
//#define minScale 0.2
#define kEnemyAcceleration 100.0
#define kEnemyEggLife 5
#define kSoundDistance 1000

typedef enum : uint32_t {
    categoryBullet = 1,
    categoryRocket = 2,
    categoryEnemy = 4,
    categoryEdge = 8,
    categoryAstroid= 16,
    categoryWormhole = 32,
    categorySpriteHolder = 64,
    categorySolidObject = 128,
    categoryEnemyArtilary = 256,
    categoryScud = 512,
    categoryEnemyEgg = 1024
} category;

#define bulletCollisions 0
#define rocketCollisions categoryEnemy | categoryAstroid | categorySpriteHolder | categorySolidObject | categoryEnemyArtilary | categoryEnemyEgg
#define enemyCollisions categoryAstroid | categoryRocket | categorySpriteHolder | categoryEnemy | categorySolidObject | categoryEnemyArtilary | categoryEnemyEgg
#define spriteHolderCollisions 0
#define astroidCollisions 0
#define wormholeCollisions 0
#define solidObjectCollisions 0
#define enemyArtilaryCollisions 0
#define scudCollisions 0
#define enemyEggCollisions 0

#define bulletContacts categorySpriteHolder | categoryRocket | categoryEnemy | categoryAstroid | categorySolidObject | categoryEnemyArtilary | categoryEnemyEgg
#define rocketContacts categoryWormhole | categoryEnemy | categoryAstroid | categoryEnemyEgg
#define enemyContacts 0
#define spriteHolderContacts 0
#define astroidContacts 0
#define wormholeContacts 0
#define solidObjectContacts 0
#define enemyArtilaryContacts 0
#define scudContacts categorySpriteHolder | categoryRocket | categoryEnemy | categoryAstroid | categorySolidObject | categoryEnemyArtilary | categoryEnemyEgg
#define enemyEggContacts 0


//gameplay values
#define rocketFullHealth 100

//CGFloat kcontrolRadius = 60;
//CGFloat kspinStep = 0.1;



//[tools turnToward]; enemyLogic

//confused about CGPoint properties in RocketSprite - can't access as expected, have had to declare private variable rather tnan property

static CGFloat kFieldSizeX = 2400;
static CGFloat kFieldSizeY = 1600;

typedef enum {
    kCHOOSE = 0,
    kBUILDING,
    kPLAYING,
} GameState;


typedef enum {
    kFire = 0,
    kThrustForward,
    kThrustReverse,
    kBack,
    kBuild,
    kPlay,
    kUtility,
    kAddEnemy,
    kAddEnemyArtilary,
    kAddEnemySpawnPoint,
    kAddEnemyEgg,
    kAddEraser,
    kAddSharpener,
    kAddPencilBlue,
    kAddPencilGreen,
    kAddPencilRed,
    kAddPencilBrown,
    kEnemySpawnRate,
    kAddRocket,
    kClosePanel1,
    kClosePanel2,
    kScrollAndZoom,
    kEditSprites,
    kSave,
    kAddLevel,
    kClearLevel,
    kAddAstroid2,
    kAddAstroid3,
    kAddWormHole,
    kAddNode,
    kAddAstroidLine,
    kClearSelection,
    kTrash,
    kRotate,
    kSpin,
    kSpriteSelection,
    kLevel,
    kPlayNextLevel,
    kReplayLevel,
    kLevelMenu,
    kDeleteLevel,
    kZoomOut,
    kZoomIn,
    kHorizontalEnlarge,
    kVerticalEnlarge,
    kNextLevel,
    kPreviousLevel,
    kQuery,
    kPlayDemo,
    kGameCenter,
    kFforward,
    kPlayFirstLevel,
    kFpsUp,
    kFpsDown,
    kMusicLink,
    kToggleSound,
    kPause
} ButtonType;

typedef enum{
    kBlank = 0,
    kRocket,
    kEnemy,
    kEnemySpawnPoint,
    kAstroid,
    kWormhole,
    kSharpener,
    kPencilBlue,
    kPencilRed,
    kPencilGreen,
    kPencilBrown,
    kEraser,
    kNode
} spriteType;

typedef enum{
    kCSMHeader = 0,
    kCSMLevel,
    kCSMSpriteNode,
    kCSMRocketSprite,
    kCSMSolidObject,
    kCSMEnemySpawnPoint,
    kCSMAsroidSprite,
    kCSMEnemySprite,
    kCSMEnemyEgg,
    kCSMEnemyArtilary,
    kCSMWormHoleSprite,
    kCSMNodeSprite
} dataType;


typedef enum{
    kScale = 0
} SliderType;

//structs for sprite data
/*
struct CGPoint {
    CGFloat x;
    CGFloat y;
};
typedef struct CGPoint CGPoint;
 */

struct CSMEnemySettings{
    CGPoint position;
    CGFloat rotation;
};
typedef struct CSMEnemySettings CSMEnemySettings;

struct CSMEnemySpawnPointSettings{
    CGPoint position;
    CGFloat spawnRate;
};
typedef struct CSMEnemySpawnPointSettings CSMEnemySpawnPointSettings;

struct CSMAstroidSettings{
    CGRect rect;
    CGFloat rotation;
    CGFloat spinRate;
};
typedef struct CSMAstroidSettings CSMAstroidSettings;

struct CSMRocketSettings{
    CGPoint position;
    CGFloat rotation;
};
typedef struct CSMRocketSettings CSMRocketSettings;

struct CSMWormHoleSettings{
    CGPoint position;
};
typedef struct CSMWormHoleSettings CSMWormHoleSettings;

struct CSMSolidObjectSettings{
    CGPoint position;
    CGFloat rotation;
    int type;
};
typedef struct CSMSolidObjectSettings CSMSolidObjectSettings;


#endif
