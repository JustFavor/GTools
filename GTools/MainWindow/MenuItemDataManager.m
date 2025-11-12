//
//  MenuItemDataManager.m
//  GTools
//
//  Created by YYHMac on 2025/11/12.
//

#import "MenuItemDataManager.h"

@implementation MenuItemDataManager

+ (instancetype)sharedManager {
    static MenuItemDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MenuItemDataManager alloc] init];
    });
    return manager;
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDir = [paths firstObject];
    NSString *appDir = [appSupportDir stringByAppendingPathComponent:@"GTools"];

    // 确保目录存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:appDir]) {
        [fileManager createDirectoryAtPath:appDir withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return [appDir stringByAppendingPathComponent:@"menuItems.plist"];
}

- (NSArray<NSDictionary *> *)loadMenuItems {
    NSString *filePath = [self dataFilePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *items = [NSArray arrayWithContentsOfFile:filePath];
        return items ?: @[];
    }

    // 返回默认菜单项示例
    return @[
        @{@"title": @"打开终端", @"action": @"open:/Applications/Utilities/Terminal.app"},
        @{@"title": @"打开访达", @"action": @"open:/System/Library/CoreServices/Finder.app"},
        @{@"title": @"查看系统信息", @"action": @"cmd:system_profiler SPSoftwareDataType"},
        @{@"title": @"打开Safari", @"action": @"as:tell application \"Safari\" to activate"},
        @{@"title": @"清理DNS缓存(需要密码)", @"action": @"sudo:cmd:dscacheutil -flushcache; killall -HUP mDNSResponder"}
    ];
}

- (void)saveMenuItems:(NSArray<NSDictionary *> *)menuItems {
    NSString *filePath = [self dataFilePath];
    [menuItems writeToFile:filePath atomically:YES];
}

@end
