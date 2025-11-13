//
//  StatusItemManager.m
//  GTools
//
//  Created by YYHMac on 2025/11/12.
//

#import "StatusItemManager.h"
#import "StatusPopupWindow.h"

@interface StatusItemManager ()

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) StatusPopupWindow *popupWindow;
@property (nonatomic, strong) NSMenu *rightClickMenu;
@property (nonatomic, strong) NSArray<NSDictionary *> *menuItemsData;

@end

@implementation StatusItemManager

+ (instancetype)sharedManager {
    static StatusItemManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[StatusItemManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _menuItemsData = @[];
    }
    return self;
}

- (void)setupStatusItem {
    // 创建状态栏图标
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

    // 设置图标
    NSImage *icon = [NSImage imageNamed:NSImageNameFolder];
    icon.size = NSMakeSize(18, 18);
    self.statusItem.button.image = icon;

    // 设置按钮行为
    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(statusItemClicked:);

    // 允许右键点击
    [self.statusItem.button sendActionOn:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown];

    // 初始化右键菜单
    [self setupRightClickMenu];
}

- (void)statusItemClicked:(NSButton *)sender {
    NSEvent *currentEvent = [NSApp currentEvent];

    if (currentEvent.type == NSEventTypeRightMouseDown) {
        // 右键点击 - 显示菜单
        [self.statusItem popUpStatusItemMenu:self.rightClickMenu];
    } else {
        // 左键点击 - 显示自定义窗口
        [self togglePopupWindow];
    }
}

- (void)togglePopupWindow {
    if (self.popupWindow && self.popupWindow.isVisible) {
        [self closePopupWindow];
    } else {
        [self showPopupWindow];
    }
}

- (void)showPopupWindow {
    if (!self.popupWindow) {
        self.popupWindow = [[StatusPopupWindow alloc] init];
        // 监听窗口失去焦点事件
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(popupWindowDidResignKey:)
                                                     name:NSWindowDidResignKeyNotification
                                                   object:self.popupWindow];
    }

    // 计算窗口位置
    NSRect buttonFrame = self.statusItem.button.window.frame;
    NSRect windowFrame = self.popupWindow.frame;

    CGFloat x = buttonFrame.origin.x + (buttonFrame.size.width - windowFrame.size.width) / 2;
    CGFloat y = buttonFrame.origin.y - windowFrame.size.height - 5;

    [self.popupWindow setFrameOrigin:NSMakePoint(x, y)];
    [self.popupWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)closePopupWindow {
    [self.popupWindow orderOut:nil];
}

- (void)popupWindowDidResignKey:(NSNotification *)notification {
    [self closePopupWindow];
}

- (void)setupRightClickMenu {
    self.rightClickMenu = [[NSMenu alloc] init];
    [self updateMenuItems:self.menuItemsData];
}

- (void)updateMenuItems:(NSArray<NSDictionary *> *)menuItems {
    self.menuItemsData = menuItems;

    // 清空现有菜单项
    [self.rightClickMenu removeAllItems];

    // 添加自定义菜单项
    for (NSDictionary *itemData in menuItems) {
        NSString *title = itemData[@"title"];
        NSString *action = itemData[@"action"];

        if (title && action) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                          action:@selector(customMenuItemClicked:)
                                                   keyEquivalent:@""];
            item.target = self;
            item.representedObject = action;
            [self.rightClickMenu addItem:item];
        }
    }

    // 添加分隔线
    if (menuItems.count > 0) {
        [self.rightClickMenu addItem:[NSMenuItem separatorItem]];
    }

    // 添加清除Web缓存菜单项
    NSMenuItem *clearCacheItem = [[NSMenuItem alloc] initWithTitle:@"清除Web缓存"
                                                            action:@selector(clearWebCache:)
                                                     keyEquivalent:@""];
    clearCacheItem.target = self;
    [self.rightClickMenu addItem:clearCacheItem];

    // 添加设置菜单项
    NSMenuItem *settingsItem = [[NSMenuItem alloc] initWithTitle:@"设置"
                                                          action:@selector(openSettings:)
                                                   keyEquivalent:@","];
    settingsItem.target = self;
    [self.rightClickMenu addItem:settingsItem];

    // 添加退出菜单项
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"退出"
                                                      action:@selector(quit:)
                                               keyEquivalent:@"q"];
    quitItem.target = self;
    [self.rightClickMenu addItem:quitItem];
}

- (void)customMenuItemClicked:(NSMenuItem *)sender {
    NSString *action = sender.representedObject;
    NSLog(@"执行自定义操作: %@", action);

    if ([action hasPrefix:@"open:"]) {
        // 打开应用或文件
        NSString *path = [action substringFromIndex:5];
        [self executeOpenAction:path];
    } else if ([action hasPrefix:@"sh:"]) {
        // 执行Shell脚本
        NSString *scriptPath = [action substringFromIndex:3];
        [self executeShellScript:scriptPath useSudo:NO];
    } else if ([action hasPrefix:@"cmd:"]) {
        // 执行Bash命令
        NSString *command = [action substringFromIndex:4];
        [self executeBashCommand:command useSudo:NO];
    } else if ([action hasPrefix:@"as:"]) {
        // 执行AppleScript
        NSString *script = [action substringFromIndex:3];
        [self executeAppleScript:script];
    } else if ([action hasPrefix:@"sudo:cmd:"]) {
        // 使用sudo执行Bash命令
        NSString *command = [action substringFromIndex:9];
        [self executeBashCommand:command useSudo:YES];
    } else if ([action hasPrefix:@"sudo:sh:"]) {
        // 使用sudo执行Shell脚本
        NSString *scriptPath = [action substringFromIndex:8];
        [self executeShellScript:scriptPath useSudo:YES];
    } else if ([action hasPrefix:@"command:"]) {
        // 兼容旧格式
        NSString *command = [action substringFromIndex:8];
        [self executeBashCommand:command useSudo:NO];
    }
}

#pragma mark - Action Execution Methods

- (void)executeOpenAction:(NSString *)path {
    // 支持打开应用、文件或URL
    if ([path hasPrefix:@"http://"] || [path hasPrefix:@"https://"]) {
        // 打开URL
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:path]];
    } else {
        // 打开文件或应用
        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path]];
    }
}

- (void)executeShellScript:(NSString *)scriptPath useSudo:(BOOL)useSudo {
    if (useSudo) {
        // 使用osascript执行带sudo的脚本
        NSString *command = [NSString stringWithFormat:@"do shell script \"sh %@\" with administrator privileges", scriptPath];
        [self executeAppleScript:command];
    } else {
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/bin/sh";
        task.arguments = @[scriptPath];

        @try {
            [task launch];
        } @catch (NSException *exception) {
            NSLog(@"执行Shell脚本失败: %@", exception);
        }
    }
}

- (void)executeBashCommand:(NSString *)command useSudo:(BOOL)useSudo {
    if (useSudo) {
        // 使用osascript执行带sudo的命令
        NSString *escapedCommand = [command stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSString *appleScript = [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", escapedCommand];
        [self executeAppleScript:appleScript];
    } else {
        // 创建临时脚本文件并在Terminal中打开
        NSString *tempDir = NSTemporaryDirectory();
        NSString *scriptPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"gtools_%@.command", [[NSUUID UUID] UUIDString]]];

        // 写入脚本内容
        NSString *scriptContent = [NSString stringWithFormat:@"#!/bin/bash\ncd ~\n%@\necho \"\"\necho \"按任意键关闭...\"\nread -n 1\nexit", command];
        [scriptContent writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

        // 设置可执行权限
        [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions: @0755} ofItemAtPath:scriptPath error:nil];

        // 使用open打开.command文件，Terminal会自动执行
        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:scriptPath]];
    }
}

- (void)executeAppleScript:(NSString *)script {
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
    NSDictionary *errorDict = nil;
    [appleScript executeAndReturnError:&errorDict];

    if (errorDict) {
        NSLog(@"执行AppleScript失败: %@", errorDict);
    }
}

- (void)clearWebCache:(id)sender {
    if (self.popupWindow) {
        [self.popupWindow clearWebCache];
    } else {
        // 如果窗口还没创建，显示提示
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"提示";
        alert.informativeText = @"请先打开Web容器后再清除缓存";
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
    }
}

- (void)openSettings:(id)sender {
    // 发送通知打开设置窗口
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSettingsWindow" object:nil];
}

- (void)quit:(id)sender {
    [NSApp terminate:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
