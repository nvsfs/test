//
//  GameScene.m
//  colorball
//
//  Created by Natalia Souza on 5/11/15.
//  Copyright (c) 2015 Natalia Souza. All rights reserved.
//

#import "GameScene.h"
#import "GameMenuScene.h"
#import "Blocos.h"

#define colunas 6
#define linhas 8
#define minimo_blocos 2
#define tempoJogo 40.0f


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
        self.backgroundColor = [SKColor colorWithRed:0.31 green:0.35 blue:0.39 alpha:1.0];
        
        self.physicsWorld.gravity = CGVectorMake(0, -8.f);
        
    
        //criando o "chao"
        SKSpriteNode *chao = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.97 green:0.38 blue:0.38 alpha:1.0] size:CGSizeMake(640, 80)];
        
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
                
                NSArray *cores = @[[SKColor colorWithRed:0.30 green:0.74 blue:0.83 alpha:1.0],
                                   [SKColor colorWithRed:1.00 green:0.46 blue:0.58 alpha:1.0],
                                   [SKColor colorWithRed:0.99 green:0.75 blue:0.52 alpha:1.0],
                                   [SKColor colorWithRed:0.12 green:0.44 blue:0.64 alpha:1.0],
                                   [SKColor colorWithRed:0.54 green:0.71 blue:0.89 alpha:1.0]];
                
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
                _Labelscore.fontSize = 20.0f;
                _Labelscore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;

                _Labelscore.position = CGPointMake(30, 20);
                
                [self.scene addChild:_Labelscore];
                
                
                //label de tempo
                _LabelTempo = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
                _LabelTempo.text = @"";
                _LabelTempo.fontColor = [UIColor whiteColor];
                _LabelTempo.fontSize = 20.0f;
                _LabelTempo.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
                _LabelTempo.position = CGPointMake(350, 20);

                
                //add a cena
                [self.scene addChild:_LabelTempo];
                
                
            }
        }
        
    }
    
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    
    // se um bloco foi tocado
    if([node isKindOfClass:[Blocos class]]) {
        if (_gameState == STOPPED) {
            _gameState = STARTING;
        }
        Blocos *clickedBlock = (Blocos*)node;
        
        
        // Procurar os blocos ao validos (mesmo )
        NSMutableArray *objectsToRemove = [self nodesToRemove:[NSMutableArray array] aroundNode:clickedBlock];

        // verifica o se os blocos conectados podem ser destruídos
        if(objectsToRemove.count >= minimo_blocos) {
            
          
            
            // deleta os blocos
            for(Blocos *deleteNode in objectsToRemove) {
                [self runAction:[SKAction playSoundFileNamed:@"Drag.caf" waitForCompletion:NO]];

                // remover da cena
                [deleteNode removeFromParent];
                
                                
                // desce os blocos acima do deletado
                for(Blocos *testNode in [self getAllBlocks]) {
                    if(deleteNode.coluna == testNode.coluna && (deleteNode.linha < testNode.linha)) {
                        --testNode.linha;
                        
                    }
                }
                
                //sempre q é deletado um bloco, aumenta a pontuacao
                ++_score;
                
                _Labelscore.text = [NSString stringWithFormat:@ "Score: %d" , _score];
            }

            
            // prenche a coluna qnd blocos sao destruídos
            
            // linhas máximas numa coluna
            NSUInteger totallinhas[colunas];
            for(int i=0; i<colunas; i++) totallinhas[i] = 0;
            
            for(Blocos *node in [self getAllBlocks]) {
                
                // get the index of the highest row in each column
                if(node.linha > totallinhas[node.coluna]) {
                    totallinhas[node.coluna] = node.linha;
                }
            }
            
            // passa por cada coluna
            for (int coluna= 0; coluna < colunas; coluna++ ){
                while (totallinhas [coluna] < linhas -1){
                    
                    CGFloat dimension = self.scene.size.width / colunas;
            
                    
                    _cores = @[[SKColor colorWithRed:0.30 green:0.74 blue:0.83 alpha:1.0], //rosa
                                                [SKColor colorWithRed:1.00 green:0.46 blue:0.58 alpha:1.0], //magenta
                                                [SKColor colorWithRed:0.99 green:0.75 blue:0.52 alpha:1.0], //amarelinho
                                                [SKColor colorWithRed:0.12 green:0.44 blue:0.64 alpha:1.0], //azul
                                                [SKColor colorWithRed:0.54 green:0.71 blue:0.89 alpha:1.0]]; //cinza

                    
                    NSUInteger colorIndex = arc4random() % _cores.count;
                    // add os blocos na cena
                    
                    
                    Blocos *node = [[Blocos alloc] initWithLinha:totallinhas[coluna] + 1
                                                           andColuna:coluna
                                                           withColor:[_cores objectAtIndex:colorIndex]
                                                             andSize:CGSizeMake(dimension, dimension)];
                    [self.scene addChild:node];
                    
                    // incrementa o numero de linhas na coluna
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
    
    // passa por todos os nodes
    for(SKNode *childNode in self.scene.children) {
        
        // verificar se é do tipo Bloco
        if([childNode isKindOfClass:[Blocos class]]) {
            
            // add no array
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
    
    // se os blocos estao separados por uma coluna/linha
    BOOL oneOffCol = (baseNode.coluna+1 == testNode.coluna || baseNode.coluna-1 == testNode.coluna);
    BOOL oneOffRow = (baseNode.linha+1 == testNode.linha || baseNode.linha-1 == testNode.linha);
    
    // se eles sao da mesma cor
    BOOL sameColor = [baseNode.color isEqual:testNode.color];
    
    // se eles estao perto E  sao da mesma cor = true
    return ( (isRow && oneOffCol) || (isCol && oneOffRow) ) && sameColor;
}

- (NSMutableArray*) nodesToRemove:(NSMutableArray*)removedNodes aroundNode:(Blocos*)baseNode
{
    // remover o bloco base
    [removedNodes addObject:baseNode];
    
    // passar por todos os blocos
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
    
    //Jogo parado
    _gameState = STOPPED;
    
    NSString *message = [NSString stringWithFormat:@"Aeee! Você fez %d pontos", _score];
    
    // mensagem de fim de jogo
//    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Boom!"
//                                                 message:message
//                                                delegate:nil
//                                       cancelButtonTitle:@"Ok"
//                                       otherButtonTitles:nil];
//    [av show];
    
    
    UIImage *image = [UIImage imageNamed:@"alerta.png"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"FIm do Jogo!" message: message delegate:nil cancelButtonTitle:@"Reiniciar" otherButtonTitles:nil, nil];
    
    UIImageView* ivMyImageView = [[UIImageView alloc] initWithImage:image];
    [ivMyImageView setImage:image];
    
    [alert setValue: ivMyImageView forKey:@"accessoryView"];
    [alert show];
    // reset da pontuacao
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
    // passa por todos os blocos da cena
    for(SKNode *node in self.scene.children) {
        
        //posiciona os blocos corretamente
        node.position = CGPointMake(roundf(node.position.x), roundf(node.position.y));
    }
}

@end
