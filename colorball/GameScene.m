//
//  GameScene.m
//  colorball
//
//  Created by Natalia Souza on 5/11/15.
//  Copyright (c) 2015 Natalia Souza. All rights reserved.
//

#import "GameScene.h"
#import "Blocos.h"

#define colunas 6
#define linhas 8
#define minimo_blocos  3
#define tempoJogo 05.0f


typedef enum {
    
    STARTING,
    STOPPED,
    PLAYING
    
} GameState;




@interface GameScene(){
    NSArray *_cores;
    SKLabelNode *_Labelscore;
    NSUInteger _score;
    
    SKLabelNode *_LabelTempo;
    
    GameState _gameState;
    CFTimeInterval _startTime;
    
}

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size{
    
    if (self = [super initWithSize:size]){
        
        //background e gravidade
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.4 blue:0.3 alpha:1.0];
        
        self.physicsWorld.gravity = CGVectorMake(0, -8.f);
        
    
        //criando o "chao"
        SKSpriteNode *chao = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(640, 80)];
        
        chao.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:chao.size];
        
        chao.physicsBody.dynamic = false;
        
        chao.position = CGPointMake(160, 20);
        
        //add chao a cena
        [self addChild:chao];
        
        
        for (int linha= 0; linha < linhas; linha++ ){
            for (int coluna= 0; coluna < colunas; coluna++ ){
                
                CGFloat dimension = self.scene.size.width / colunas;
                CGFloat xposicao = (dimension / 2) + coluna * dimension;
                CGFloat yposicao = 640 + ( (dimension/2) - linha * dimension );
                
                NSArray *cores = @[[UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor yellowColor], [UIColor blackColor]];
                
                NSUInteger colorIndex = arc4random() % cores.count;
                
                Blocos *node = [[Blocos alloc] initWithLinha:linha
                                                       andColuna:coluna
                                                       withColor:[cores objectAtIndex:colorIndex]
                                                         andSize:CGSizeMake(dimension, dimension)];
                
                // add o bloco na cena
                [self.scene addChild:node];
                
                
                //label da pontuacao
                _Labelscore = [SKLabelNode labelNodeWithFontNamed: @"Arial"];
                _LabelTempo.text = @"";
                _Labelscore.fontColor = [UIColor whiteColor ];
                _Labelscore.fontSize = 14.0f;
                _Labelscore.position = CGPointMake(30, 10);
                
                [self.scene addChild:_Labelscore];
                
                
                //label de tempo
                _LabelTempo = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
                _LabelTempo.text = @"";
                _LabelTempo.fontColor = [UIColor whiteColor];
                _LabelTempo.fontSize = 14.0f;
                _LabelTempo.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
                _LabelTempo.position = CGPointMake(310, 20);

                
                //add a cena
                [self.scene addChild:_LabelTempo];
                
                
            }
        }
        
    }
    
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // get a touch object
    UITouch *touch = [touches anyObject];
    
    // and the touch's location
    CGPoint location = [touch locationInNode:self];
    
    // see which node was touched based on the location of the touch
    SKNode *node = [self nodeAtPoint:location];
    
    // if it was a block being touched
    if([node isKindOfClass:[Blocos class]]) {
        if (_gameState == STOPPED) {
            _gameState = STARTING;
        }
        // cast it so we can access the attributes
        Blocos *clickedBlock = (Blocos*)node;
        
        
        // recursively retrieve all valid blocks around it
        NSMutableArray *objectsToRemove = [self nodesToRemove:[NSMutableArray array] aroundNode:clickedBlock];

        // ensure that there are enough connected blocks selected
        if(objectsToRemove.count >= minimo_blocos) {
            
          
            
            // iterate through everything we need to delete
            for(Blocos *deleteNode in objectsToRemove) {
                
                // remove it from the scene
                [deleteNode removeFromParent];
                
                // and decrement the 'row' variable for all blocks that sit above the one being removed
                for(Blocos *testNode in [self getAllBlocks]) {
                    if(deleteNode.coluna == testNode.coluna && (deleteNode.linha < testNode.linha)) {
                        --testNode.linha;
                        
                    }
                }
                
                ++_score;
                
                _Labelscore.text = [NSString stringWithFormat:@ "Score: %d" , _score];
            }

            
            // make sure our grid stays full even when blocks are removed by...
            
            // initialize an array of 'maximum indexes for each column'
            NSUInteger totallinhas[colunas];
            for(int i=0; i<colunas; i++) totallinhas[i] = 0;
            
            // walk through our blocks
            for(Blocos *node in [self getAllBlocks]) {
                
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
                    
                    
                    Blocos *node = [[Blocos alloc] initWithLinha:totallinhas[coluna] + 1
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
        if([childNode isKindOfClass:[Blocos class]]) {
            
            // add it to our tracking array
            [blocks addObject:childNode];
        }
    }
    
    return [NSArray arrayWithArray:blocks];
}

- (BOOL) inRange:(Blocos*)testNode of:(Blocos*)baseNode
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

- (NSMutableArray*) nodesToRemove:(NSMutableArray*)removedNodes aroundNode:(Blocos*)baseNode
{
    // make sure our base node is being removed
    [removedNodes addObject:baseNode];
    
    // go through all the blocks on the screen
    for(Blocos *childNode in [self getAllBlocks]) {
        
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

-(void)gameEnded{
    
    // indicate our game state as stopped
    _gameState = STOPPED;
    
    // create a message to let the user know their score
    NSString *message = [NSString stringWithFormat:@"You scored %d this time", _score];
    
    // show the message to the user
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Game over!"
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil];
    [av show];
    
    // reset the score tracker for the next game
    _score = 0;

    
}


-(void)update:(CFTimeInterval)currentTime {
    
    
    if (_gameState == STARTING) {
        _startTime = currentTime;
        _gameState = PLAYING;
        
    }
    
    if (_gameState == PLAYING) {
        int temporestante = ceil(tempoJogo + (_startTime - currentTime));
        _LabelTempo.text = [NSString stringWithFormat:@"Tempo restante: %d", temporestante];
        
        if (temporestante == 0) {
            [self gameEnded];
        }
    }
    // go through all the blocks in our scene
    for(SKNode *node in self.scene.children) {
        
        // and normalize the position so it falls exactly on a pixel
        node.position = CGPointMake(roundf(node.position.x), roundf(node.position.y));
    }
}

@end
