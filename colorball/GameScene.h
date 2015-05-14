//
//  GameScene.h
//  colorball
//

//  Copyright (c) 2015 Natalia Souza. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GameScene : SKScene

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) SKAction *deleteSound;
@property (strong, nonatomic) SKAction *owSound;

@end
