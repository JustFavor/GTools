//
//  StatusItemManager.h
//  GTools
//
//  Created by YYHMac on 2025/11/12.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatusItemManager : NSObject

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;

+ (instancetype)sharedManager;

- (void)setupStatusItem;
- (void)updateMenuItems:(NSArray<NSDictionary *> *)menuItems;

@end

NS_ASSUME_NONNULL_END
