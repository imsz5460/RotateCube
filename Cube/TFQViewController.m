//
//  TFQViewController.m
//  
//
//  Created by shizhi on 21-9-20.
//

#import "TFQViewController.h"
#import "TFQTrackBall.h"
#import "ColorfulCube.h"


@interface TFQViewController ()<GLKViewControllerDelegate,GLKViewDelegate>
{
    GLKMatrix4 _rotateMatrix4;
    NSInteger _tapCount;
}

@property (strong,nonatomic)EAGLContext *context;
@property (strong,nonatomic)GLKBaseEffect *effect;
@property (strong,nonatomic)TFQTrackBall *trackBall;
@property (strong,nonatomic)ColorfulCube *cube;

@end

@implementation TFQViewController


- (void)glkViewControllerUpdate:(GLKViewController *)controller {

    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.5, 0.5, 0.5, 0.5);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.cube draw];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];

    GLKView *view = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds] context:context];
    view.delegate = self;
    self.view = view;

    ColorfulCube *cube = [[ColorfulCube alloc] init];
    self.cube = cube;
    
    _rotateMatrix4 = GLKMatrix4Identity;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
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

#pragma mark -
#pragma mark 绘图刷新
-(void)update{
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width/size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, 0.5, 15);
    GLKMatrix4 modelviewMatricx = GLKMatrix4Translate(GLKMatrix4Identity, 0,0, -3);
    
    modelviewMatricx = GLKMatrix4Multiply(modelviewMatricx,_rotateMatrix4);
    self.cube.effect.transform.modelviewMatrix = modelviewMatricx;
    self.cube.effect.transform.projectionMatrix = projectionMatrix;
    
}


#pragma mark -
#pragma mark getter方法初始化数据

-(TFQTrackBall *)trackBall{
    if (!_trackBall) {
        self.trackBall = [[TFQTrackBall alloc] init];
    }
    return _trackBall;
}

@end
