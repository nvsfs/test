//
//  ballNode.h
//  colorball
//
//  Created by Natalia Souza on 5/12/15.
//  Copyright (c) 2015 Natalia Souza. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ballNode : SKSpriteNode

@property (nonatomic, assign) NSUInteger linha;
@property (nonatomic, assign) NSUInteger coluna;

-(ballNode*) initWithLinha: (NSUInteger)linha
                 andColuna: (NSUInteger)coluna
                 withColor:(UIColor*)color
                   andSize: (CGSize)size;
@end
