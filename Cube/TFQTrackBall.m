//
//  TFQTrackBall.m
//  MagicCube
//
//  Created by shizhi on 21-9-20.
//

#import "TFQTrackBall.h"

#define square(X) (X)*(X)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


typedef  struct {
    GLfloat radius;
    GLKVector3 origin;
} TrackBall;
@interface TFQTrackBall (){
    TrackBall _ball;
    GLKVector3 _touchPoint;
    GLKMatrix4 _oldMatria4;
    bool isMoved;
}

@end
@implementation TFQTrackBall
- (id)init
{
    self = [super init];
    if (self) {
        _ball.radius=170;
        _ball.origin=GLKVector3Make(0, 0, 0);
        _oldMatria4=GLKMatrix4Identity;
    }
    return self;
}

-(void)touchDownAtX:(GLfloat)x AtY:(GLfloat)y{
   _touchPoint= [self touchPointVector3FromVector2:GLKVector2Make(x-kScreenWidth*0.5, y-kScreenHeight*0.5)];
}

-(GLKMatrix4)touchMoveAtX:(GLfloat)x AtY:(GLfloat)y{
    isMoved=YES;
    GLKVector3 movePoint= [self touchPointVector3FromVector2:GLKVector2Make(x-kScreenWidth*0.5, y-kScreenHeight*0.5)];
    
    return GLKMatrix4Multiply(GLKMatrix4RotateWithVector3(GLKMatrix4Identity,
                                       acosf(GLKVector3DotProduct(movePoint,_touchPoint)/(GLKVector3Length(movePoint)*GLKVector3Length(_touchPoint))),
                                        GLKVector3CrossProduct( _touchPoint,movePoint))
                              ,_oldMatria4);
}
-(void)touchUpAtX:(GLfloat)x AtY:(GLfloat)y{
    if (isMoved) {
        _oldMatria4=[self touchMoveAtX:x AtY:y];
        isMoved=NO;
    }
}
-(GLKVector3)touchPointVector3FromVector2:(GLKVector2)vector2{
    GLfloat x,y,z;
   
    x=vector2.x;
    y=-vector2.y;
   GLfloat safeRadius=_ball.radius-1;
    if(safeRadius<GLKVector2Length(vector2)){
        float theta = atan2f(y, x);
        x = safeRadius * cosf(theta);
        y = safeRadius * sinf(theta);
    }
    z=sqrtf(square(_ball.radius)-square(x)-square(y));
    GLKVector3 v=GLKVector3Make(x,y,z);
    return GLKVector3MultiplyScalar( GLKVector3Normalize(v), _ball.radius) ;
}
@end
