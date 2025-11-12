//
//  AppDelegate.m
//  GTools
//
//  Created by YYHMac on 2025/11/11.
//

#import "AppDelegate.h"
#import "StatusItemManager.h"
#import "MainWindowController.h"
#import "MenuItemDataManager.h"

///
/// 1.自定义菜单栏图标，支持自定义功能
/// 2.主窗口支持自定义添加功能
/// 3.弹出终端窗口
/// 4.开机自启动
/// 5.加载一个h5的容器用于摸鱼
///

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 隐藏Dock图标，只显示菜单栏图标
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    // 初始化状态栏图标
    [[StatusItemManager sharedManager] setupStatusItem];

    // 加载菜单项数据并更新状态栏菜单
    NSArray *menuItems = [[MenuItemDataManager sharedManager] loadMenuItems];
    [[StatusItemManager sharedManager] updateMenuItems:menuItems];

    // 监听打开设置窗口的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openSettingsWindow:)
                                                 name:@"OpenSettingsWindow"
                                               object:nil];

    // 监听菜单项更新的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuItemsDidUpdate:)
                                                 name:@"MenuItemsDidUpdate"
                                               object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

#pragma mark - Notifications

- (void)openSettingsWindow:(NSNotification *)notification {
    [[MainWindowController sharedController] showWindow];
}

- (void)menuItemsDidUpdate:(NSNotification *)notification {
    NSArray *menuItems = notification.userInfo[@"menuItems"];
    [[StatusItemManager sharedManager] updateMenuItems:menuItems];
}

@end
