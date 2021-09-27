//
//  ColorfulCube.h
//  Cube
//  Created by shizhi on 21-9-20.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ColorfulCube : NSObject 

@property (nonatomic, strong) GLKBaseEffect *effect;

- (void)draw;

@end
