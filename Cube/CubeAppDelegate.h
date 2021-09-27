//
//  CubeAppDelegate.h
//  Cube
//
//  Created by shizhi on 21-9-20.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface CubeAppDelegate : UIResponder <UIApplicationDelegate> {
  NSMutableArray *cubes;
}

@property (strong, nonatomic) UIWindow *window;

@end
