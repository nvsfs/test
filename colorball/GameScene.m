//
//  GameScene.m
//  colorball
//
//  Created by Natalia Souza on 5/11/15.
//  Copyright (c) 2015 Natalia Souza. All rights reserved.
//

#import "GameScene.h"
#define colunas 6
#define linhas 8

@implementation GameScene


-(void)Blockfall: (CGSize)size withPosition:(CGPoint)position andColor :(UIColor*)cor{
    
    
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithColor:cor size:size];
    
    ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(size.width-2, size.height-2)];
    
    ball.position = position;
    
    ball.physicsBody.restitution = 0.f;
    
    ball.physicsBody.allowsRotation = false;
    
    [self addChild:ball];
    

}

-(id)initWithSize:(CGSize)size{

    if (self = [super initWithSize:size]){
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.4 blue:0.3 alpha:1.0];
        
        self.physicsWorld.gravity = CGVectorMake(0, -8.f);
        
//    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"Image.png"];
//    
//    ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ball.size];
//    
//    ball.position = CGPointMake(160, 480);
//        
//    ball.physicsBody.restitution = 0.f;
//        
//    [self addChild:ball];
        
    SKSpriteNode *chao = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(640, 80)];
        
        chao.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:chao.size];
        
        chao.physicsBody.dynamic = false;
        
        chao.position = CGPointMake(160, 20);
        
        chao.physicsBody.mass = -1;
        
        [self addChild:chao];
        
        
        for (int linha= 0; linha < linhas; linha++ ){
                for (int coluna= 0; coluna < colunas; coluna++ ){
                    
                    CGFloat dimension = self.scene.size.width / colunas;
            CGFloat xposicao = (dimension / 2) + coluna * dimension;
            CGFloat yposicao = 640 + ( (dimension/2) - linha * dimension );
                    
            NSArray *cores = @[[UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor yellowColor], [UIColor blackColor]];
            
            NSUInteger colorIndex = arc4random() % cores.count;
            
            [self Blockfall:CGSizeMake(dimension, dimension)
               withPosition:CGPointMake(xposicao, yposicao)
                   andColor:[cores objectAtIndex:colorIndex]];
            }
        }
    
    }

    return self;

}
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
//
//    self.physicsWorld.gravity = CGVectorMake(0, 1.0f);
//    
//    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithColor: [UIColor redColor] size:CGSizeMake(100, 100)];
//    
//    ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ball.size];
//    
//    ball.position = CGPointMake(160, 480);
//    
//    [self addChild:ball];


}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
