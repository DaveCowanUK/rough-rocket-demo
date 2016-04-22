//
//  CSMMenuScene.m
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMMenuScene.h"
#import "CSMGamePlayScene.h"
#import "ButtonSprite.h"
#import "CSMLevelsLibrary.h"
#import "CSMLevel.h"
#import "CSMResponsiveLabel.h"
#import "CSMLevelIcon.h"
#import "Tools.h"
#import "CSMGameData.h"
#import "CSMSpriteMove.h"

#ifdef compileWithBuildModule
#import "CSMLevelBuildScene.h"
#endif


//#define originalLevelsLabelPos CGPointMake(-self.frame.size.width/2 + 100, self.frame.size.height/2 - 100)
//#define myLevelsLabelPos CGPointMake(-self.frame.size.width/2 + 100, self.frame.size.height/2 - 180)
//#define loadedLevelsLabelPos CGPointMake(-self.frame.size.width/2 + 100, self.frame.size.height/2 - 260)

//#define originalLevelsLabelPos CGPointMake(-kFieldSizeX/2 + 100, kFieldSizeY/2 - 75)
//#define myLevelsLabelPos CGPointMake(-kFieldSizeX/2 + 100, kFieldSizeY/2 - 135)
//#define loadedLevelsLabelPos CGPointMake(-kFieldSizeX/2 + 100, kFieldSizeY/2 - 190)

#define originalLevelsScrollPos CGPointMake(kFieldSizeX/2 - self.frame.size.width*1.5, -kFieldSizeY/2 + self.frame.size.height/2)
//#define originalLevelsScrollPos CGPointMake(-kFieldSizeX/2, kFieldSizeY/2)
//#define myLevelsScrollPos CGPointMake(kFieldSizeX/2 - self.frame.size.width*1.5, -kFieldSizeY/2 + self.frame.size.height*1.5)
//#define loadedLevelsScrollPos CGPointMake(kFieldSizeX/2 - self.frame.size.width*1.5, -kFieldSizeY/2 + self.frame.size.height*2.5)

//#define originalLevelsPos CGPointMake(-kFieldSizeX/2 + self.frame.size.width*1, kFieldSizeY/2 - self.frame.size.height/2)
//#define originalLevelsPos CGPointMake(-kFieldSizeX/2, kFieldSizeY/2)

#define buildButtonPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) + 40 ,kFieldSizeY/2 - self.frame.size.height + 50)
#define addLevelMenuButtonPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) - 40 ,kFieldSizeY/2 - self.frame.size.height + 50)

#define queryButtonPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) - 50 ,kFieldSizeY/2 - self.frame.size.height/2 + 25)
#define playButtonPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) + 50 ,kFieldSizeY/2 - self.frame.size.height/2 + 25)
#define centreButtonPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) ,kFieldSizeY/2 - self.frame.size.height/2 + 25)
#define musicAcknoPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) ,kFieldSizeY/2 - self.frame.size.height/2 - 75)
//#define musicAcknoPos CGPointMake((-kFieldSizeX/2+self.frame.size.width-200) ,kFieldSizeY/2 - self.frame.size.height + 54)
#define gameAcknoPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) ,kFieldSizeY/2 - self.frame.size.height/2 - 108)
#define soundButtonPos CGPointMake((-kFieldSizeX/2+self.frame.size.width/2) ,kFieldSizeY/2 - self.frame.size.height/2 -120)



#define startPos CGPointMake(kFieldSizeX/2 - self.frame.size.width/2, -kFieldSizeY/2 + self.frame.size.height/2)
#define originalLevelsPos CGPointMake(-kFieldSizeX/2+self.frame.size.width+80, kFieldSizeY/2 - self.frame.size.height/2)
#define originalLevelsLabelPos  CGPointMake(-kFieldSizeX/2+self.frame.size.width+60, kFieldSizeY/2)

#define backArrowPos CGPointMake(-kFieldSizeX/2+self.frame.size.width+40, kFieldSizeY/2 - self.frame.size.height/2 + 25)
#define gameCenterControlPos CGPointMake(-kFieldSizeX/2+(2*self.frame.size.width)-40, kFieldSizeY/2 - 60)
#define scorePos CGPointMake(-kFieldSizeX/2+(2*self.frame.size.width)-25, kFieldSizeY/2 - 30)

//#define gameCenterControlPos CGPointMake( self.frame.size.width/2 - 30 , self.frame.size.height/2 -60)


typedef enum {
    NORMAL = 0,
    BUILD,
    PLAY,
} MenuState;

@interface CSMMenuScene()
@property CSMLevelsLibrary* levelsLibrary;
@property CSMGameData* gameData;
@property ButtonSprite* queryControl;
@property ButtonSprite* playControl;
@property ButtonSprite* gameCenterControl;
@property ButtonSprite* speakerControl;

@end


@implementation CSMMenuScene{
    MenuState state;
    CGPoint touch1;
    CGPoint touch2;
    //NSMutableArray *pinchTouches;
    CGPoint pinchTouches [4];
    CGPoint currentLevelScrollPos;
    BOOL displayLevelsToStart;
    
    CSMSpriteMove* spriteMove;
    
    BOOL bAllowVerticalScroll;
    CGFloat maxY;
    CGFloat minY;
    
    SKLabelNode* totalScoreLabel;
}

-(id)initWithSize:(CGSize)size{
    //[self authenticateLocalPlayer];
    return [self initWithSize:size gameData:nil levels:NO];
}
/*
 -(id)initWithSize:(CGSize)size pos:(CSMMenuPos)pos{
 return [self initWithSize:size pos:pos gameData:nil];
 }
 */

-(id)initWithSize:(CGSize)size gameData:(id)gData levels:(BOOL)startAtLevels{
    
    if([super initWithSize:size]){
        if(startAtLevels){
            //menuPos = originalLevelsScrollPos;
            displayLevelsToStart = YES;
            bAllowVerticalScroll = YES;
        }
        else{
            //menuPos = startPos;
            displayLevelsToStart = NO;
            bAllowVerticalScroll = NO;
        }
        
        if(gData)
            self.gameData = gData;
        else
            self.gameData = [CSMGameData gameData];
    }
    self.name = @"menuscene";
    
    
    return self;
}

+(CSMMenuScene*)sceneWithSize:(CGSize)size gameData:(id)gData{
    return [[CSMMenuScene alloc]initWithSize:size gameData:gData levels:NO];
}

+(CSMMenuScene*)sceneWithSize:(CGSize)size viewController:(SpriteViewController *)vc{
    CSMMenuScene* scene =  [[CSMMenuScene alloc]initWithSize:size];
    scene.gameData.vc = vc;
    return scene;
}

+(CSMMenuScene*)sceneWithSize:(CGSize)size gameData:(id)gData levels:(BOOL)startAtLevels{
    return [[CSMMenuScene alloc]initWithSize:size gameData:gData levels:YES];
}

-(void)createSceneContents{
    //NSLog(@"creating CSMMenuScene");
    [super createSceneContents];
    super.backControl.userInteractionEnabled = NO;
    super.backControl.hidden = YES;
    [self.backControl removeFromParent];
    
    state = NORMAL;
    
    
    
    /*
     //contents labels
     [self responsiveLabelAdd:@"Original Levels" position:originalLevelsLabelPos];
     [self responsiveLabelAdd:@"My Levels" position:myLevelsLabelPos];
     [self responsiveLabelAdd:@"Loaded Levels" position:loadedLevelsLabelPos];
     */
    
#ifdef compileWithBuildModule
    
    SKTexture *buildIconTexture = [SKTexture textureWithImageNamed:@"BuildIcon.png"];
    self.buildControl = [[ButtonSprite alloc]initWithTexture: buildIconTexture scene:self type:kBuild];
    self.buildControl.position = buildButtonPos;
    self.buildControl.userInteractionEnabled = YES;
    self.buildControl.alpha = 1.0;
    self.buildControl.zPosition = kIcon1zPos;
    //self.buildControl.hidden = YES;
    [self.spriteHolder addChild:self.buildControl];
    
    SKTexture *addLevelIconTexture = [SKTexture textureWithImageNamed:@"IconAddLevel.png"];
    self.addLevelControl = [[ButtonSprite alloc]initWithTexture: addLevelIconTexture scene:self type:kAddLevel];
    self.addLevelControl.position = addLevelMenuButtonPos;
    self.addLevelControl.userInteractionEnabled = YES;
    self.addLevelControl.alpha = 1.0;
    self.addLevelControl.zPosition = kIcon1zPos;
    //self.addLevelControl.hidden = YES;
    [self.spriteHolder addChild:self.addLevelControl];
     
#endif
    
    
    SKTexture *queryIconTexture = [SKTexture textureWithImageNamed:@"queryControl.png"];
    self.queryControl = [[ButtonSprite alloc]initWithTexture: queryIconTexture scene:self type:kQuery];
    self.queryControl.position = queryButtonPos;
    self.queryControl.userInteractionEnabled = YES;
    self.queryControl.alpha = 1.0;
    self.queryControl.zPosition = kIcon1zPos;
    //self.queryControl.hidden = YES;
    [self.spriteHolder addChild:self.queryControl];
    
    SKTexture *playIconTexture = [SKTexture textureWithImageNamed:@"playControl.png"];
    self.playControl = [[ButtonSprite alloc]initWithTexture: playIconTexture scene:self type:kPlay];
    self.playControl.position = playButtonPos;
    self.playControl.userInteractionEnabled = YES;
    self.playControl.alpha = 1.0;
    self.playControl.zPosition = kIcon1zPos;
    //self.playControl.hidden = YES;
    [self.spriteHolder addChild:self.playControl];
    
    SKTexture *arrowLeftTexture = [SKTexture textureWithImageNamed:@"ArrowLeft.png"];
    self.backControl = [[ButtonSprite alloc]initWithTexture: arrowLeftTexture scene:self type:kBack];
    self.backControl.position = backArrowPos;
    self.backControl.userInteractionEnabled = YES;
    self.backControl.alpha = 1.0;
    self.backControl.zPosition = kIcon1zPos;
    //self.backControl.hidden = YES;
    [self.spriteHolder addChild:self.backControl];
    
    SKTexture *speakerIconTexture;
    if([self.gameData musicPlaying]){
        speakerIconTexture = [SKTexture textureWithImageNamed:@"IconSpeaker.png"];
    }
    else{
        speakerIconTexture = [SKTexture textureWithImageNamed:@"IconSpeakerCrossed.png"];
    }
    self.speakerControl = [[ButtonSprite alloc]initWithTexture: speakerIconTexture scene:self type:kToggleSound];
    self.speakerControl.position = soundButtonPos;
    self.speakerControl.userInteractionEnabled = YES;
    self.speakerControl.alpha = 0.9;
    self.speakerControl.zPosition = kIcon1zPos;
    //self.playControl.hidden = YES;
    [self.spriteHolder addChild:self.speakerControl];
    
    CSMResponsiveLabel* musicAckno = [[CSMResponsiveLabel alloc]initWithScene:self];
    musicAckno.fontName = @"Chalkduster";
    musicAckno.text = MUSIC_ACKNO_STRING;
    musicAckno.alpha = 1.0;
    musicAckno.name = @"label";
    musicAckno.position = musicAcknoPos;
    musicAckno.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    musicAckno.fontSize = 17;
    musicAckno.fontColor = [UIColor iconBlue];
    musicAckno.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:musicAckno];
    
    SKTexture* newWindowTexture = [SKTexture textureWithImageNamed:@"IconNewWindow.png"];
    ButtonSprite* musicLinkButton = [[ButtonSprite alloc] initWithTexture:newWindowTexture scene:self type:kMusicLink];
    musicLinkButton.anchorPoint = CGPointMake(0.5, 0.25);
    musicLinkButton.xScale = 0.75;
    musicLinkButton.yScale = 0.75;
    musicLinkButton.position = CGPointMake(musicAckno.frame.origin.x + musicAckno.frame.size.width + 25, musicAckno.position.y);
    musicLinkButton.userInteractionEnabled = YES;
    musicLinkButton.alpha = 0.9;
    musicLinkButton.zPosition = kIcon1zPos;
    [self.spriteHolder addChild:musicLinkButton];
  
    /*
    CSMResponsiveLabel* gameAckno = [[CSMResponsiveLabel alloc]initWithScene:self];
    gameAckno.fontName = @"Chalkduster";
    gameAckno.text = GAME_ACKNO_STRING;
    gameAckno.alpha = 0.7;
    gameAckno.name = @"label";
    gameAckno.position = gameAcknoPos;
    gameAckno.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    gameAckno.fontSize = 17;
    gameAckno.fontColor = [UIColor iconBlue];
    gameAckno.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:gameAckno];
    */
    
    
    // [self hideFrameControls];
    
    
    //self.levelsLibrary = [CSMLevelsLibrary levelsLibraryFromKeyedArchive];
    self.levelsLibrary = [CSMLevelsLibrary levelsLibrary];
    
    SKTexture* levelIcon = [SKTexture textureWithImageNamed:@"IconSelected.png"];
    SKTexture* lockedLevelIcon = [SKTexture textureWithImageNamed:@"IconSelectedGray.png"];
    SKTexture* redtickIcon = [SKTexture textureWithImageNamed:@"tickred.png"];
    
    
    CGFloat labelIconx = originalLevelsPos.x;// + margin;
    CGFloat labelIcony = originalLevelsPos.y;// - (margin/1.5);
    
    currentLevelScrollPos = originalLevelsScrollPos;
    
    if(self.levelsLibrary != nil){
        
        NSArray* keys = [self.levelsLibrary.seedDictionary allKeys];
        NSArray* sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
        NSArray* points = [self getGridFor:CGRectMake(originalLevelsLabelPos.x,
                                                      originalLevelsLabelPos.y,
                                                      self.frame.size.width-150,
                                                      self.frame.size.height)
                                edgeMargin:outerMargin
                                     space:iconSpace
                                      with:[sortedKeys count]
                           ];
        int i = 0;
        int incompleteLevelCount = 0;
        
        for(NSNumber* levelNumber in sortedKeys){
            
            CSMLevelIcon* levelButton;
            
            if(incompleteLevelCount < 3){
                levelButton = [[CSMLevelIcon alloc]initWithTexture:levelIcon scene:self type:kLevel];
                [levelButton addChild:[self labelMake:[levelNumber stringValue] position:CGPointMake(0, -10)]];
                levelButton.alpha = 0.7;
                
                //check if incomplete level is off screen
                if( ((originalLevelsLabelPos.y - [[points objectAtIndex:i] CGPointValue].y) * self.spriteHolder.yScale) > self.frame.size.height ){
                    //NSLog(@"offfscreen");
                    currentLevelScrollPos = CGPointMake(originalLevelsScrollPos.x, -[[points objectAtIndex:i] CGPointValue].y);
                }
                //menuPos = currentLevelScrollPos;
            }
            else{
                levelButton = [[CSMLevelIcon alloc]initWithTexture:lockedLevelIcon scene:self type:kLevel];
                
#ifdef levelsLocked
                levelButton.userInteractionEnabled = NO;
#endif
                
                levelButton.alpha = 0.5;
                SKLabelNode* ln = [self labelMake:[levelNumber stringValue] position:CGPointMake(0, -10)];
                ln.fontColor = [UIColor grayColor];
                [levelButton addChild:ln];
            }
            levelButton.name = @"levelbutton";
            //levelButton.position = CGPointMake( (labelIconx - 3 + rand()%6) , (labelIcony - 4 + rand()%8) );
            
            
            levelButton.zPosition = kDrawing1zPos;
            
            //[levelButton addChild:[self labelMake:[levelNumber stringValue] position:CGPointMake(0, -10)]];
            
            //add ticks for completed levels
            if([self.gameData scoreForLevel:[levelNumber intValue]] > 0){
                SKSpriteNode* tickSprite = [SKSpriteNode spriteNodeWithTexture:redtickIcon];
                tickSprite.position = CGPointMake(19, -4);
                [levelButton addChild:tickSprite];
                
                //add score
                SKLabelNode* scoreLabel = [self labelMake:[NSString stringWithFormat:@"%i",[self.gameData scoreForLevel:[levelNumber intValue]]] position:CGPointMake(20.0, -40.0)];
                scoreLabel.fontColor = [SKColor colorWithRed:0.78 green:0.0 blue:0.0 alpha:1];
                scoreLabel.fontSize = 17;
                [levelButton addChild:scoreLabel];
                
            }
            else{
                incompleteLevelCount++;
            }
            levelButton.position = [[points objectAtIndex:i] CGPointValue];
            i++;
            
            [self.spriteHolder addChild:levelButton];
            maxY = -levelButton.position.y;
           // NSLog(@"maxY:%f", maxY);
        }
    }
    
    if(self.levelsLibrary == nil || [self.levelsLibrary.seedDictionary count] == 0){
        CSMLevelIcon* levelButton = [[CSMLevelIcon alloc]initWithTexture:levelIcon scene:self type:kLevel];
        levelButton.position = CGPointMake( (labelIconx - 3 + rand()%6) , (labelIcony - 4 + rand()%8) );
        levelButton.alpha = 0.7;
        SKLabelNode* levelLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        levelLabel.name = @"label";
        levelLabel.position = CGPointMake(0, -10);
        levelLabel.fontSize = 30;
        levelLabel.fontColor = [UIColor iconBlue];
        levelLabel.text = @"0";
        levelLabel.zPosition = 10;
        [levelButton addChild:levelLabel];
        [self.spriteHolder addChild:levelButton];
        //NSLog(@"loadin blank");
        
    }
    
    //total score
    totalScoreLabel = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
    totalScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    totalScoreLabel.fontSize = 20;
    totalScoreLabel.fontColor = [UIColor iconBlue];
    totalScoreLabel.text = [NSString stringWithFormat:@":%i", [self.gameData totalScore]];
    totalScoreLabel.position = scorePos;
    totalScoreLabel.zPosition = kIcon1zPos;
    [self.spriteHolder addChild:totalScoreLabel];
    
    
    minY = startPos.y;
    
    if(displayLevelsToStart){
        self.spriteHolder.position = currentLevelScrollPos;
    }
    else{
        self.spriteHolder.position = startPos;
    }
    
    if([self.gameData gameCenterEnabled]){
        [self showGameCenterControl];
    }
    
}

-(void)showGameCenterControl{
    
    //add GameCentre control
    if(!self.gameCenterControl){
        SKTexture *gameCenterIconTexture = [SKTexture textureWithImageNamed:@"gameCenterControlSmall.png"];
        self.gameCenterControl = [[ButtonSprite alloc]initWithTexture: gameCenterIconTexture scene:self type:kGameCenter];
        self.gameCenterControl.position = gameCenterControlPos;
        self.gameCenterControl.userInteractionEnabled = YES;
        self.gameCenterControl.alpha = 1.0;
        self.gameCenterControl.zPosition = kIcon1zPos;
        //self.gameCenterControl.hidden = YES;
        [self.spriteHolder addChild:self.gameCenterControl];
    }
    
}

#pragma mark - Actions

-(void)openGameScene:(int)levelNumber{
    
    [self.gameData openGamePlayLevel:levelNumber fromScene:self];

}

-(void)openBuildScene:(int)levelNumber{
#ifdef compileWithBuildModule
    [self.gameData openBuildLevel:levelNumber fromScene:self];
#endif
    /*
     NSLog(@"menu openBuildScene]");
     CSMLevel* level = [self.levelsLibrary level:levelNumber];
     //SKScene * scene = [CSMLevelBuildScene sceneWithSize:self.size];
     SKScene * scene = [CSMLevelBuildScene sceneWithSize:self.size library:self.levelsLibrary level:level];
     SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
     [self.view presentScene:scene transition:doors];
     */
}

-(void)addLevel{
    #ifdef compileWithBuildModule
    SKScene * scene = [CSMLevelBuildScene sceneWithSize:self.size library:self.levelsLibrary level:[CSMLevel emptyLevel:[self.levelsLibrary newLevelNumber]]];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:scene transition:doors];
#endif
    /*
     int i = self.levelsLibrary.newLevelNumber;
     //NSLog(@"[menu addLevel]: %i", i);
     [self openBuildScene:i];
     */
}

#pragma mark - User Input

-(void)buttonReleased:(ButtonType)button{
    switch (button) {
        case kBack:
            //[self slowScrollTo:startPos];
            spriteMove = [[CSMSpriteMove alloc]initNode:self.spriteHolder to:startPos duration:0.7];
            bAllowVerticalScroll = NO;
            //[self hideFrameControls];
            break;
        case kAddLevel:
            [self addLevel];
            break;
        case kBuild:
            if(state == BUILD){
                state = NORMAL;
                [self hideEditIcons];
            }
            else{
                state = BUILD;
                [self showEditIcons];
            }
            break;
        case kPlay:
            self.backControl.position = backArrowPos;
            spriteMove = [[CSMSpriteMove alloc]initNode:self.spriteHolder to:currentLevelScrollPos duration:0.7];
            bAllowVerticalScroll = YES;
            break;
        case kQuery:
            [self.gameData openDemoLevelFromScene:self];
            break;
        case kGameCenter:
            //NSLog(@"gameCenter control released");
            [self.gameData showLeaderboard];
            break;
        case kMusicLink:
            [self linkToMusicPage];
            break;
        case kToggleSound:
            [self toggleSound];
            break;
        default:
            //NSLog(@"unrecognised ButtonType");
            break;
    }
}

-(void)labelTouched:(NSString *)labelText{
    
    if([labelText isEqualToString:MUSIC_ACKNO_STRING]){
        //NSLog(@"\n\nlink to web");
        [self linkToMusicPage];
    }
    
    else if (labelText.intValue >= 0){
        //NSLog(@"labelTouched");
        if(state == BUILD)
            [self openBuildScene:labelText.intValue];
        else
            [self openGameScene:labelText.intValue];
    }
    [self showFrameControls];
}

-(void)linkToMusicPage{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MUSIC_LINK_URL_STRING]];
}

-(void)toggleSound{
    if([self.gameData toggleSound]){
        self.speakerControl.texture = [SKTexture textureWithImageNamed:@"IconSpeaker.png"];
    }
    else{
        self.speakerControl.texture = [SKTexture textureWithImageNamed:@"IconSpeakerCrossed.png"];
    }
    
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    
    //check for move
    if([allTouches count] == 1)
        touch1 = [[allTouches anyObject] locationInNode:self.spriteHolder];
    
    /*
    //check for pinch
    else if([allTouches count] == 2){
        int i=0;
        for(UITouch *touch in [allTouches allObjects]){
            pinchTouches[i] = [touch locationInNode:self.spriteHolder];
            i++;
        }
        touch1 = CGPointMake(0, 0);
        touch2 = CGPointMake(0, 0);
        //place marker in the midddle of the thouch
        //self.marker.position = [Tools getMidPoint:pinchTouches[0] and:pinchTouches[1]];
    }
     */
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
   // NSLog(@"MenuTouchesMoved");
    NSSet *allTouches = [event allTouches];
    
    //check for move
    if([allTouches count] == 1){
        touch2 = [[allTouches anyObject] locationInNode:self.spriteHolder];
        
        [self scrollFrom:touch1 to:touch2];
        
        
    }
    /*
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
    */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    
    //check for move or ad item
    if([allTouches count] == 1){
        touch2 = [[allTouches anyObject] locationInNode:self.spriteHolder];
        [self scrollFrom:touch1 to:touch2];
        
    }
    /*
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
     */
}



#pragma mark loop methods

-(void)scrollControl:(NSTimeInterval)currentTime{
    if(spriteMove){
        self.spriteHolder.position = [spriteMove currentPointPos:currentTime];
        if(spriteMove.complete)
            spriteMove = nil;
    }
}

-(void)update:(NSTimeInterval)currentTime{
    [self scrollControl:currentTime];
    [self checkButtonPositions];
}

#pragma mark helpers

-(void)scrollFrom:(CGPoint)p1 to:(CGPoint)p2{
    
    if(bAllowVerticalScroll){
        CGFloat dY = p1.y - p2.y;
        
        CGFloat newX = self.spriteHolder.position.x;
        CGFloat newY = self.spriteHolder.position.y - (dY * self.spriteHolder.yScale);
        
        if( (newY > minY) && (newY < maxY) )
            self.spriteHolder.position = CGPointMake(newX, newY);
    }
    
    //[self checkButtonPositions];
    
    /*
    //NSLog(@"scroll");
    CGFloat dX = p1.x - p2.x;
    CGFloat dY = p1.y - p2.y;
    
    CGFloat newX = self.spriteHolder.position.x - (dX * self.spriteHolder.xScale);
    CGFloat newY = self.spriteHolder.position.y - (dY * self.spriteHolder.yScale);
    
    self.spriteHolder.position = CGPointMake(newX, newY);
    */
}

-(void)slowScrollTo:(CGPoint)point{
    point = CGPointMake(point.x * self.spriteHolder.xScale, point.y * self.spriteHolder.yScale);
    SKAction* scrollAction = [SKAction moveTo:point duration:0.5];
    /*
     SKAction* zooming = [SKAction sequence:@[
     [SKAction scaleTo:0.5 duration:1.0],
     [SKAction scaleTo:1.0 duration:1.0]
     ]];
     */
    [self.spriteHolder runAction:[SKAction group:@[scrollAction]]];
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

-(void)checkButtonPositions{
    
    //score
    totalScoreLabel.position = CGPointMake(
                                           totalScoreLabel.position.x,
                                           self.frame.size.height/2 - 30 - self.spriteHolder.position.y
                                           );
    
    //gamecenter control
    if(self.gameCenterControl){
        self.gameCenterControl.position = CGPointMake(
                                                      self.gameCenterControl.position.x,
                                                      self.frame.size.height/2 - 60 - self.spriteHolder.position.y
                                                      );
    }
    
    //back button
    CGFloat maxHeight =  self.frame.size.height/2 - 30;//kFieldSizeY/2 + self.spriteHolder.position.y;
    CGFloat minHeight = -self.frame.size.height/2 + 30;
    
    //CGPoint positionInFrame = [self convertPoint:self.backControl.position fromNode:self.spriteHolder];
    
    if( (self.backControl.position.y + self.spriteHolder.position.y) > maxHeight ){
        self.backControl.position = CGPointMake(
                                                self.backControl.position.x,
                                                maxHeight - self.spriteHolder.position.y
                                                );
    }
    else if( (self.backControl.position.y + self.spriteHolder.position.y) < minHeight ){
        self.backControl.position = CGPointMake(
                                                self.backControl.position.x,
                                                minHeight - self.spriteHolder.position.y
                                                );
    }
    
    
}

-(SKLabelNode*)labelMake:(NSString*)str position:(CGPoint)position{
    SKLabelNode* label = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    label.text = str;
    label.name = @"label";
    label.position = position;
    label.fontSize = 30;
    label.fontColor = [UIColor iconBlue];
    label.zPosition = 10;
    return label;
}

-(void)responsiveLabelAdd:(NSString*)str position:(CGPoint)position{
    CSMResponsiveLabel* label = [[CSMResponsiveLabel alloc] initWithScene:self];
    label.fontName = @"Chalkduster";
    label.text = str;
    label.name = @"label";
    label.position = position;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    label.fontSize = 30;
    label.fontColor = [UIColor iconBlue];
    label.zPosition = kDrawing1zPos;
    [self.spriteHolder addChild:label];
}

-(NSArray*)getGridFor:(CGRect)rect edgeMargin:(CGFloat)edgeMargin space:(CGFloat)space with:(unsigned long)count{
    
    // NSLog(@"\n\n\ngetGridFor:(CGRect)%f %f %f %f space:(CGFloat)%f, with:(ul)%lu", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, space, count);
    
    ///////
    /*
    SKSpriteNode* tl = [[SKSpriteNode alloc]initWithColor:[SKColor purpleColor] size:CGSizeMake(30, 30)];
    tl.position = rect.origin;
    tl.zPosition = kIcon1zPos;
    [self.spriteHolder addChild:tl];
    
    SKSpriteNode* tr = [[SKSpriteNode alloc]initWithColor:[SKColor purpleColor] size:CGSizeMake(30, 30)];
    tr.position = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    tr.zPosition = kIcon1zPos;
    [self.spriteHolder addChild:tr];
    */
    //////
    
    NSMutableArray* grid  = [NSMutableArray arrayWithCapacity:count];
    

    if(rect.size.width < (space * 2))
        return [NSArray arrayWithArray:grid];
    
    CGFloat pX = rect.origin.x + edgeMargin;
    CGFloat pY = rect.origin.y - edgeMargin;
    CGFloat xMax = rect.origin.x + rect.size.width;// - edgeMargin;
    //CGFloat yMax = rect.origin.y + rect.size.height - space;
    
    for(int i=0; i<count; i++){
        
        [grid addObject:[NSValue valueWithCGPoint:CGPointMake(pX, pY)]];
        
        ///////////
        /*
        SKSpriteNode* tr = [[SKSpriteNode alloc]initWithColor:[SKColor purpleColor] size:CGSizeMake(10, 10)];
        tr.position = CGPointMake(pX, pY);
        tr.zPosition = kIcon1zPos;
        [self.spriteHolder addChild:tr];
         */
        
        ///////////
        
        pX += space;
        
        if(pX > xMax){
            pX = rect.origin.x + edgeMargin;
            pY -= space;
        }
        
        
    }
    
    return [NSArray arrayWithArray:grid];
}

-(void)showFrameControls{
    [self.backControl runAction:[SKAction fadeInWithDuration:0.3]];
    self.buildControl.hidden = NO;
    self.addLevelControl.hidden = NO;
    [self.buildControl runAction:[SKAction fadeInWithDuration:0.3]];
    [self.addLevelControl runAction:[SKAction fadeInWithDuration:0.3]];
    
}

-(void)hideFrameControls{
    [self.backControl runAction:[SKAction fadeOutWithDuration:0.3]];
    [self.buildControl runAction:[SKAction fadeOutWithDuration:0.3]];
    [self.addLevelControl runAction:[SKAction fadeOutWithDuration:0.3]];
}

-(void)showEditIcons{
    //prepare Edit Icon
    //add to each button
    for(SKSpriteNode *sprite in [self.spriteHolder children]){
        if([sprite.name isEqualToString:@"levelbutton"]){
            SKSpriteNode* pencilIcon = [[SKSpriteNode alloc]initWithImageNamed:@"IconPencil.png"];
            pencilIcon.name = @"pencilIcon";
            pencilIcon.position = CGPointMake(15, -15);
            [sprite addChild:pencilIcon];
        }
    }
}

-(void)hideEditIcons{
    for(SKSpriteNode *sprite in [self.spriteHolder children]){
        if([sprite.name isEqualToString:@"levelbutton"]){
            [[sprite childNodeWithName:@"pencilIcon"] removeFromParent];
        }
    }
}

#ifdef compileWithGameKit
/*
- (void) showGameCenter
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
 */


#endif

-(void)clearReferences{
    [super clearReferences];
    self.buildControl = nil;
    self.addLevelControl = nil;
    self.settingsControl = nil;
    self.viewController = nil;
    self.levelsLibrary = nil;
    self.gameData = nil;
    self.queryControl = nil;
    self.playControl = nil;
    self.gameCenterControl = nil;
}

@end
