//
//  CSMLevelBuildScene.m
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//


#import "CSMLevelBuildScene.h"
#import "Tools.h"
#import "CSMPanelSprite.h"
#import "ButtonSprite.h"
#import <SpriteKit/SpriteKit.h>
#import "CSMLevel.h"
#import "CSMLevelsLibrary.h"
#import "CSMEnemySprite.h"
#import "CSMRocketSprite.h"
#import "CSMAstroidSprite.h"
#import "CSMSpriteNode.h"
#import "CSMEnemySpawnPoint.h"
#import "CSMWormHoleSprite.h"
#import "CSMSolidObject.h"
#import "CSMNodeSprite.h"
#import "CSMPanelButton.h"
#import "CSMEnemyArtilary.h"
#import "CSMEnemyEgg.h"
#import "CSMGameData.h"

//icon positions
#define scrollAndZoomButtonPos CGPointMake (-self.frame.size.width/2 + 90, self.frame.size.height/2 - 30)
#define editSpritesButtonPos CGPointMake (-self.frame.size.width/2 + 140, self.frame.size.height/2 - 30)
#define clearSelectionButtonPos CGPointMake(-self.frame.size.width/2 + 190, self.frame.size.height/2 - 30)

#define saveButtonPos CGPointMake (-self.frame.size.width/2 + 30, self.frame.size.height/2 - 80)
#define addLevelButtonPos CGPointMake (-self.frame.size.width/2 + 30, self.frame.size.height/2 - 130)
#define clearLevelButtonPos CGPointMake (-self.frame.size.width/2 + 30, self.frame.size.height/2 - 180)
#define deleteLevelButtonPos CGPointMake (-self.frame.size.width/2 + 30, self.frame.size.height/2 - 230)
#define stateLabelPos CGPointMake (20, self.frame.size.height/2 - 30);
#define levelNumberLabelPos CGPointMake (180, self.frame.size.height/2 - 30);

#define zoomOutButtonPos CGPointMake (-self.frame.size.width/2 + 30, -self.frame.size.height/2 + 30)
#define zoomInButtonPos CGPointMake (-self.frame.size.width/2 + 80, -self.frame.size.height/2 + 30)
#define previousLevelButtonPos CGPointMake (-self.frame.size.width/2 + 130, -self.frame.size.height/2 + 30)
#define nextLevelButtonPos CGPointMake (-self.frame.size.width/2 + 180, -self.frame.size.height/2 + 30)


//panels
#define icon6Pos CGPointMake(panel1.size.width/2, 30)
#define icon5Pos CGPointMake(panel1.size.width/2, 80)
#define icon4Pos CGPointMake(panel1.size.width/2, 130)
#define icon3Pos CGPointMake(panel1.size.width/2, 180)
#define icon2Pos CGPointMake(panel1.size.width/2, 230)
#define icon1Pos CGPointMake(panel1.size.width/2, 280)

/*
//RHS Panel
#define closepanel1ButtonPos CGPointMake(panel1.size.width/2, 30)
#define addEnemyButtonPos CGPointMake(panel1.size.width/2, 80)
#define placeRocketButtonPos CGPointMake(panel1.size.width/2, 130)
#define addAstroidButtonPos CGPointMake(panel1.size.width/2, 180)
#define addWormHoleButtonPos CGPointMake(panel1.size.width/2, 230)

//BTM Panel
#define closepanel2ButtonPos CGPointMake(30, -panel2.size.height/2)
#define addEnemySpawnPointPos CGPointMake(80, -panel2.size.height/2)
#define addSharpenerButtonPos CGPointMake(130, -panel2.size.height/2)
#define addPencilButtonPos CGPointMake(180, -panel2.size.height/2)
#define addEraserButtonPos CGPointMake(230, -panel2.size.height/2)
#define addNodeButtonPos CGPointMake(280, -panel2.size.height/2)
*/

//zPositions
//#define zPosPanelBut 10
//#define zPosPanel 11
//#define zPosIcon 10



typedef enum {
    SCROLLZOOM = 0,
    EDIT,
    ADDING_ENEMY,
    ADDING_ENEMYARTILARY,
    ADDING_ENEMYEGG,
    PLACING_ROCKET,
    ADDING_ASTROID,
    ADDING_WORMHOLE,
    ROTATING_SPRITE,
    SPRITE_SELECTED,
    NODE_SELECTED,
    ADDING_ENEMYSPAWNPOINT,
    ADDING_SHARPENER,
    ADDING_PENCIL,
    ADDING_ERASER,
    ADDING_NODE
} BuildState;

@interface CSMLevelBuildScene()
@property CSMLevelsLibrary *levelsLibrary;
@property CSMLevel* currentLevel;
@property CSMGameData* gameData;

@end

@implementation CSMLevelBuildScene{
    CGPoint touch1;
    CGPoint touch2;
    CGPoint pinchTouches [4];
    
    CSMPanelSprite *panel1;
    CSMPanelSprite *panelTOP;
    CSMPanelSprite *panel2;
    CSMPanelSprite * panel3;
    CSMPanelSprite * panel4;
    BOOL contentCreated;
    BuildState state;
    int currentLevelNumber;
    CSMSpriteNode* currentSprite;
    SKNode* highlight;
    NSDictionary* IconPositions;
    SKSpriteNode* rotateIcon;
    SKLabelNode* stateLabel;
    BOOL nodeSelected;
    BOOL newAstroidLine;
    
    int astroidType;
    int solidObjectType;
    CGSize fieldSize;
    
    int nextParentNumber;
    int nextSpriteNumber;
}

#pragma mark debug tools
/*
-(void)update:(NSTimeInterval)currentTime{
    static NSTimeInterval lastTime = 0.0;
    if( (currentTime - lastTime) > 5.0 ){
        lastTime = currentTime;
        
        NSLog(@"\nspriteHolder children:");
        for(SKSpriteNode* sprite in [self.spriteHolder children]){
            if(![sprite.name isEqualToString:@"tile"] && ![sprite.name isEqualToString:@"desk"]){
                NSLog(@"%@", sprite.name);
                for(SKSpriteNode* sprite2 in [sprite children]){
                    NSLog(@"%@: %@", sprite.name, sprite2.name);
                }
            }
        }
    }
}
 */

#pragma mark initialisation

+(id)sceneWithSize:(CGSize)size library:(CSMLevelsLibrary *)library level:(CSMLevel *)level{
    CSMLevelBuildScene* scene = [[CSMLevelBuildScene alloc]initWithSize:size library:library level:level];
    return scene;
}

+(id)sceneWithSize:(CGSize)size level:(CSMLevel *)level gameData:(CSMGameData *)gData{
    CSMLevelBuildScene* scene = [[CSMLevelBuildScene alloc]initWithSize:size level:level gameData:gData];
    return scene;
}

-(id)initWithSize:(CGSize)size library:(CSMLevelsLibrary *)library level:(CSMLevel *)level{
    if (self = [self initWithSize:size]){
        self.currentLevel = level;
        currentLevelNumber = [[level getLevelNumber] intValue];
        self.levelsLibrary = library;
        astroidType = 2;
        newAstroidLine = YES;
        
        //temporary field size
        fieldSize = kStandardFieldSize;
    }
    self.name = @"levelbuildscene";
    return self;
}

-(id)initWithSize:(CGSize)size level:(CSMLevel *)level gameData:(CSMGameData*)gData{
    if (self = [self initWithSize:size library:nil level:level]){
        self.gameData = gData;
    }
    return self;
}

-(void)createSceneContents{
    //NSLog(@"[CSMLevelBuildScene createSceneContents]");
    [super createSceneContents];
    
    
    
    //state text
    stateLabel = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    stateLabel.fontColor = [UIColor blueColor];
    stateLabel.position = stateLabelPos;
    stateLabel.fontSize = 20;
    stateLabel.alpha = 0.7;
    stateLabel.zPosition = kIcon1zPos;
    [self addChild:stateLabel];
    
    //level no
    SKLabelNode* levelNumberLabel = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    levelNumberLabel.fontColor = [UIColor blueColor];
    levelNumberLabel.position = levelNumberLabelPos;
    levelNumberLabel.fontSize = 20;
    levelNumberLabel.alpha = 0.7;
    levelNumberLabel.zPosition = kIcon1zPos;
    levelNumberLabel.text = [NSString stringWithFormat:@"%@", self.currentLevel.getLevelNumber];
    [self addChild:levelNumberLabel];
   
    
    //scrollAndZoom icon
    SKTexture *scrollAndZoomTexture = [SKTexture textureWithImageNamed:@"IconScrollAndZoom.png"];
    ButtonSprite* scrollAndZoomControl = [[ButtonSprite alloc]initWithTexture: scrollAndZoomTexture scene:self type:kScrollAndZoom];
    scrollAndZoomControl.position = scrollAndZoomButtonPos;
    scrollAndZoomControl.userInteractionEnabled = YES;
    scrollAndZoomControl.alpha = 0.6;
    scrollAndZoomControl.zPosition = kIcon1zPos;
    [self addChild:scrollAndZoomControl];
    
    //editSprites icon
    SKTexture *editSpritesTexture = [SKTexture textureWithImageNamed:@"IconEditSprites.png"];
    ButtonSprite* editSpritesControl = [[ButtonSprite alloc]initWithTexture: editSpritesTexture scene:self type:kEditSprites];
    editSpritesControl.position = editSpritesButtonPos;
    editSpritesControl.userInteractionEnabled = YES;
    editSpritesControl.alpha = 0.6;
    editSpritesControl.zPosition = kIcon1zPos;
    [self addChild:editSpritesControl];
    
    //clear selection button
    ButtonSprite *clearSelectionButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconClearSelection.png"]
                                                                        scene:self
                                                                         type:kClearSelection];
    clearSelectionButton.position = clearSelectionButtonPos;
    clearSelectionButton.userInteractionEnabled = YES;
    clearSelectionButton.zPosition = kIcon1zPos;
    [self addChild:clearSelectionButton];
    
    //save icon
    SKTexture *saveTexture = [SKTexture textureWithImageNamed:@"IconSave.png"];
    ButtonSprite* saveControl = [[ButtonSprite alloc]initWithTexture: saveTexture scene:self type:kSave];
    saveControl.position = saveButtonPos;
    saveControl.userInteractionEnabled = YES;
    saveControl.alpha = 0.6;
    saveControl.zPosition = kIcon1zPos;
    [self addChild:saveControl];
    
    //add level icon
    SKTexture *addLevelTexture = [SKTexture textureWithImageNamed:@"IconAddLevel.png"];
    ButtonSprite* addLevelControl = [[ButtonSprite alloc]initWithTexture: addLevelTexture scene:self type:kAddLevel];
    addLevelControl.position = addLevelButtonPos;
    addLevelControl.userInteractionEnabled = YES;
    addLevelControl.alpha = 0.6;
    addLevelControl.zPosition = kIcon1zPos;
    [self addChild:addLevelControl];
    
    //clear level icon
    SKTexture *clearLevelTexture = [SKTexture textureWithImageNamed:@"IconClearLevel.png"];
    ButtonSprite* clearLevelControl = [[ButtonSprite alloc]initWithTexture: clearLevelTexture scene:self type:kClearLevel];
    clearLevelControl.position = clearLevelButtonPos;
    clearLevelControl.userInteractionEnabled = YES;
    clearLevelControl.alpha = 0.6;
    clearLevelControl.zPosition = kIcon1zPos;
    [self addChild:clearLevelControl];
    
    //delete level icon
    SKTexture *levelTrashTexture = [SKTexture textureWithImageNamed:@"IconLevelTrash.png"];
    ButtonSprite* deleteLevelControl = [[ButtonSprite alloc]initWithTexture: levelTrashTexture scene:self type:kDeleteLevel];
    deleteLevelControl.position = deleteLevelButtonPos;
    deleteLevelControl.userInteractionEnabled = YES;
    deleteLevelControl.alpha = 0.6;
    deleteLevelControl.zPosition = kIcon1zPos;
    [self addChild:deleteLevelControl];
    
    //zoomout button
    SKTexture *zoomOutTexture = [SKTexture textureWithImageNamed:@"iconzoomout.png"];
    ButtonSprite* zoomOutControl = [[ButtonSprite alloc]initWithTexture: zoomOutTexture scene:self type:kZoomOut];
    zoomOutControl.position = zoomOutButtonPos;
    zoomOutControl.userInteractionEnabled = YES;
    zoomOutControl.alpha = 0.6;
    zoomOutControl.zPosition = kIcon1zPos;
    [self addChild:zoomOutControl];
    
    //zoomin button
    SKTexture *zoomInTexture = [SKTexture textureWithImageNamed:@"iconzoomin.png"];
    ButtonSprite* zoomInControl = [[ButtonSprite alloc]initWithTexture: zoomInTexture scene:self type:kZoomIn];
    zoomInControl.position = zoomInButtonPos;
    zoomInControl.userInteractionEnabled = YES;
    zoomInControl.alpha = 0.6;
    zoomInControl.zPosition = kIcon1zPos;
    [self addChild:zoomInControl];
    
    //previousLevelButton
    SKTexture *previousLevelTexture = [SKTexture textureWithImageNamed:@"ArrowLeft.png"];
    ButtonSprite* previousLevelControl = [[ButtonSprite alloc]initWithTexture: previousLevelTexture scene:self type:kPreviousLevel];
    previousLevelControl.position = previousLevelButtonPos;
    previousLevelControl.userInteractionEnabled = YES;
    previousLevelControl.alpha = 0.6;
    previousLevelControl.zPosition = kIcon1zPos;
    [self addChild:previousLevelControl];
    
    //nextLevelButton
    SKTexture *nextLevelTexture = [SKTexture textureWithImageNamed:@"ArrowRight.png"];
    ButtonSprite* nextLevelControl = [[ButtonSprite alloc]initWithTexture: nextLevelTexture scene:self type:kNextLevel];
    nextLevelControl.position = nextLevelButtonPos;
    nextLevelControl.userInteractionEnabled = YES;
    nextLevelControl.alpha = 0.6;
    nextLevelControl.zPosition = kIcon1zPos;
    [self addChild:nextLevelControl];
    
    
    //Build panel1
    CSMPanelButton* panel1but = [[CSMPanelButton alloc]initWithColor:[SKColor blueColor] edge:kPanelRight parentScene:self];
    panel1but.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-((panel1but.size.height)));
    panel1but.userInteractionEnabled = YES;
    panel1but.name = @"panel1but";
    panel1but.zPosition = kIcon1zPos;
    [self addChild:panel1but];
    panel1 = panel1but.panel;
    panel1.name = @"panel1";
    panel1.zPosition = kIcon2zPos;
    
    //Build panel2
    CSMPanelButton* panel2but = [[CSMPanelButton alloc]initWithColor:[SKColor redColor] edge:kPanelRight parentScene:self];
    panel2but.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-((panel1but.size.height*2)));
    panel2but.userInteractionEnabled = YES;
    panel2but.name = @"panel2but";
    panel2but.zPosition = kIcon1zPos;
    [self addChild:panel2but];
    panel2 = panel2but.panel;
    panel2.name = @"panel2";
    panel2.zPosition = kIcon2zPos;
    
    //Build panel3
    CSMPanelButton* panel3but = [[CSMPanelButton alloc]initWithColor:[SKColor greenColor] edge:kPanelRight parentScene:self];
    panel3but.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-((panel1but.size.height*3)));
    panel3but.userInteractionEnabled = YES;
    panel3but.name = @"panel3but";
    panel3but.zPosition = kIcon1zPos;
    [self addChild:panel3but];
    panel3 = panel3but.panel;
    panel3.name = @"panel3";
    panel3.zPosition =kIcon2zPos;
    
    //Build panel4
    CSMPanelButton* panel4but = [[CSMPanelButton alloc]initWithColor:[SKColor brownColor] edge:kPanelRight parentScene:self];
    panel4but.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-((panel1but.size.height*4)));
    panel4but.userInteractionEnabled = YES;
    panel4but.name = @"panel4but";
    panel4but.zPosition = kIcon1zPos;
    [self addChild:panel4but];
    panel4 = panel4but.panel;
    panel4.name = @"panel4";
    panel4.zPosition =kIcon2zPos;
    
    
    //panel1 buttons --------------------------------
    
    //place rocket button
    ButtonSprite *addRocketButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"rocket2.0.png"]
                                                                   scene:self
                                                                    type:kAddRocket];
    addRocketButton.position = icon1Pos;
    addRocketButton.userInteractionEnabled = YES;
    [panel1 addChild:addRocketButton];
    
    //place worm hole button
    ButtonSprite *addWormholeButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"WormHole.png"]
                                                                     scene:self
                                                                      type:kAddWormHole];
    addWormholeButton.position = icon2Pos;
    addWormholeButton.userInteractionEnabled = YES;
    addWormholeButton.xScale = 0.5;
    addWormholeButton.yScale = 0.5;
    //panel1.zPosition = zPosPanel;
    [panel1 addChild:addWormholeButton];
    
    //add astroid2 button
    ButtonSprite *addAstroid2Button = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"astroid2.png"]
                                                                     scene:self
                                                                      type:kAddAstroid2];
    addAstroid2Button.position = icon3Pos;
    addAstroid2Button.userInteractionEnabled = YES;
    addAstroid2Button.xScale = 0.1;
    addAstroid2Button.yScale = 0.1;
    [panel1 addChild:addAstroid2Button];
    
    //add astroid3 button
    ButtonSprite *addAstroid3Button = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"iconAstroid3.png"]
                                                                     scene:self
                                                                      type:kAddAstroid3];
    addAstroid3Button.position = icon4Pos;
    addAstroid3Button.userInteractionEnabled = YES;
    addAstroid3Button.xScale = 0.1;
    addAstroid3Button.yScale = 0.1;
    [panel1 addChild:addAstroid3Button];
    
    //add astroidLine button
    /*
    ButtonSprite *addAstroidLine = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconAstroidLine.png"]
                                                                  scene:self
                                                                   type:kAddAstroidLine];
    addAstroidLine.position = icon5Pos;
    addAstroidLine.userInteractionEnabled = YES;
    [panel1 addChild:addAstroidLine];
     */
    
    //add node
    ButtonSprite *addNodeButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"iconNode.png"]
                                                                 scene:self
                                                                  type:kAddNode];
    addNodeButton.position = icon6Pos;
    addNodeButton.userInteractionEnabled = YES;
    addNodeButton.xScale = 1.0;
    addNodeButton.yScale = 1.0;
    //addNodeButton.zRotation = 0.75*M_PI;
    [panel1 addChild:addNodeButton];

    
    
    //add buttons to panel2 -----------------------------------
   
    //add enemy button
    ButtonSprite *addEnemyButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"enemy1.png"]
                                                            scene:self
                                                             type:kAddEnemy];
    addEnemyButton.position = icon1Pos;
    addEnemyButton.userInteractionEnabled = YES;
    [panel2 addChild:addEnemyButton];
    
    //add enemyartilary button
    ButtonSprite *addEnemyArtilaryButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"enemyartilary.png"]
                                                                   scene:self
                                                                    type:kAddEnemyArtilary];
    addEnemyArtilaryButton.position = icon2Pos;
    addEnemyArtilaryButton.userInteractionEnabled = YES;
    [panel2 addChild:addEnemyArtilaryButton];
    
    
    //place enemy egg button
    ButtonSprite *addEnemyEggButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"enemyegg.png"]
                                                                     scene:self
                                                                      type:kAddEnemyEgg];
    addEnemyEggButton.position = icon3Pos;
    addEnemyEggButton.userInteractionEnabled = YES;
    addEnemyEggButton.xScale = 1.0;
    addEnemyEggButton.yScale = 1.0;
    //panel1.zPosition = zPosPanel;
    [panel2 addChild:addEnemyEggButton];
    
    
    //add enemySpawnPoint
    ButtonSprite *addEnemySpawnPointButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"enemySpawnPoint.png"]
                                                                  scene:self
                                                                   type:kAddEnemySpawnPoint];
    addEnemySpawnPointButton.position = icon4Pos;
    addEnemySpawnPointButton.userInteractionEnabled = YES;
    [panel2 addChild:addEnemySpawnPointButton];
    
    
    //panel3 buttons ----------------------------------------------------
    
    
    //add sharpener
    ButtonSprite *addSharpenerButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"sharpener.png"]
                                                                   scene:self
                                                                    type:kAddSharpener];
    addSharpenerButton.position = icon1Pos;
    addSharpenerButton.userInteractionEnabled = YES;
    addSharpenerButton.xScale = 0.2;
    addSharpenerButton.yScale = 0.2;
    [panel3 addChild:addSharpenerButton];
    
    
    //add rubber
    ButtonSprite *addEraserButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"objecteraser.png"]
                                                                   scene:self
                                                                    type:kAddEraser];
    addEraserButton.position = icon2Pos;
    addEraserButton.userInteractionEnabled = YES;
    addEraserButton.xScale = 0.2;
    addEraserButton.yScale = 0.2;
    addEraserButton.zRotation = 0.75*M_PI;
    [panel3 addChild:addEraserButton];
    
    //add blue pencil
    ButtonSprite *addPencilBlueButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"pencil_blue.png"]
                                                                            scene:self
                                                                             type:kAddPencilBlue];
    addPencilBlueButton.position = icon3Pos;
    addPencilBlueButton.userInteractionEnabled = YES;
    addPencilBlueButton.xScale = 0.1;
    addPencilBlueButton.yScale = 0.2;
    addPencilBlueButton.zRotation = 0.75*M_PI;
    [panel3 addChild:addPencilBlueButton];
    
    //add red pencil
    ButtonSprite *addPencilRedButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"pencil_red.png"]
                                                                   scene:self
                                                                    type:kAddPencilRed];
    addPencilRedButton.position = icon4Pos;
    addPencilRedButton.userInteractionEnabled = YES;
    addPencilRedButton.xScale = 0.1;
    addPencilRedButton.yScale = 0.2;
    addPencilRedButton.zRotation = 0.75*M_PI;
    [panel3 addChild:addPencilRedButton];
    
    //add green pencil
    ButtonSprite *addPencilGreenButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"pencil_green.png"]
                                                                   scene:self
                                                                    type:kAddPencilGreen];
    addPencilGreenButton.position = icon5Pos;
    addPencilGreenButton.userInteractionEnabled = YES;
    addPencilGreenButton.xScale = 0.1;
    addPencilGreenButton.yScale = 0.2;
    addPencilGreenButton.zRotation = 0.75*M_PI;
    [panel3 addChild:addPencilGreenButton];
    
    //add brown pencil
    ButtonSprite *addPencilBrownButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"pencil_brown.png"]
                                                                   scene:self
                                                                    type:kAddPencilBrown];
    addPencilBrownButton.position = icon6Pos;
    addPencilBrownButton.userInteractionEnabled = YES;
    addPencilBrownButton.xScale = 0.1;
    addPencilBrownButton.yScale = 0.2;
    addPencilBrownButton.zRotation = 0.75*M_PI;
    [panel3 addChild:addPencilBrownButton];
    
    //panel4 buttons ------------------------------------------------------------
    
    
    //horizontal enlarge
    ButtonSprite *horizontalEnlargeButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconHorizontalEnlarge.png"]
                                                                        scene:self
                                                                         type:kHorizontalEnlarge];
    horizontalEnlargeButton.position = icon1Pos;
    horizontalEnlargeButton.userInteractionEnabled = YES;
    [panel4 addChild:horizontalEnlargeButton];
    
    
    //vertial enlarge
    ButtonSprite *verticalEnlargeButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconVerticalEnlarge.png"]
                                                                           scene:self
                                                                            type:kVerticalEnlarge];
    verticalEnlargeButton.position = icon2Pos;
    verticalEnlargeButton.userInteractionEnabled = YES;
    [panel4 addChild:verticalEnlargeButton];
    
    
    
    
    
    [self loadLevel];
    [self setState:SCROLLZOOM];
    [self deadenSprites];
    
    self.spriteHolder.xScale = self.minScale;
    self.spriteHolder.yScale = self.minScale;
}

-(void)loadLevel{
    [super addBackground:self.spriteHolder Size:self.currentLevel.fieldSize];
    
    [self placeRocket:CGPointMake([self.currentLevel getRocketPosition].x, [self.currentLevel getRocketPosition].y)];
    
    NSArray *sprites = [self.currentLevel getSprites];
    
    for(CSMSpriteNode* spriteTem in sprites){
        //NSLog(@"\nadding %@\n\n", sprite);
        CSMSpriteNode* sprite = [spriteTem copy];
        if([sprite parent]){
            NSLog(@"already has parent: %@", sprite);
        }
        else{
            if([sprite isKindOfClass:[CSMSpriteNode class]]){
                [self.spriteHolder addChild:sprite];
                sprite.zPosition = kDrawing1zPos;
                
                [sprite setScene:self];
                
                
                if([sprite children]){
                    [sprite setdownChildren];
                }
                
                sprite.userInteractionEnabled = YES;
            }
            else{
                NSLog(@"doesn't respond to set scene: %@", sprite);
            }
        }
    }
    
    [self setNextParentNumber];
}

-(void)displayImage:(CGImageRef)image{
    SKSpriteNode* im = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithCGImage:image]];
    im.position = CGPointMake(0.0, 0.0);
    [self addChild:im];
}


#pragma mark user input

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    
    //check for move
    if([allTouches count] == 1)
        touch1 = [[allTouches anyObject] locationInNode:self.spriteHolder];
    
    //check for pinch
    else if([allTouches count] == 2){
        int i=0;
        for(UITouch *touch in [allTouches allObjects]){
            pinchTouches[i] = [touch locationInNode:self.spriteHolder];
            i++;
        }
        touch1 = CGPointMake(0, 0);
        touch2 = CGPointMake(0, 0);
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    
    //check for move
    if([allTouches count] == 1){
        touch2 = [[allTouches anyObject] locationInNode:self.spriteHolder];
        
        switch (state) {
            case ADDING_ASTROID:
                [self addNewAstroid];
                break;
            case ROTATING_SPRITE:
                [self rotateSprite];
                break;
            default:
                [self scrollFrom:touch1 to:touch2];
        }
    }
    
    //check for pinch
    else if([allTouches count] == 2){
        int i=2;
        for(UITouch *touch in [allTouches allObjects]){
            pinchTouches[i] = [touch locationInNode:self.spriteHolder];
            i++;
        }
        [self zoom];
        touch1 = CGPointMake(0, 0);
        touch2 = CGPointMake(0, 0);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    
    //check for move or ad item
    if([allTouches count] == 1){
        touch2 = [[allTouches anyObject] locationInNode:self.spriteHolder];
        switch (state) {
            case ADDING_ENEMY:
                [self addEnemy:touch2];
                break;
            case ADDING_ENEMYARTILARY:
                [self addEnemyArtilary:touch2];
                break;
            case ADDING_ENEMYSPAWNPOINT:
                [self addEnemySpawnPoint:touch2];
                break;
            case ADDING_ENEMYEGG:
                [self addEnemyEgg:touch2];
                break;
            case PLACING_ROCKET:
                [self placeRocket:touch2];
                break;
            case ADDING_ASTROID:
                if(newAstroidLine)
                    [self addAstroid:YES];
                newAstroidLine = YES;
                break;
            case ADDING_WORMHOLE:
                [self addWormhole:touch2];
                break;
            case ADDING_SHARPENER:
                [self addSharpener:touch2];
                [self setState:EDIT];
                break;
            case ADDING_PENCIL:
                [self addPencil:touch2];
                [self setState:EDIT];
                break;
            case ADDING_ERASER:
                [self addEraser:touch2];
                [self setState:EDIT];
                break;
            case ADDING_NODE:
                [self addNode:touch2];
                [self setState:EDIT];
                break;
            default:
                //[self scrollFrom:touch1 to:touch2];
                break;
        
        //touch1 = touch2;
    }
    }
    
    //check for pinch
    else if([allTouches count] == 2){
        int i=2;
        for(UITouch *touch in [allTouches allObjects]){
            pinchTouches[i] = [touch locationInNode:self.spriteHolder];
            i++;
        }
        [self zoom];
        touch1 = CGPointMake(touch2.x, touch2.y);
        
    }
}

-(void)buttonReleased:(ButtonType)button{
    switch (button) {
        case kBack:
            [super openMenu];
            break;
        case kScrollAndZoom:
            [self deadenSprites];
            [self setState:SCROLLZOOM];
            break;
        case kEditSprites:
            [self enlivenSprites];
            [self setState:EDIT];
            break;
        case kAddEnemy:
            [self setState:ADDING_ENEMY];
            break;
        case kAddEnemyArtilary:
            [self setState:ADDING_ENEMYARTILARY];
            break;
        case kAddEnemyEgg:
            [self setState:ADDING_ENEMYEGG];
            break;
        case kAddEnemySpawnPoint:
            [self setState:ADDING_ENEMYSPAWNPOINT];
            break;
        case kEnemySpawnRate:
            [self setEnemySpawnRate];
            break;
        case kAddRocket:
            [self setState:PLACING_ROCKET];
            break;
        case kAddAstroid2:
            astroidType = 2;
            [self setState:ADDING_ASTROID];
            break;
        case kAddAstroid3:
            astroidType = 3;
            [self setState:ADDING_ASTROID];
            break;
        case kAddAstroidLine:
            //[self setState:ADDING_ASTROIDLINE];
            [self setState:ADDING_ASTROID];
            break;
        case kAddWormHole:
            [self setState:ADDING_WORMHOLE];
            break;
        case kAddSharpener:
            [self setState:ADDING_SHARPENER];
            break;
        case kAddPencilBlue:
            [self setState:ADDING_PENCIL];
            solidObjectType = kPencilBlue;
            break;
        case kAddPencilGreen:
            [self setState:ADDING_PENCIL];
            solidObjectType = kPencilGreen;
            break;
        case kAddPencilRed:
            [self setState:ADDING_PENCIL];
            solidObjectType = kPencilRed;
            break;
        case kAddPencilBrown:
            [self setState:ADDING_PENCIL];
            solidObjectType = kPencilBrown;
            break;
        case kAddEraser:
            [self setState:ADDING_ERASER];
            break;
        case kClearSelection:
            [self deselect];
            break;
        case kClosePanel1:
            [panel1 close];
            break;
        case kClosePanel2:
            [panel2 close];
            break;
        case kSave:
            [self saveLevel];
            break;
        case kAddLevel:
            [self addLevel];
            break;
        case kClearLevel:
            [self clearLevel];
            break;
        case kDeleteLevel:
            [self deleteLevel];
            break;
        case kTrash:
            [currentSprite removeFromParent];
            [self removeHighlight];
            [self setState:EDIT];
            [self closePanelTop];
            break;
        case kRotate:
            [self removeHighlight];
            [self rotateSpritePrep];
            break;
        case kSpin:
            [self setSpriteSpin];
            break;
        case kSpriteSelection:
            [self deselect];
            break;
        case kAddNode:
            [self setState:ADDING_NODE];
            break;
        case kZoomIn:
            [self zoom:1.1];
            break;
        case kZoomOut:
            [self zoom:0.9];
            break;
        case kVerticalEnlarge:
            [self changeSize:NO enlarge:YES];
            break;
        case kHorizontalEnlarge:
            [self changeSize:YES enlarge:YES];
            break;
            
#ifdef compileWithBuildModule
        case kPreviousLevel:
            //[self openLevel:[self.currentLevel.getLevelNumber intValue]-1];
            [self.gameData openBuildLevel:[self.currentLevel.getLevelNumber intValue]-1 fromScene:self];
            break;
        case kNextLevel:
            //[self openLevel:[self.currentLevel.getLevelNumber intValue]+1];
            [self.gameData openBuildLevel:[self.currentLevel.getLevelNumber intValue]+1 fromScene:self];
            break;
#endif
            
        default:
            NSLog(@"unrecognised button released");
            break;
    }
}

-(void)spriteTouched:(CSMSpriteNode *)sprite{
    //NSLog(@"spriteTouched %@", sprite);
    
    if([sprite.name isEqualToString:@"node"]){
        nodeSelected = YES;
    }
    
    currentSprite = sprite;
    
    //if(state != NORMAL)
    //    return;
    
    if(state == SCROLLZOOM){
        NSLog(@"spriteTouched in SCROLLZOOM state");
        
    }
    
    [self setState:SPRITE_SELECTED];
    
    [self removeHighlight];
    
    highlight = [sprite getHighlight];
    highlight.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:highlight];
    NSLog(@"highlight added: %lu", (unsigned long)[[highlight children] count]);
    
    
    /*
    if(!spriteSelection)
        spriteSelection = [[ButtonSprite alloc] initWithTexture:[SKTexture textureWithImageNamed:@"IconSelected.png"]
                                                          scene:self
                                                           type:kSpriteSelection];
    else
        [spriteSelection removeFromParent];
    
    
    currentSprite = sprite;
    
    spriteSelection.position = CGPointMake(sprite.position.x, sprite.position.y);
    [self.spriteHolder addChild:spriteSelection];
    */
    if(panelTOP)
        [panelTOP close];
    if([panelTOP parent])
        [panelTOP removeFromParent];
    
    //build panel every time for now
    if(!panelTOP || panelTOP){
        //prepare icons for panel
        CGFloat xPos = 30;
        
        //rotate button
        ButtonSprite *rotateButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconRotate.png"]
                                                                    scene:self
                                                                     type:kRotate];
        rotateButton.position = CGPointMake(xPos, 30);
        rotateButton.userInteractionEnabled = YES;
        
        //trash button
        xPos+=50;
        ButtonSprite *trashButton = [[ButtonSprite alloc]initWithTexture:[SKTexture textureWithImageNamed:@"IconTrash.png"]
                                                                   scene:self
                                                                    type:kTrash];
        trashButton.position = CGPointMake(xPos, 30);
        trashButton.userInteractionEnabled = YES;
        
        //build panel
        panelTOP = [[CSMPanelSprite alloc] initWithColor:[SKColor grayColor]
                                                  number:0
                                                    size:CGSizeMake(150, 70)
                                                    open:CGVectorMake(0, -70)];
        [panelTOP addChild:trashButton];
        [panelTOP addChild:rotateButton];
        panelTOP.position = CGPointMake(0, 0);
        panelTOP.zPosition = kIcon1zPos;
        panelTOP.position = CGPointMake((self.frame.size.width/2 - 120- panelTOP.size.width), self.frame.size.height/2);
        [self addChild:panelTOP];
        
        //optional thirdButton
        xPos+=50;
        ButtonSprite* thirdButton = [ButtonSprite alloc];
        
        if([currentSprite.name isEqualToString:@"astroid"] || [currentSprite.name isEqualToString:@"node"]){
            thirdButton = [thirdButton initWithTexture:[SKTexture textureWithImageNamed:@"IconSpin.png"]
                                                 scene:self
                                                  type:kSpin];
            thirdButton.position = CGPointMake(xPos, 30);
            thirdButton.userInteractionEnabled = YES;
            [panelTOP addChild:thirdButton];
        }
        else if([currentSprite.name isEqualToString:@"enemyspawnpoint"]){
            thirdButton = [thirdButton initWithTexture:[SKTexture textureWithImageNamed:@"EnemySpawnRateIcon.png"]
                                                 scene:self
                                                  type:kEnemySpawnRate];
            thirdButton.position = CGPointMake(xPos, 30);
            thirdButton.userInteractionEnabled = YES;
            [panelTOP addChild:thirdButton];
        }
        
    }
    
    [panelTOP open];
    
    panelTOP.name = [[NSString stringWithString:currentSprite.name] stringByAppendingString:@"Context"];
    
    /*
    if([sprite.name isEqualToString:@"node"]){
        CSMNodeSprite *nd = (CSMNodeSprite*)sprite;
        [nd highlightNode];
    }
     */
}

-(void)openLevel:(int)levelNo{
    NSLog(@"[CSMLevelBuildScene openLevel:%i", levelNo);
#ifdef compileWithBuildMoidule
    [self.gameData openBuildLevel:levelNo fromScene:self];
#endif
    /*
    CSMLevel* level = [self.levelsLibrary level:levelNo];
    //SKScene * scene = [CSMLevelBuildScene sceneWithSize:self.size];
    SKScene * scene = [CSMLevelBuildScene sceneWithSize:self.size library:self.levelsLibrary level:level];
    
    SKTransition *doors = [SKTransition crossFadeWithDuration:0.5];
     
    [self.view presentScene:scene transition:doors];
     */
     
    /*
    if(levelNo > [self.currentLevel.getLevelNumber intValue])
        doors = [SKTransition moveInWithDirection:SKTransitionDirectionRight duration:0.2];
    else
        doors = [SKTransition moveInWithDirection:SKTransitionDirectionLeft duration:0.2];
     */
 
    
}


#pragma mark building tools


-(void)changeSize:(BOOL)horizontal enlarge:(BOOL)en{
    //remove background tiles
    for(SKNode* node in [self.spriteHolder children]){
        if([node.name isEqualToString:@"tile"])
            [node removeFromParent];
    }
    
    //change field size
    if(horizontal)
        fieldSize = en ? CGSizeMake(fieldSize.width + 200, fieldSize.height) : CGSizeMake(fieldSize.width - 200, fieldSize.height) ;
    else
        fieldSize = en ? CGSizeMake(fieldSize.width, fieldSize.height + 200) : CGSizeMake(fieldSize.width, fieldSize.height - 200) ;
    
    //add tiles
    [super addBackground:self.spriteHolder Size:fieldSize];
    
}

-(void)addSharpener:(CGPoint)location
{
    CSMSolidObject *sharpener = [[CSMSolidObject alloc] initWithType:kSharpener scene:self];
    sharpener.position = location;
    sharpener.zPosition = kSolidObjzPos;
    sharpener.userInteractionEnabled = YES;
    [self.spriteHolder addChild:sharpener];
}

-(void)addPencil:(CGPoint)location
{
    CSMSolidObject *pencil = [[CSMSolidObject alloc] initWithType:solidObjectType scene:self];
    pencil.position = location;
    pencil.zPosition = kSolidObjzPos;
    pencil.userInteractionEnabled = YES;
    [self.spriteHolder addChild:pencil];
}

-(void)addEraser:(CGPoint)location
{
    CSMSolidObject *eraser = [[CSMSolidObject alloc] initWithType:kEraser scene:self];
    eraser.position = location;
    eraser.zPosition = kSolidObjzPos;
    eraser.userInteractionEnabled = YES;
    [self.spriteHolder addChild:eraser];
}

-(void)addEnemy:(CGPoint)location
{
    
    CSMEnemySprite *newEnemy = [[CSMEnemySprite alloc]initWithScene:self];
    newEnemy.position = location;
    newEnemy.zPosition = kDrawing1zPos;
    newEnemy.userInteractionEnabled = YES;
    [self.spriteHolder addChild:newEnemy];

}

-(void)addEnemyArtilary:(CGPoint)location{
    
    if([currentSprite isKindOfClass:[CSMAstroidSprite class]]){
        
        CSMAstroidSprite* as = (CSMAstroidSprite*)currentSprite;
        
        //calculate angle from parent astroid to touch
        CGFloat angleFromParent = [Tools getAngleFrom:as.position to:location];
        //angleFromParent = 0.5 * M_PI;
        
        //calculate location on perimeter of astroid
        CGFloat dx = sinf(angleFromParent) * (13 + as.size.width/2) * -1;
        CGFloat dy = cosf(angleFromParent) * (13 + as.size.width/2);
        
        
        //place artilary
        CSMEnemyArtilary *newArtilary = [[CSMEnemyArtilary alloc]initWithScene:self rotation:angleFromParent];
        newArtilary.position = CGPointMake(as.position.x + dx, as.position.y + dy);
        newArtilary.zPosition = kDrawing1zPos;
        newArtilary.userInteractionEnabled = YES;
        
        
        newArtilary.parentNumber = as.number;
        [self.spriteHolder addChild:newArtilary];
        newArtilary.zPosition = kDrawing1zPos;
    }
    
    //[self addLabels:newArtilary];
/*
    if([currentSprite isKindOfClass:[CSMAstroidSprite class]]){
        CSMAstroidSprite* as = (CSMAstroidSprite*)currentSprite;
        newArtilary.astroidNumber = as.number;
        NSLog(@"adding ea to astroid number %i", as.number);
        //[newAstroid lineToParent:n];
        [self.spriteHolder addChild:newArtilary];
    }
 */
    
}

-(void)addEnemyEgg:(CGPoint)location{
    CSMEnemyEgg *newEnemy = [[CSMEnemyEgg alloc]initWithScene:self];
    newEnemy.position = location;
    newEnemy.zPosition = kDrawing1zPos;
    newEnemy.userInteractionEnabled = YES;
    
    if(nodeSelected && [currentSprite isKindOfClass:[CSMNodeSprite class]]){
        CSMNodeSprite* n = (CSMNodeSprite*)currentSprite;
        newEnemy.parentNumber = n.number;
    }
    
    [self.spriteHolder addChild:newEnemy];
    
    NSLog(@"added enemyEgg iwth pNum %i", newEnemy.parentNumber);
}

-(void)addNode:(CGPoint)location
{
    /*
    //get node number
    int num = 0;
    for(SKNode* node in self.spriteHolder.children){
        if([node isKindOfClass:[CSMNodeSprite class]] == YES){
            CSMNodeSprite* n = (CSMNodeSprite*)node;
            if(n.number > num)
                num = n.number;
        }
    }
    num++;
     */
    
    CSMNodeSprite *newNode = [[CSMNodeSprite alloc]initWithNumber:[self getNewParentNumber] scene:self];
    //newNode.number = [self getNewParentNumber];
    newNode.position = location;
    newNode.zPosition = kDrawing1zPos;
    newNode.userInteractionEnabled = YES;
    [self.spriteHolder addChild:newNode];
    //NSLog(@"addNode");
    [self addLabels:newNode];
}

-(void)addEnemySpawnPoint:(CGPoint)location{
    CSMEnemySpawnPoint* enemySpawnPoint = [[CSMEnemySpawnPoint alloc] initWithImageNamed:@"enemySpawnPoint.png" scene:self];
    enemySpawnPoint.spawnRate = 1;
    enemySpawnPoint.name = @"enemyspawnpoint";
    enemySpawnPoint.position = location;
    enemySpawnPoint.zPosition = kDrawing1zPos;
    enemySpawnPoint.userInteractionEnabled = YES;
    
    if(nodeSelected && [currentSprite isKindOfClass:[CSMNodeSprite class]]){
        CSMNodeSprite* n = (CSMNodeSprite*)currentSprite;
        enemySpawnPoint.parentNumber = n.number;
    }
    
    [self.spriteHolder addChild:enemySpawnPoint];
    [self setState:EDIT];
}

-(void)setEnemySpawnRate{
    //get spawn rate
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    textField.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-100);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blueColor];
    textField.font = [UIFont systemFontOfSize:17.0];
    CSMEnemySpawnPoint* esp = (CSMEnemySpawnPoint*) currentSprite;
    
    textField.placeholder = [NSString stringWithFormat:@"%f", esp.spawnRate];
    textField.backgroundColor = [UIColor whiteColor];
    //textField.autocorrectionType = UITextAutocorrectionTypeYes;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate = self;
    [self.view addSubview:textField];
    
    /*
    //set rate
    if([currentSprite.name isEqualToString:@"enemyspawnpoint"]){
        esp.spawnRate = 1;
    }
    else{
        NSLog(@"trying to set angular velocity on non-astroid");
    }
     */
}

-(void)placeRocket:(CGPoint)location{
    //remove current rocket
    SKNode* oldRocket;
    for(SKNode *node in self.spriteHolder.children){
        if([node.name isEqualToString:@"rocket"])
            oldRocket = node;
    }
    [oldRocket removeFromParent];
    
    //add rocket
    CSMRocketSprite *newRocket = [[CSMRocketSprite alloc]initWithScene:self];
    newRocket.position = location;
    newRocket.zPosition = kDrawing1zPos;
    newRocket.userInteractionEnabled = YES;
    [self.spriteHolder addChild:newRocket];
    //state = NORMAL;
}

-(void)addNewAstroid{
    
    //if new astroid line just add astroid
    if(newAstroidLine){
        [self addAstroid:NO];
        newAstroidLine = NO;
    }
    
    //calculate whether another astroid should be added
    
    //establish astroid diameter
    static CGFloat astroid2Diameter;
    static CGFloat astroid3Diameter;
    if(astroid2Diameter == 0.0){
        NSLog(@"getting diameter");
        SKSpriteNode *ast = [CSMAstroidSprite astroidWithType:2 scene:NULL];
        astroid2Diameter = ast.size.width;
        ast = [CSMAstroidSprite astroidWithType:3 scene:NULL];
        astroid3Diameter = ast.size.width;
    }
    
    int astroidDiameter = 20000;
    
    switch (astroidType) {
        case 2:
            astroidDiameter = astroid2Diameter;
            break;
        case 3:
            astroidDiameter = astroid3Diameter;
            break;
        default:
            NSLog(@"unknown astroidType %i in [CSMLevelBuildScene addAstroidToLine]", astroidType);
            break;
    }
    
    if([Tools getDistanceBetween:touch1 and:touch2] >= astroidDiameter){
        //NSLog(@"touch distance > astroid Diameter");
        touch1 = CGPointMake(touch2.x, touch2.y);
        [self addAstroid:NO];
    }
    
    
}

-(void)addAstroid:(BOOL)touchesEnded{
    //NSLog(@"addAstroid, currentsprite:%@", currentSprite);
    //NSLog(@"addAstroid...");
    
    
    CSMAstroidSprite *newAstroid = [CSMAstroidSprite astroidWithType:astroidType scene:self];
    if(touchesEnded){
        newAstroid.name = @"astroid";
        newAstroidLine = YES;
    }
    else{
        //newAstroid.name = @"tempAstroid";
        newAstroid.name = @"astroid";
    }
    
    newAstroid.anchorPoint = CGPointMake(0.5, 0.5);
    newAstroid.position = CGPointMake(touch1.x, touch1.y);
    newAstroid.zPosition = kDrawing1zPos;
    newAstroid.userInteractionEnabled = YES;
    newAstroid.angularVelocity = 0.2;
    newAstroid.zRotation = (float)rand()/RAND_MAX * 2 * M_PI;
    newAstroid.number = [self getNewParentNumber];
    
    
    if(nodeSelected && [currentSprite isKindOfClass:[CSMNodeSprite class]]){
        //newAstroid.position = [self.spriteHolder convertPoint:touch1 toNode:currentSprite];
        CSMNodeSprite* n = (CSMNodeSprite*)currentSprite;
        newAstroid.parentNumber = n.number;
        //[newAstroid lineToParent:n];
    }
    [self.spriteHolder addChild:newAstroid];
   // NSLog(@"added Astroid - num:%i", newAstroid.number);
    //[self addLabels:newAstroid];
    
}
/*
-(void)addAstroidToLine{
    if(newAstroidLine){
       // NSLog(@"calling [self addAstroid:YES]");
        [self addAstroid:NO];
        newAstroidLine = NO;
    }
    
    static CGFloat astroid2Diameter;
    static CGFloat astroid3Diameter;
    if(astroid2Diameter == 0.0){
        NSLog(@"getting diameter");
        SKSpriteNode *ast = [CSMAstroidSprite astroidWithType:2 scene:NULL];
        astroid2Diameter = ast.size.width;
        ast = [CSMAstroidSprite astroidWithType:3 scene:NULL];
        astroid3Diameter = ast.size.width;
    }
    
    int astroidDiameter = 20000;
    
    switch (astroidType) {
        case 2:
            astroidDiameter = astroid2Diameter;
            break;
        case 3:
            astroidDiameter = astroid3Diameter;
            break;
        default:
            NSLog(@"unknown astroidType %i in [CSMLevelBuildScene addAstroidToLine]", astroidType);
            break;
    }
    
    
    if([Tools getDistanceBetween:touch1 and:touch2] >= astroidDiameter){
        touch1 = CGPointMake(touch2.x, touch2.y);
        [self addAstroid:YES];
    }
}
*/
-(void)addWormhole:(CGPoint)location{
    CSMWormHoleSprite* wormhole = [[CSMWormHoleSprite alloc] initWithSettings:[Tools CSMWormHoleSettingsMake:location] scene:self];
    wormhole.name = @"wormhole";
    wormhole.zPosition = kDrawing1zPos;
    wormhole.userInteractionEnabled = YES;
    
    if(nodeSelected && [currentSprite isKindOfClass:[CSMNodeSprite class]]){
        CSMNodeSprite* n = (CSMNodeSprite*)currentSprite;
        wormhole.parentNumber = n.number;
    }
    
    [self.spriteHolder addChild:wormhole];
    [self setState:EDIT];
}

-(void)saveLevel{
    
    CSMLevel* newLevel = [CSMLevel levelWithSpriteHolder:self.spriteHolder num:currentLevelNumber fieldSize:fieldSize];
    [self.gameData saveLevel:newLevel];
}

-(void)addLevel{

    CSMLevel* newLevel = [CSMLevel levelWithSpriteHolder:self.spriteHolder num:++currentLevelNumber fieldSize:fieldSize];
    [self.gameData addLevel:newLevel];
    [self.gameData openBuildLevel:currentLevelNumber fromScene:self];
}

-(void)clearLevel{
    for(SKSpriteNode *sprite in [self.spriteHolder children]){
        if(![sprite.name isEqualToString:@"tile"])
            [sprite removeFromParent];
    }
}

-(void)deleteLevel{
    [self.gameData deleteLevel:currentLevelNumber];
    [self.gameData openMenuFromScene:self];
    //[self.levelsLibrary removeLevel:currentLevelNumber];
    //[self.levelsLibrary saveLibrary];
    //[super openMenu];
}

-(void)rotateSpritePrep{
    if(state == ROTATING_SPRITE){
        [rotateIcon removeFromParent];
        //selection = nil;
        [panelTOP close];
        [self setState:EDIT];
    }
    else{
        if(!rotateIcon)
            rotateIcon = [[SKSpriteNode alloc] initWithImageNamed:@"IconRotate.png"];
        [currentSprite addChild:rotateIcon];
        [self setState:ROTATING_SPRITE];
    }
}

-(void)rotateSprite{
    CGFloat ang1 = [Tools getAngleFrom:currentSprite.position to:touch1];
    CGFloat ang2 = [Tools getAngleFrom:currentSprite.position to:touch2];
    currentSprite.zRotation -= (ang1 - ang2);
    if([currentSprite isKindOfClass:[CSMSolidObject class]]){
        CSMSolidObject *so = (CSMSolidObject*)currentSprite;
        [so reshadow];
    }
    touch1 = touch2;
}

-(void)setSpriteSpin{
    //get rate of spin
    //UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2+20, 200, 40)];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    textField.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-100);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blueColor];
    textField.font = [UIFont systemFontOfSize:17.0];
    CSMAstroidSprite* as = (CSMAstroidSprite*) currentSprite;
    textField.placeholder = [NSString stringWithFormat:@"%f", as.angularVelocity];
    textField.backgroundColor = [UIColor whiteColor];
    //textField.autocorrectionType = UITextAutocorrectionTypeYes;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate = self;
    [self.view addSubview:textField];
    
    //set spin
    if([currentSprite.name isEqualToString:@"astroid"]){
        CSMAstroidSprite* as = (CSMAstroidSprite*)currentSprite;
        as.angularVelocity = 0.5;
    }
    else if([currentSprite.name isEqualToString:@"node"]){
        CSMNodeSprite* nde = (CSMNodeSprite*)currentSprite;
        nde.angularVelocity = 0.5;
    }
    else{
        NSLog(@"trying to set angular velocity on non-astroid");
    }
}

-(void)deselect{
    /*
    if([currentSprite.name isEqualToString:@"node"]){
        CSMNodeSprite* node = (CSMNodeSprite*)currentSprite;
        [node removeHighlight];
    }
     */
    
    currentSprite = nil;
    [self removeHighlight];
    if(rotateIcon.parent)
        [rotateIcon removeFromParent];
    if(panelTOP)
        [panelTOP close];
    /*
    if(selection.parent)
        selection.position = CGPointMake(200, 200);
     */
    
    [self setState:EDIT];

    
    /*
     if(state == SPRITE_SELECTED){
     currentSprite = nil;
     [spriteSelection removeFromParent];
     [panelTOP close];
     }
     else{
     selection.position = CGPointMake(200, 200);
     }
     if(!rotateIcon.parent)
     [rotateIcon removeFromParent];
     [self setState:NORMAL];
     */
}


#pragma mark scene tools

-(void)scrollFrom:(CGPoint)p1 to:(CGPoint)p2{
    //NSLog(@"scroll");
    CGFloat dX = p1.x - p2.x;
    CGFloat dY = p1.y - p2.y;
    
    CGFloat newX = self.spriteHolder.position.x - (dX * self.spriteHolder.xScale);
    CGFloat newY = self.spriteHolder.position.y - (dY * self.spriteHolder.yScale);
    
    self.spriteHolder.position = CGPointMake(newX, newY);
}

-(void)zoom{
    
    CGFloat startPinch = [Tools getDistanceBetween:pinchTouches[0] and:pinchTouches[1]];
    CGFloat endPinch = [Tools getDistanceBetween:pinchTouches[2] and:pinchTouches[3]];
    //touch1 = [Tools getMidPoint:pinchTouches[0] and:pinchTouches[1]];
    //touch2 = [Tools getMidPoint:pinchTouches[2] and:pinchTouches[3]];
    //self.marker.position = [Tools getMidPoint:pinchTouches[2] and:pinchTouches[3]];
    //NSLog(@"scrolling: %fx, %fy", touch2.x-touch1.x, touch2.y-touch1.y);
    //NSLog(@"centre: %f.1, %f.1", touch2.x, touch2.y);
    [self scrollFrom:[Tools getMidPoint:pinchTouches[0] and:pinchTouches[1]]
                  to:[Tools getMidPoint:pinchTouches[2] and:pinchTouches[3]]
     ];
    
    CGFloat scaleChange = endPinch / startPinch;
    
    [self zoom:scaleChange];
    
}

-(void)zoom:(CGFloat)scaleChange{
    if(
       (self.spriteHolder.xScale * scaleChange) < self.minScale
       ||
       (self.spriteHolder.xScale * scaleChange) > maxScale
       )
        return;
    
    //NSLog(@"scaleChange: %f", scaleChange);
    //NSLog(@"from: %f to: %f", self.spriteHolder.xScale, self.spriteHolder.xScale*scaleChange);
    self.spriteHolder.xScale = self.spriteHolder.xScale * scaleChange;
    self.spriteHolder.yScale = self.spriteHolder.yScale * scaleChange;
}

-(void)closePanelTop{
    [panelTOP close];
}

-(void)setState:(BuildState)newState{
    state = newState;
    
    switch (newState) {
            /*
        case NORMAL:
            stateLabel.text = @"READY";
            break;
             */
        case SCROLLZOOM:
            stateLabel.text = @"SCROLLZOOM";
            break;
        case EDIT:
            stateLabel.text = @"EDIT";
            break;
        case ADDING_ENEMY:
            stateLabel.text = @"ADDING_ENEMY";
            break;
        case ADDING_ENEMYSPAWNPOINT:
            stateLabel.text = @"ADDING_ENEMYSPAWNPONT";
            break;
        case ADDING_ENEMYARTILARY:
            stateLabel.text = @"ADDING_ENEMYARTILARY";
            break;
        case ADDING_ENEMYEGG:
            stateLabel.text = @"ADDING_ENEMYEGG";
            break;
        case ADDING_SHARPENER:
            stateLabel.text = @"ADDING_SHARPENER";
            break;
        case ADDING_PENCIL:
            stateLabel.text = @"ADDING_PENCIL";
            break;
        case ADDING_ERASER:
            stateLabel.text = @"ADDING_ERASER";
            break;
        case PLACING_ROCKET:
            stateLabel.text = @"PLACING_ROCKET";
            break;
        case ADDING_ASTROID:
            stateLabel.text = @"ADDING_ASTROID";
            break;
        //case ADDING_ASTROIDLINE:
          //  stateLabel.text = @"ADDING_ASTROIDLINE";
            //break;
        case ADDING_WORMHOLE:
            stateLabel.text = @"ADDING_WORMHOLE";
            break;
        case ROTATING_SPRITE:
            stateLabel.text = @"ROTATING_SPRITE";
            break;
        case SPRITE_SELECTED:
            stateLabel.text = @"SPRITE_SELECTED";
            break;
        case NODE_SELECTED:
            stateLabel.text = @"NODE_SELECTED";
            break;
        case ADDING_NODE:
            stateLabel.text = @"ADDING_NODE";
            break;
        default:
            stateLabel.text = @"UNKNOWN STATE";
            break;
    }
    
}

-(void)deadenSprites{
    //NSLog(@"deadenSprites");
    for(SKNode* node in self.spriteHolder.children){
        //NSLog(@"considerg %@", node.name);
        if([node isKindOfClass:[CSMSpriteNode class]] == YES){
            //NSLog(@"Deadening %@", node.name);
            node.userInteractionEnabled = NO;
        }
    }
}

-(void)enlivenSprites{
    for(SKNode* node in self.spriteHolder.children){
        if([node isKindOfClass:[CSMSpriteNode class]] == YES){
            node.userInteractionEnabled = YES;
        }
    }
}

-(void)removeHighlight{
    if(highlight){
        if([highlight parent])
            [highlight removeFromParent];
        highlight = NULL;
    }
}

-(int)getNewParentNumber{
    
    nextParentNumber++;
   // NSLog(@"getNewParentNumber:%i", nextParentNumber);
    return nextParentNumber;
}

-(void)setNextParentNumber{
    int num = 0;
    for(CSMSpriteNode* node in self.spriteHolder.children){
        if(([node isKindOfClass:[CSMNodeSprite class]] || [node isKindOfClass:[CSMAstroidSprite class]]) == YES){
            //NSLog(@"%@:%i", node.name, node.number);
            if(node.number > num)
                num = node.number;
        }
    }
    nextParentNumber =  num;
    //NSLog(@"nextParentNumber:%i", nextParentNumber);
}

-(void)addLabels:(CSMSpriteNode*) sn{
    SKLabelNode* label = [[SKLabelNode alloc] initWithFontNamed:@"Ariel"];
    label.text = [NSString stringWithFormat:@"n:%i", sn.number];
    label.name = @"label";
    label.position = CGPointMake(sn.position.x+50, sn.position.y);
    label.fontSize = 30;
    label.fontColor = [UIColor iconBlue];
    label.zPosition = kDrawing2zPos;
    label.userInteractionEnabled = NO;
    [self.spriteHolder addChild:label];
    
    SKLabelNode* label2 = [label copy];
    label2.text = [NSString stringWithFormat:@"p:%i", sn.parentNumber];
    label2.name = @"label";
    label.position = CGPointMake(sn.position.x+50, sn.position.y+30.0);
    label2.userInteractionEnabled = NO;
    [self.spriteHolder addChild:label2];
}

#pragma mark delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([currentSprite.name isEqualToString:@"astroid"]){
        CSMAstroidSprite* as = (CSMAstroidSprite*)currentSprite;
        NSLog(@"angularVe;: %f", [textField.text floatValue]);
        as.angularVelocity = [textField.text floatValue];
        NSLog(@"AngVel set to:%f", as.angularVelocity);
    }
    else if ([currentSprite.name isEqualToString:@"enemyspawnpoint"]){
        CSMEnemySpawnPoint* esp = (CSMEnemySpawnPoint*)currentSprite;
        esp.spawnRate = [textField.text floatValue];
        NSLog(@"spawn rate ste to:%f", esp.spawnRate);
    }
    else if([currentSprite.name isEqualToString:@"node"]){
        CSMNodeSprite* nde = (CSMNodeSprite*)currentSprite;
        nde.angularVelocity = [textField.text floatValue];
        NSLog(@"angularVel set to:%f", nde.angularVelocity);
    }
    [textField resignFirstResponder];
    [textField removeFromSuperview];
    
    return YES;
}

-(BOOL)editMode{
    if (state == SCROLLZOOM)
        return NO;
    else
        return YES;
}

@end


