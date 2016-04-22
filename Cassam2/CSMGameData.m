//
//  CSMGameData.m
//  Cassam2
//
//  Created by The Cowans on 07/10/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMGameData.h"
#import "CSMScoreRegister.h"
#import "CSMLevelsLibrary.h"
#import "CSMGamePlayScene.h"
#import "CSMMenuScene.h"
#import "CSMLevel.h"
#import "CSMScoreRegister.h"
#import "CSMTestScene.h"
#import "SpriteViewController.h"
#import "CSMDemoScene.h"
#import "CSMThumbPlayScene.h"
//#import "UIView.h"

#ifdef compileWithBuildModule
#import "CSMLevelBuildScene.h"
#endif

@interface CSMGameData()

@property CSMLevelsLibrary* levelsLibrary;
@property CSMScoreRegister* scoreRegister;
@property NSMutableDictionary* imageDictionary;

@end

@implementation CSMGameData{
    GKLocalPlayer* localPlayer;
}

+(CSMGameData*)gameData{
    return [[CSMGameData alloc]init];
}

-(id)init{
    if([super init]){
        _levelsLibrary = [CSMLevelsLibrary levelsLibrary];
        _scoreRegister = [CSMScoreRegister scoreRegister];
        _imageDictionary = [NSMutableDictionary dictionaryWithCapacity:20];
        _demoWatched = NO;
        
        
        /*
        NSString *reqSysVer = @"7.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            bNeedToScalePhysicsBodies = NO;
        else
            bNeedToScalePhysicsBodies = YES;
         */
        
       
        
    }
    return self;
}


# pragma mark Scene Management

//flipHorizontalWithDuration:(NSTimeInterval)sec
//moveInWithDirection:(SKTransitionDirection)direction duration:(NSTimeInterval)sec
//+ (SKTransition *)pushWithDirection:(SKTransitionDirection)direction duration:(NSTimeInterval)sec

/*
 + (SKTransition *)revealWithDirection:(SKTransitionDirection)direction duration:(NSTimeInterval)sec;
 + (SKTransition *)moveInWithDirection:(SKTransitionDirection)direction duration:(NSTimeInterval)sec;
 + (SKTransition *)pushWithDirection:(SKTransitionDirection)direction duration:(NSTimeInterval)sec;
*/

-(void)switchSceneFrom:(SKScene*)oldScene to:(SKScene*)newScene{
    NSLog(@"GameData switchScene");
    
    NSLog(@"[%@ swiichSceneFrom:%@ to: %@]", self.vc, oldScene, newScene);
    
    [self.vc switchSceneFrom:oldScene to:newScene];
    
    /*
    
    //take screenshot
    UIGraphicsBeginImageContextWithOptions(oldScene.view.bounds.size, NO, oldScene.xScale);
    [oldScene.view drawViewHierarchyInRect:oldScene.view.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
    [oldScene.view addSubview:imageView];
    
    
    SKTransition *trans = [SKTransition crossFadeWithDuration:0.7];
    //SKTransition *trans = [SKTransition doorsOpenHorizontalWithDuration:0.7];
    [oldScene.view presentScene:newScene transition:trans];
    
    
    if([oldScene isKindOfClass:[CSMResponsiveSKScene class]]){
        [(CSMResponsiveSKScene*)oldScene clearReferences];
    }
    else{
        NSLog(@"closing non-CSM scene :%@", oldScene);
    }
    
    */
    
    /*
    SKView* newView = [[SKView alloc]initWithFrame:self.vc.view.frame];
    UIView* oldView = self.vc.view;
    self.vc.view = newView;
    [newView presentScene:newScene];
    
    [oldView removeFromSuperview];
    */
    
    //[self.vc.view transition]
    
    //UIView* v = [[UIView alloc]initWithFrame:self.vc.view.frame];
    
    /*
    
    1 - At the point you want to transition from one scene to the other, take a snapshot of the scene using the following code:
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    Then, add this image as a subview of the SKView of the current scene, and remove the scene.
    
    2 - Initialise the new scene on another view, and transition between the two views using UIView animation.
    
    3 - Remove the first view from it's superview.
    */
    
    
    /*
    SKTransition *trans = [SKTransition crossFadeWithDuration:0.7];
    
    __weak typeof(oldScene) weakOldScene = oldScene;
    [weakOldScene.view presentScene:newScene transition:trans];
     */
}


-(void)openDemoLevelFromScene:(SKScene *)scene{
    
    SKScene* nextScene = [CSMDemoScene sceneWithSize:scene.size gameData:self];
    [self switchSceneFrom:scene to:nextScene];
    
    //SKTransition *trans = [SKTransition crossFadeWithDuration:0.7];
    //[scene.view presentScene:nextScene transition:trans];
}

-(void)openGamePlayLevel:(int)levelNo fromScene:(SKScene *)scene{
    
    if(levelNo == 1 && !self.demoWatched){
        [self openDemoLevelFromScene:scene];
    }
    else{
    
        CSMLevel* level = [self.levelsLibrary level:levelNo];
        if(level){
            SKScene * nextScene = [CSMGamePlayScene sceneWithSize:scene.size level:level gameData:self];
            
            [self switchSceneFrom:scene to:nextScene];
            
            
            //SKTransition *trans = [SKTransition crossFadeWithDuration:0.7];
            //[scene.view presentScene:nextScene transition:trans];
           
        }
        else{
            [self openMenuFromScene:scene];
        }
    }
}


-(void)openBuildLevel:(int)levelNo fromScene:(SKScene *)scene{
#ifdef compileWithBuildModule
    
    CSMLevel* level = [self.levelsLibrary level:levelNo];
    if(level){
        SKScene * nextScene = [CSMLevelBuildScene sceneWithSize:scene.size level:level gameData:self];
        [self switchSceneFrom:scene to:nextScene];
        //SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
        //[scene.view presentScene:nextScene transition:doors];
    }
    else{
        [self openMenuFromScene:scene];
    }
#endif
    
}

-(void)openBuildLevelFromScene:(SKScene *)scene{
#ifdef compileWithBuildModule
    int newLevelNo = [self.levelsLibrary newLevelNumber];
    SKScene * nextScene = [CSMLevelBuildScene sceneWithSize:scene.size level:[CSMLevel emptyLevel:newLevelNo] gameData:self];
    [self switchSceneFrom:scene to:nextScene];
    //SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    //[scene.view presentScene:nextScene transition:doors];
#endif
}


-(void)openMenuFromScene:(SKScene *)scene{
    CSMMenuScene* nextScene;
    if([scene isMemberOfClass:[CSMGamePlayScene class]]){
        nextScene = [CSMMenuScene sceneWithSize:scene.size gameData:self levels:YES];
    }
    else{
        nextScene = [CSMMenuScene sceneWithSize:scene.size gameData:self];
    }
    [self switchSceneFrom:scene to:nextScene];
    //SKTransition *trans = [SKTransition crossFadeWithDuration:0.7];
    //[scene.view presentScene:nextScene transition:trans];
}

# pragma mark level editing

-(void)saveLevel:(CSMLevel *)level{
    [self.levelsLibrary saveLevel:level];
}

-(void)addLevel:(CSMLevel *)level{
    [self.levelsLibrary addLevel:level];
}

-(void)deleteLevel:(int)levelNo{
    [self.levelsLibrary deleteLevel:levelNo];
}

-(CSMLevel*)getDemoLevel{
    return [self.levelsLibrary level:1];
}

-(NSUInteger)numberOfLevels{
    return[self.levelsLibrary.seedDictionary count];
}
/*
-(void)insertLevel:(CSMLevel *)level{
    [self.levelsLibrary addLevel:level];
}
 */

/*-
-(void)addLevel;
-(void)deleteLevel:(int)levelNo;
*/

# pragma mark Score Data

-(void)completedlevel:(int)levelNo withScore:(int)score{
    //NSLog(@"game data completedlevel:%i withScore:%i", levelNo, score);
    int s = [self.scoreRegister scoreForLevel:levelNo];
    //NSLog(@"stored scorre for level %i is %i", levelNo, s);
    if (score > s){
       // NSLog(@" gamedata storing score %i for level %i", score, levelNo);
        [self.scoreRegister setScore:score forLevel:levelNo];
        #ifdef compileWithGameKit
        [self.vc reportScore:[self totalScore]];
#endif
    }
}

-(int)scoreForLevel:(int)levelNo{
    return [self.scoreRegister scoreForLevel:levelNo];
}

-(int)totalScore{
    return [self.scoreRegister totalScore];
}

-(BOOL)gameComplete{
    BOOL complete = NO;
    if([self.scoreRegister allLevelsScoredUpTo:(int)[self.levelsLibrary.seedDictionary count]]){
        complete = YES;
    }
    return complete;
}

-(BOOL)gameCenterEnabled{
    return self.vc.gameCenterEnabled;
}

-(void)showLeaderboard{
    #ifdef compileWithGameKit
    [self.vc showLeaderboard];
#endif
}

-(BOOL)toggleSound{
    return [self.vc toggleSound];
}

-(BOOL)musicPlaying{
    return [self.vc musicPlaying];
}

-(SKTexture*)getTextureNamed:(NSString *)imageName{
    SKTexture* texture = [self.imageDictionary valueForKey:imageName];
    if(!texture){
        texture = [SKTexture textureWithImageNamed:imageName];
        if(texture){
            [self.imageDictionary setObject:texture forKey:imageName];
        }
    }
    return texture;
}

-(void)pauseGame{
    [self.vc pauseGame];
}

@end
