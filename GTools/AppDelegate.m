//
//  AppDelegate.m
//  GTools
//
//  Created by YYHMac on 2025/11/11.
//

#import "AppDelegate.h"
///
/// 1.自定义菜单栏图标，支持自定义功能
/// 2.主窗口支持自定义添加功能
/// 3.弹出终端窗口
/// 4.开机自启动
/// 5.加载一个h5的容器用于摸鱼
/// 



@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
