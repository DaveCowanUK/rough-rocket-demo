//
//  CSMTemplateScene.m
//  Cassam2
//
//  Created by The Cowans on 20/03/2014.
//  Copyright (c) 2014 RNC. All rights reserved.
//

#import "CSMTemplateScene.h"
#import "GameConstants.h"
#import "Tools.h"
#import "CSMMenuScene.h"
#import "ButtonSprite.h"

@interface CSMTemplateScene ()
@property BOOL contentCreated;
@end

@implementation CSMTemplateScene{
    Tools* tools;
}

-(id)initWithSize:(CGSize)size
{
    
    if (self = [super initWithSize:size])
    {
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        //self.physicsWorld.contactDelegate = self;
        self.minScale = 0.2;
        
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    //NSLog(@"template DidMove ToView, contentCreated=%i", self.contentCreated);
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
        //NSLog(@"contentCreated=%i", self.contentCreated);
    }
}

- (void)createSceneContents
{
    //NSLog(@"template CreateSceneContents");
    self.anchorPoint = CGPointMake (0.5,0.5);
    
    tools = [[Tools alloc]init];
    
    //gameNode for holding game
    self.gameNode = [SKNode node];// initWithColor:[SKColor grayColor] size:CGSizeMake(100,100)];
    self.gameNode.name = @"gameNode";
    self.gameNode.physicsBody.dynamic = NO;
    self.gameNode.physicsBody = nil;
    [self addChild:self.gameNode];
    
    
    //Sprite holder for scrolling view
    self.spriteHolder = [SKNode node];// initWithColor:[SKColor grayColor] size:CGSizeMake(100,100)];
    self.spriteHolder.name = @"spriteHolder";
    self.spriteHolder.physicsBody.dynamic = NO;
    self.spriteHolder.physicsBody = nil;
    [self.gameNode addChild:self.spriteHolder];
    
    self.backgroundColor = [SKColor blackColor];
    //self.scaleMode = SKSceneScaleModeFill; // how does that affect things?
    
    //Area boundary
    self.boundary = CGRectMake(-tools.kFieldSize.width/2, -tools.kFieldSize.height/2, tools.kFieldSize.width, tools.kFieldSize.height);
    
    
    [self addBackground:self.spriteHolder Size: tools.kFieldSize];
    
    SKTexture *backTexture = [SKTexture textureWithImageNamed:@"ArrowLeft.png"];
    self.backControl = [[ButtonSprite alloc]initWithTexture: backTexture scene:self type:kBack];
    self.backControl.position = settingsButtonPos;
    self.backControl.userInteractionEnabled = YES;
    self.backControl.alpha = 1.0;
    self.backControl.zPosition = kIcon1zPos;
    self.backControl.name = @"backControl";
    [self.gameNode addChild:self.backControl];
    
    
}

-(void)addBackground:(SKNode *)node Size:(CGSize)size {
//}
//-(void)comment:(SKNode *)node Size:(CGSize)size{
    //add tiles
    
    [Tools addTilesWithTexture:[SKTexture textureWithImageNamed:@"BackgroundTileCol1.png"]
                            to:node //backgroundNode
                          area:CGRectMake(
                                          -size.width/2, -size.height/2,
                                          size.width, size.height
                                          )
                          zPos:kPaperzPos];
    
    
    
    /*
     //add desk as whole
    SKSpriteNode* desk = [SKSpriteNode spriteNodeWithImageNamed:@"desk.jpg"];
    desk.zPosition = kSurfacezPos;
    desk.name = @"desk";
    [node addChild:desk];
     */
    
    //add desk in parts
    
    SKTexture* deskTexture = [SKTexture textureWithImageNamed:@"desk1.jpg"];
    
    CGFloat heightProportion = size.height / deskTexture.size.height;
    CGFloat topDesk = 1.0 - ( ((deskTexture.size.height - size.height) / 2) / deskTexture.size.height );
    CGFloat rightDesk = 1.0 - ( ((deskTexture.size.width - size.width) / 2) / deskTexture.size.width );
    CGFloat bottomDesk = ((deskTexture.size.height - size.height) / 2) / deskTexture.size.height;
    CGFloat leftDesk = ((deskTexture.size.width - size.width) / 2) / deskTexture.size.width;
    
    SKSpriteNode* deskRightSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture
                                                                          textureWithRect:CGRectMake(rightDesk, bottomDesk, 1.0-rightDesk, heightProportion)
                                                                          inTexture:deskTexture]];
    deskRightSprite.name = @"desk";
    deskRightSprite.position = CGPointMake(size.width/2 + deskRightSprite.size.width/2, 0.0);
    deskRightSprite.zPosition = kDrawing3zPos;
    [node addChild:deskRightSprite];
    
    
    SKSpriteNode* deskLeftSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture
                                                                            textureWithRect:CGRectMake(0.0, bottomDesk, leftDesk, heightProportion)
                                                                            inTexture:deskTexture]];
    deskLeftSprite.name = @"desk";
    deskLeftSprite.position = CGPointMake(-size.width/2 - deskLeftSprite.size.width/2, 0.0);
    deskLeftSprite.zPosition = kDrawing3zPos;
    [node addChild:deskLeftSprite];
    
    
    SKSpriteNode* deskBottomSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture
                                                                         textureWithRect:CGRectMake(0.0, 0.0, 1.0, bottomDesk)
                                                                         inTexture:deskTexture]];
    deskBottomSprite.name = @"desk";
    deskBottomSprite.position = CGPointMake(0.0, - size.height/2 - deskBottomSprite.size.height/2 );
    deskBottomSprite.zPosition = kDrawing3zPos;
    [node addChild:deskBottomSprite];
    
    
    SKSpriteNode* deskTopSprite = [[SKSpriteNode alloc] initWithTexture:[SKTexture
                                                                         textureWithRect:CGRectMake(0.0, topDesk, 1.0, 1.0 - topDesk)
                                                                         inTexture:deskTexture]];
    deskTopSprite.name = @"desk";
    deskTopSprite.position = CGPointMake(
                                         0.0,
                                         size.height/2 + deskTopSprite.size.height/2
                                         );
    deskTopSprite.zPosition = kDrawing3zPos;
    [node addChild:deskTopSprite];
    
    //calculate minScale
    CGFloat minMargin = (deskTexture.size.width - size.width) < (deskTexture.size.height - size.height) ?
      (deskTexture.size.width - size.width) : (deskTexture.size.height - size.height) ;
    //NSLog(@"minMargin:%f", minMargin);
    minMargin /= 2;
    
    self.minScale = (self.frame.size.width / (size.width + minMargin) ) >
      (self.frame.size.height / (size.height + minMargin) ) ?
        (self.frame.size.width / (size.width + minMargin) ) :
        (self.frame.size.height / (size.height + minMargin) ) ;
    

  
    
    
}

-(void)openMenu{
    NSLog(@"CSMTemplateScene openMenu called but depreciated");
    
    SKScene *menuScene  = [[CSMMenuScene alloc] initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:menuScene transition:doors];

}

-(void)openMenuWithLocation:(CSMMenuPos)pos{
    NSLog(@"CSMTemplateScene openMenuWithLocation called but but depreciated and out of use");
    /*
    SKScene *menuScene  = [[CSMMenuScene alloc] initWithSize:self.size pos:pos];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:menuScene transition:doors];
    */
}

-(void)buttonReleased:(ButtonType)button{
    switch (button) {
        case(kBack):
            [self openMenu];
            break;
        default:
            NSLog(@"unrecognised button released");
            break;
    }
}

-(void)spriteTouched:(SKSpriteNode*)sprite{}

-(SKSpriteNode*)mark:(CGPoint)location{
    SKSpriteNode* marker = [SKSpriteNode spriteNodeWithImageNamed:@"iconNode.png"];
    marker.position = location;
    marker.zPosition = kIcon2zPos;
    [self.spriteHolder addChild:marker];
    return marker;
}

-(void)clearReferences{
    [super clearReferences];
    self.rocket = nil;
    self.spriteHolder = nil;
    self.backControl = nil;
    tools = nil;
}


@end
