//
//  MenuItemDataManager.h
//  GTools
//
//  Created by YYHMac on 2025/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuItemDataManager : NSObject

+ (instancetype)sharedManager;

- (NSArray<NSDictionary *> *)loadMenuItems;
- (void)saveMenuItems:(NSArray<NSDictionary *> *)menuItems;

@end

NS_ASSUME_NONNULL_END
