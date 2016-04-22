//
//  SpriteViewController.m
//  Cassam2
//
//  Created by The Cowans on 16/12/2013.
//  Copyright (c) 2013 RNC. All rights reserved.
//

#import "SpriteViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "CSMMenuScene.h"
#import "CSMTestScene.h"
#import <sys/utsname.h>


@interface SpriteViewController ()


// This property stores the default leaderboard's identifier.
@property (nonatomic, strong) NSString *leaderboardIdentifier;

@end

@implementation SpriteViewController{
    AVQueuePlayer* musicPlayer;
    AVAudioPlayer* audioPlayer;
    int songIndex;
    NSArray* songList;

    BOOL bDropFrameRate;
    BOOL bMusicOn;
    
}


- (void)viewWillLayoutSubviews
{
    
    // NSLog(@"viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
    
    bMusicOn = YES;
    

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        //set frmae interval if iPhone4
        bDropFrameRate = NO;
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString* hardwareString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", hardwareString);
        
        //check for old iPhone
        NSRange range = [hardwareString rangeOfString:@"iPhone"];
        if(range.location != NSNotFound){
            if([hardwareString compare:@"iPhone5,1"] == NSOrderedAscending){//5,1
                bDropFrameRate = YES;
            }
        }
        
        if(bDropFrameRate){
            skView.frameInterval = 2;
            //NSLog(@"frameInterval=2");
        }
        else{
            //NSLog(@"frameInterval=1");
        }
        
        
        skView.showsFPS = NO;
        //skView.frameInterval = 2;
        //skView.showsNodeCount = YES;
       // skView.showsPhysics = NO;
        //skView.showsDrawCount = YES;
        
        // Create and configure the scene.
        //NSLog(@"configuring scene");
       
        SKScene * scene = [CSMMenuScene sceneWithSize:skView.bounds.size viewController:self];
        
        
        // Present the scene.
        [skView presentScene:scene];
        
        [self prepareMusic];
        [self playCurrentSong];
        //[self performSelector:@selector(playMusic) withObject:nil afterDelay:7.0];
    }
}

-(void)switchSceneFrom:(SKScene*)oldScene to:(SKScene*)newScene{
    
    NSLog(@"\n\n [VC switchScemeFrom:%@ \nto:%@", oldScene, newScene);
    
    SKView* newView = [[SKView alloc] initWithFrame:self.view.frame];
    if(bDropFrameRate){
        newView.frameInterval = 2;
    }
    [newView presentScene:newScene];
    
    
    [self performSelector:@selector(switchViewTo:) withObject:newView afterDelay:0.1];
    [self performSelector:@selector(clearScene:) withObject:oldScene afterDelay:(SCENE_CHANGE_DURATION * 2)];
 
}

- (void)switchViewTo:(UIView*)newView {
    //NSLog(@"\n\n[VC switchViewTo:%@", newView);
    [UIView transitionFromView:self.view toView:newView duration:SCENE_CHANGE_DURATION options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished){
                        self.view = newView;
                    }];
}

-(void)clearScene:(SKScene*)oldScene{
    
    if([oldScene isKindOfClass:[CSMResponsiveSKScene class]]){
        //NSLog(@"\n\nclearing...");
        [(CSMResponsiveSKScene*)oldScene clearReferences];
    }
}



- (void)replaceViewUsing:(SKScene*)newScene{
    
    //NSLog(@"\n\nviewController replaceViewUsing..");
    
    
    SKView* newView = [[SKView alloc] initWithFrame:self.view.frame];
    UIView* oldView = self.view;
    
    
    
    self.view = newView;
    [newView presentScene:newScene];
    
    [oldView removeFromSuperview];
    
    
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        //set frmae interval if iPhone4
        bDropFrameRate = NO;
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString* hardwareString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", hardwareString);
        
        //check for old iPhone
        NSRange range = [hardwareString rangeOfString:@"iPhone"];
        if(range.location != NSNotFound){
            if([hardwareString compare:@"iPhone5,1"] == NSOrderedAscending){//5,1
                bDropFrameRate = YES;
            }
        }
        
        if(bDropFrameRate){
            skView.frameInterval = 2;
            //NSLog(@"frameInterval=2");
        }
        else{
            //NSLog(@"frameInterval=1");
        }
        
        
        skView.showsFPS = NO;
        //skView.frameInterval = 2;
        //skView.showsNodeCount = YES;
        // skView.showsPhysics = NO;
        //skView.showsDrawCount = YES;
        
        // Create and configure the scene.
        //NSLog(@"configuring scene");
        
        SKScene * scene = [CSMMenuScene sceneWithSize:skView.bounds.size viewController:self];
        
        
        // Present the scene.
        [skView presentScene:scene];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _gameCenterEnabled = NO;
    _leaderboardIdentifier = @"";
    #ifdef compileWithGameKit
    [self authenticateLocalPlayer];
#endif
}



-(void)authenticateLocalPlayer{
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                //show gameCenter control if menu scene is in use
                if([self.view isKindOfClass:[SKView class]]){
                    SKView* v = (SKView*)self.view;
                    if([v.scene isKindOfClass:[CSMMenuScene class]]){
                        CSMMenuScene* ms = (CSMMenuScene*)v.scene;
                        [ms showGameCenterControl];
                    }
                }
                
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                //_gameCenterEnabled = NO;
            }
        }
    };
}

-(void)reportScore:(int)newScore{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
    score.value = newScore;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)showLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = _leaderboardIdentifier;
    
    
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)playCurrentSong
{
    if(bMusicOn){
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:[songList objectAtIndex:songIndex] ofType:nil]] error:&error];
        if(error !=nil)
        {
            NSLog(@"%@",error);
            //Also possibly increment sound index and move on to next song
        }
        else
        {
            //self.lblCurrentSongName.text = [songList objectAtIndex:currentSoundsIndex];
            [audioPlayer setDelegate:self];
            [audioPlayer prepareToPlay]; //This is not always needed, but good to include
            [audioPlayer play];
        }
    }
}

-(void)prepareMusic{
    
    bMusicOn = YES;
    
    songList = @[
                 @"Secrets.mp3",
                 @"MyCity.mp3",
                 @"PianoGlow.mp3"
                 ];
    /*
    songList = @[
                 @"glassHigh.wav",
                 @"glassMedium.wav",
                 @"glassLow.wav",
                 @"splashDrop.wav",
                 @"splashMedium.wav",
                 @"splashWet.wav"
                 ];
     */
    
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //NSLog(@"audioPayerDidFinish...");
    //Increment index but don't go out of bounds
    
    songIndex = ++songIndex % [songList count];
    
    //NSLog(@"songIndex:%i", songIndex);
    //[self playCurrentSong];
    
    [self performSelector:@selector(playCurrentSong) withObject:nil afterDelay:4.0];
}

-(BOOL)toggleSound{
    if(bMusicOn){
        [audioPlayer stop];
        bMusicOn = NO;
    }
    else{
        [audioPlayer play];
        bMusicOn = YES;
    }
    return bMusicOn;
}

-(BOOL)musicPlaying{
    return bMusicOn;
}

-(void)pauseGame{
    
}



@end
