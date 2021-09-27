//
//  ColorfulCube.m
//  Cube
//
//  Created by shizhi on 21-9-20.
//

#import "ColorfulCube.h"


static BOOL initialized = NO;
static GLKVector3 vertices[8];
static GLKVector4 colors[8];
static GLKVector3 triangleVertices[36];
static GLKVector4 triangleColors[36];

@implementation ColorfulCube


static bool flag;

- (id)init
{
  self = [super init];
  if (self) {
     self.effect = [[GLKBaseEffect alloc] init];
  }
  
  return self;
}

+ (void)initialize {
  if (!initialized) {
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
    
    initialized = YES;
  }
}

- (void)draw {
    
    [self.effect prepareToDraw];
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

@end
