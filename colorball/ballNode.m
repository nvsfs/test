//
//  ballNode.m
//  colorball
//
//  Created by Natalia Souza on 5/12/15.
//  Copyright (c) 2015 Natalia Souza. All rights reserved.
//

#import "ballNode.h"

@implementation ballNode

-(ballNode*) initWithLinha: (NSUInteger)linha
                 andColuna: (NSUInteger)coluna
                 withColor:(UIColor*)color
                   andSize: (CGSize)size;
{
    self = [super initWithColor:color size:size];
    if (self) {
    
        _linha = linha;
        _coluna = coluna;
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(size.width -2, size.height-2)];
        self.physicsBody.restitution = 0.2f;
        self.physicsBody.allowsRotation = false;
        
        
        CGFloat xposicao = (size.width / 2) + _coluna * size.width;
        CGFloat yposicao = 640 + ( (size.height /2) + _linha * size.height );
        
        self.position = CGPointMake(xposicao, yposicao);
    
    }
    
    return self;
}

@end
