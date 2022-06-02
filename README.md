#OpenGL ES 打造一个一阶魔方

万丈高楼平地起，为了完成一个三阶魔方，本篇文章先达成一个小目标：打造一个一阶魔方。一阶魔方是什么鬼（其实我也想笑，实际上谁会去玩一个一阶的魔方）？对啰，就是一个正方体。把玩魔方时需要观察各个面，所以需要有个旋转魔方的功能，这次我们就做一个可以通过**滑动手势全方位旋转的一阶魔方**。
![效果动图.gif](https://upload-images.jianshu.io/upload_images/4320229-ed5658a1a0f9b8ce.gif?imageMogr2/auto-orient/strip)
###静态的正方体
我们使用GLKit绘制一个正方体，GLKit是对OpenGL ES 的封装，内部帮我们做了很多事情，可以简化编程。我们知道，正方体有6个面，8个顶点。
定义数组：
```swift
static GLKVector3 vertices[8];
static GLKVector4 colors[6];
static GLKVector3 triangleVertices[36];
static GLKVector4 triangleColors[36];
```
初始化数据：
```swift
vertices[0] = GLKVector3Make(-0.5, -0.5,  0.5); // Left  bottom front
vertices[1] = GLKVector3Make( 0.5, -0.5,  0.5); // Right bottom front
vertices[2] = GLKVector3Make( 0.5,  0.5,  0.5); // Right top    front
vertices[3] = GLKVector3Make(-0.5,  0.5,  0.5); // Left  top    front
vertices[4] = GLKVector3Make(-0.5, -0.5, -0.5); // Left  bottom back
vertices[5] = GLKVector3Make( 0.5, -0.5, -0.5); // Right bottom back
vertices[6] = GLKVector3Make( 0.5,  0.5, -0.5); // Right top    back
vertices[7] = GLKVector3Make(-0.5,  0.5, -0.5); // Left  top    back

colors[0] = GLKVector4Make(0.000, 0.586, 1.000, 1.000); //  湖蓝
colors[1] = GLKVector4Make(1.0, 0.0, 0.0, 1.0); // 红
colors[2] = GLKVector4Make(0.119, 0.519, 0.142, 1.000); //  暗绿
colors[3] = GLKVector4Make(1.000, 0.652, 0.000, 1.000); // 橙
colors[4] = GLKVector4Make(1.000, 1.000, 0.000, 1.000); // 黄
colors[5] = GLKVector4Make(1.0, 1.0, 1.0, 1.0); // 白

//每个面需要6个点描述（2个三角形拼合而成），显然有些点是共用的，采用顶点索引，对应8个顶点
int vertexIndices[36] = {
  // Front
  0, 1, 2,
  0, 2, 3,
  // Right
  1, 5, 6,
  1, 6, 2,
  // Back
  5, 4, 7,
  5, 7, 6,
  // Left
  4, 0, 3,
  4, 3, 7,
  // Top
  3, 2, 6,
  3, 6, 7,
  // Bottom
  4, 5, 1,
  4, 1, 0,
};

for (int i = 0; i < 36; i++) {
    triangleVertices[i] = vertices[vertexIndices[i]];
    triangleColors[i] = colors[i/6];
}
```
屏幕绘制
```swift
-(void)update{
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width/size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, 0.5, 15);
    GLKMatrix4 modelviewMatricx = GLKMatrix4Translate(GLKMatrix4Identity, 0,0, -3);
    
    modelviewMatricx = GLKMatrix4Multiply(modelviewMatricx,_rotateMatrix4);
    self.cube.effect.transform.modelviewMatrix = modelviewMatricx;
    self.cube.effect.transform.projectionMatrix = projectionMatrix;
}

- (void)draw {
  [effect prepareToDraw];
  
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, triangleVertices);
  
  glEnableVertexAttribArray(GLKVertexAttribColor);
  glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, triangleColors);
  
  glDrawArrays(GL_TRIANGLES, 0, 36);
  
  glDisableVertexAttribArray(GLKVertexAttribPosition);
  glDisableVertexAttribArray(GLKVertexAttribColor);
}
```
###手势操作旋转立方体
>功能描述：
通过触摸手势操作，实现全方位旋转。
思路：
构建一个三维球空间，通过屏幕的二维触摸轨迹模拟三维的球平面的滑动轨迹。

数学建模，如下图所示：

![旋转球空间模型.png](https://upload-images.jianshu.io/upload_images/4320229-dd285aa4a141f6ca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
假设屏幕触摸点为B，我们将其对应为球面上的点A，OB为OA在xy平面上的投影。不难看出二维与三维的映射关系。
令A点坐标为（a,b,c），B点坐标(a,b)，OA长度为R， 则有a^2 + b^2 + c^2 = R^2。
根据时间片内手指滑动的方向求出球旋转的轴向量。

二维OB向量转为三维OA向量的算法：
```swift
 _ball.radius=170;
 _ball.origin=GLKVector3Make(0, 0, 0);
```
```swift
//二维OB向量转为三维OA向量的算法
-(GLKVector3)touchPointVector3FromVector2: (GLKVector2)vector2 {
    GLfloat x,y,z;
    x=vector2.x;
    y=-vector2.y;
   GLfloat safeRadius = _ball.radius-1;
// 超出圆形区域的处理
    if(safeRadius < GLKVector2Length(vector2)) {
        float theta = atan2f(y, x);
        x = safeRadius * cosf(theta);
        y = safeRadius * sinf(theta);
    }
    z = sqrtf(square(_ball.radius) - square(x) - square(y));
    GLKVector3 v=GLKVector3Make(x,y,z);
    return GLKVector3MultiplyScalar( GLKVector3Normalize(v),  _ball.radius) ;
}
```
>函数说明：GLKVector3MultiplyScalar
返回通过将向量的每个分量乘以标量值创建的新向量。

手指滑动过程中的旋转矩阵：
```swift
_oldMatria4=GLKMatrix4Identity;
-(GLKMatrix4)touchMoveAtX:(GLfloat)x AtY:(GLfloat)y{
    isMoved=YES;
    GLKVector3 movePoint= [self touchPointVector3FromVector2:GLKVector2Make(x-screenW*0.5, y-screenH*0.5)];
    
    return GLKMatrix4Multiply(GLKMatrix4RotateWithVector3(GLKMatrix4Identity,
                                       acosf(GLKVector3DotProduct(movePoint,_touchPoint)/(GLKVector3Length(movePoint)*GLKVector3Length(_touchPoint))),
                                        GLKVector3CrossProduct( _touchPoint,movePoint))
                              ,_oldMatria4);
}
```
>函数说明：
GLKVector3DotProduct
返回两个向量的点积。
GLKVector3CrossProduct
返回两个向量的交叉乘积。
GLKMatrix4 GLKMatrix4RotateWithVector3(GLKMatrix4 matrix, float radians, GLKVector3 axisVector)
矩阵matrix绕axisVector向量旋转radians，返回新矩阵。 
```
#pragma mark 触屏处理
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    _tapCount=[touch tapCount];
    if (_tapCount == 2) {

    }else if (_tapCount == 1){
    [self.trackBall touchDownAtX:touchPoint.x AtY:touchPoint.y];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
 if (_tapCount == 1){
     [self.trackBall touchUpAtX:point.x AtY:point.y];
     self.cube.effect.transform.modelviewMatrix = _rotateMatrix4;
 }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (_tapCount == 2) {

    }else if (_tapCount == 1){
    _rotateMatrix4 = [self.trackBall touchMoveAtX:point.x AtY:point.y];
    self.cube.effect.transform.modelviewMatrix = _rotateMatrix4;
    }
}
```
本文demo源码 [传送门](https://github.com/imsz5460/RotateCube)

###参考
>[GLKVector3参考](https://blog.csdn.net/weixin_33759269/article/details/92970485)
[进入 3D 世界，从正方体开始](https://www.jianshu.com/p/dc4d34b1c979)
