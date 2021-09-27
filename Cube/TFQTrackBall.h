//
//  TFQTrackBall.h
//  MagicCube
//
//  Created by shizhi on 21-9-20.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>
@interface TFQTrackBall : NSObject
-(void)touchDownAtX:(GLfloat)x AtY:(GLfloat)y;

-(GLKMatrix4)touchMoveAtX:(GLfloat)x AtY:(GLfloat)y;
-(void)touchUpAtX:(GLfloat)x AtY:(GLfloat)y;

@end
