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

    return [appDir stringByAppendingPathComponent:@"menuItems.json"];
}

- (NSString *)defaultJSONPath {
    return [[NSBundle mainBundle] pathForResource:@"defaultMenuItems" ofType:@"json"];
}

- (NSArray<NSDictionary *> *)loadDefaultMenuItems {
    NSString *defaultPath = [self defaultJSONPath];
    if (!defaultPath) {
        return @[];
    }

    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    if (!data) {
        return @[];
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || !json[@"menuItems"]) {
        return @[];
    }

    return json[@"menuItems"];
}

- (NSArray<NSDictionary *> *)loadMenuItems {
    NSString *filePath = [self dataFilePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            NSError *error = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error && json[@"menuItems"]) {
                return json[@"menuItems"];
            }
        }
    }

    // 如果没有用户配置，返回默认配置
    NSArray *defaultItems = [self loadDefaultMenuItems];
    if (defaultItems.count > 0) {
        return defaultItems;
    }

    // 兜底：硬编码的默认配置
    return @[
        @{@"title": @"打开终端", @"action": @"open:/Applications/Utilities/Terminal.app"},
        @{@"title": @"打开访达", @"action": @"open:/System/Library/CoreServices/Finder.app"}
    ];
}

- (void)saveMenuItems:(NSArray<NSDictionary *> *)menuItems {
    NSString *filePath = [self dataFilePath];

    NSDictionary *json = @{@"menuItems": menuItems};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];

    if (!error && data) {
        [data writeToFile:filePath atomically:YES];
    } else {
        NSLog(@"保存菜单项失败: %@", error);
    }
}

- (void)resetToDefault {
    NSString *filePath = [self dataFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];

    // 发送通知，让UI重新加载
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemsDidReset" object:nil];
}

@end
