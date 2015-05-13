//
//  GameScene.m
//  colorball
//
//  Created by Natalia Souza on 5/11/15.
//  Copyright (c) 2015 Natalia Souza. All rights reserved.
//

#import "GameScene.h"
#import "ballNode.h"

#define colunas 6
#define linhas 8
#define minimo_blocos  3


@interface GameScene(){
    NSArray *_cores;
}
@end

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
                
                ballNode *node = [[ballNode alloc] initWithLinha:linha
                                                       andColuna:coluna
                                                       withColor:[cores objectAtIndex:colorIndex]
                                                         andSize:CGSizeMake(dimension, dimension)];
                
                // add the block to our scene
                [self.scene addChild:node];
                
                            }
        }
        
    }
    
    return self;
    
}
-(void)didMoveToView:(SKView *)view {
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // get a touch object
    UITouch *touch = [touches anyObject];
    
    // and the touch's location
    CGPoint location = [touch locationInNode:self];
    
    // see which node was touched based on the location of the touch
    SKNode *node = [self nodeAtPoint:location];
    
    // if it was a block being touched
    if([node isKindOfClass:[ballNode class]]) {
        
        // cast it so we can access the attributes
        ballNode *clickedBlock = (ballNode*)node;
        
        
        // recursively retrieve all valid blocks around it
        NSMutableArray *objectsToRemove = [self nodesToRemove:[NSMutableArray array] aroundNode:clickedBlock];

        // ensure that there are enough connected blocks selected
        if(objectsToRemove.count >= minimo_blocos) {
            
            // iterate through everything we need to delete
            for(ballNode *deleteNode in objectsToRemove) {
                
                // remove it from the scene
                [deleteNode removeFromParent];
                
                // and decrement the 'row' variable for all blocks that sit above the one being removed
                for(ballNode *testNode in [self getAllBlocks]) {
                    if(deleteNode.coluna == testNode.coluna && (deleteNode.linha < testNode.linha)) {
                        --testNode.linha;
                    }
                }
            }

            
            // make sure our grid stays full even when blocks are removed by...
            
            // initialize an array of 'maximum indexes for each column'
            NSUInteger totallinhas[colunas];
            for(int i=0; i<colunas; i++) totallinhas[i] = 0;
            
            // walk through our blocks
            for(ballNode *node in [self getAllBlocks]) {
                
                // get the index of the highest row in each column
                if(node.linha > totallinhas[node.coluna]) {
                    totallinhas[node.coluna] = node.linha;
                }
            }
            
            // walk through each column
            for (int coluna= 0; coluna < colunas; coluna++ ){
                while (totallinhas [coluna] < linhas -1){
                    
                    CGFloat dimension = self.scene.size.width / colunas;
            
                    
                     _cores = @[[UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor yellowColor], [UIColor blackColor]];
                    
                    NSUInteger colorIndex = arc4random() % _cores.count;
                    // add the block to our scene
                    
                    
                    ballNode *node = [[ballNode alloc] initWithLinha:totallinhas[coluna] + 1
                                                           andColuna:coluna
                                                           withColor:[_cores objectAtIndex:colorIndex]
                                                             andSize:CGSizeMake(dimension, dimension)];
                    [self.scene addChild:node];
                    
                    // increment the number of rows in this particular column
                    ++totallinhas[coluna];
                    
                }
                
            }
//
        }
//        
  }
    
}

- (NSArray*) getAllBlocks
{
    NSMutableArray *blocks = [NSMutableArray array];
    
    // iterate through all nodes
    for(SKNode *childNode in self.scene.children) {
        
        // see if it's of type 'BlockNode'
        if([childNode isKindOfClass:[ballNode class]]) {
            
            // add it to our tracking array
            [blocks addObject:childNode];
        }
    }
    
    return [NSArray arrayWithArray:blocks];
}

- (BOOL) inRange:(ballNode*)testNode of:(ballNode*)baseNode
{
    // mesma linha ou coluna
    BOOL isRow = (baseNode.linha == testNode.linha);
    BOOL isCol = (baseNode.coluna == testNode.coluna);
    
    // if the nodes are one row/column apart
    BOOL oneOffCol = (baseNode.coluna+1 == testNode.coluna || baseNode.coluna-1 == testNode.coluna);
    BOOL oneOffRow = (baseNode.linha+1 == testNode.linha || baseNode.linha-1 == testNode.linha);
    
    // if the nodes are the same color
    BOOL sameColor = [baseNode.color isEqual:testNode.color];
    
    // returns true when they are next to each other AND the same color
    return ( (isRow && oneOffCol) || (isCol && oneOffRow) ) && sameColor;
}

- (NSMutableArray*) nodesToRemove:(NSMutableArray*)removedNodes aroundNode:(ballNode*)baseNode
{
    // make sure our base node is being removed
    [removedNodes addObject:baseNode];
    
    // go through all the blocks on the screen
    for(ballNode *childNode in [self getAllBlocks]) {
        
        // if the node being tested is on one of the four sides off our base node
        // and it is the same color, it is in range and valid to be removed
        if([self inRange:childNode of:baseNode]) {
            
            // if we have not already checked if this block is being removed
            if(![removedNodes containsObject:childNode]) {
                
                // test the blocks around this one for possible removal
                removedNodes = [self nodesToRemove:removedNodes aroundNode:childNode];
            }
            
        }
    }
    
    return removedNodes;
}



-(void)update:(CFTimeInterval)currentTime {
    // go through all the blocks in our scene
    for(SKNode *node in self.scene.children) {
        
        // and normalize the position so it falls exactly on a pixel
        node.position = CGPointMake(roundf(node.position.x), roundf(node.position.y));
    }
}

@end
