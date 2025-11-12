//
//  MainWindowController.h
//  GTools
//
//  Created by YYHMac on 2025/11/12.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainWindowController : NSWindowController

+ (instancetype)sharedController;
- (void)showWindow;

@end

NS_ASSUME_NONNULL_END
