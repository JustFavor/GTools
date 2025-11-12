//
//  StatusPopupWindow.m
//  GTools
//
//  Created by YYHMac on 2025/11/12.
//

#import "StatusPopupWindow.h"
#import <WebKit/WebKit.h>

typedef NS_ENUM(NSInteger, DeviceType) {
    DeviceTypeMacOS,
    DeviceTypeiPad,
    DeviceTypeiPhone
};

@interface StatusPopupWindow ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSVisualEffectView *navigationBar;
@property (nonatomic, strong) NSButton *backButton;
@property (nonatomic, strong) NSButton *forwardButton;
@property (nonatomic, strong) NSButton *homeButton;
@property (nonatomic, strong) NSTextField *urlTextField;
@property (nonatomic, strong) NSButton *goButton;
@property (nonatomic, strong) NSPopUpButton *deviceSelector;
@property (nonatomic, assign) DeviceType currentDeviceType;

@end

@implementation StatusPopupWindow

- (instancetype)init {
    self.currentDeviceType = DeviceTypeMacOS;
    NSRect frame = [self frameForDeviceType:self.currentDeviceType];

    self = [super initWithContentRect:frame
                            styleMask:NSWindowStyleMaskBorderless
                              backing:NSBackingStoreBuffered
                                defer:NO];

    if (self) {
        [self setupWindow];
        [self setupWebView];
        [self setupNavigationBar];
    }

    return self;
}

- (NSRect)frameForDeviceType:(DeviceType)deviceType {
    CGFloat width, height;

    switch (deviceType) {
        case DeviceTypeiPhone:
            width = 375;
            height = 667 + 50; // +50 for navigation bar
            break;
        case DeviceTypeiPad:
            width = 768;
            height = 1024 + 50;
            break;
        case DeviceTypeMacOS:
        default:
            width = 1024;
            height = 768 + 50;
            break;
    }

    return NSMakeRect(0, 0, width, height);
}

- (void)setupWindow {
    self.backgroundColor = [NSColor clearColor];
    self.opaque = NO;
    self.hasShadow = YES;
    self.level = NSFloatingWindowLevel;
    self.movable = NO;

    // 设置窗口圆角
    self.contentView.wantsLayer = YES;
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.backgroundColor = [[NSColor colorWithWhite:0.2 alpha:0.95] CGColor];
}

- (void)setupWebView {
    // 创建WebView配置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    // 创建WebView
    self.webView = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:config];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.wantsLayer = YES;
    self.webView.layer.cornerRadius = 8;
    self.webView.layer.masksToBounds = YES;

    // 设置User Agent
    self.webView.customUserAgent = [self userAgentForDeviceType:self.currentDeviceType];

    // 加载内置HTML首页
    [self loadHomePage];
    [self.contentView addSubview:self.webView];
}

- (void)loadHomePage {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"home" ofType:@"html"];
    if (htmlPath) {
        NSURL *htmlURL = [NSURL fileURLWithPath:htmlPath];
        [self.webView loadFileURL:htmlURL allowingReadAccessToURL:htmlURL.URLByDeletingLastPathComponent];
    } else {
        // 如果找不到HTML文件，加载默认网页
        NSURL *url = [NSURL URLWithString:@"https://www.bilibili.com"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (NSString *)userAgentForDeviceType:(DeviceType)deviceType {
    NSString *userAgent;

    switch (deviceType) {
        case DeviceTypeiPhone:
            userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1";
            break;
        case DeviceTypeiPad:
            userAgent = @"Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1";
            break;
        case DeviceTypeMacOS:
        default:
            userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15";
            break;
    }

    return userAgent;
}

- (void)setupNavigationBar {
    // 创建导航栏容器 - 使用模糊效果
    self.navigationBar = [[NSVisualEffectView alloc] initWithFrame:NSZeroRect];
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.navigationBar.material = NSVisualEffectMaterialHUDWindow;
    self.navigationBar.blendingMode = NSVisualEffectBlendingModeWithinWindow;
    self.navigationBar.state = NSVisualEffectStateActive;
    self.navigationBar.wantsLayer = YES;

    [self.contentView addSubview:self.navigationBar];

    // 创建设备选择器
    self.deviceSelector = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    self.deviceSelector.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deviceSelector addItemWithTitle:@"macOS"];
    [self.deviceSelector addItemWithTitle:@"iPad"];
    [self.deviceSelector addItemWithTitle:@"iPhone"];
    self.deviceSelector.target = self;
    self.deviceSelector.action = @selector(deviceTypeChanged:);
    [self.navigationBar addSubview:self.deviceSelector];

    // 创建后退按钮
    self.backButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameGoLeftTemplate]
                                         target:self
                                         action:@selector(goBack:)];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.backButton.bordered = NO;
    self.backButton.bezelStyle = NSBezelStyleTexturedSquare;
    [self.navigationBar addSubview:self.backButton];

    // 创建前进按钮
    self.forwardButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameGoRightTemplate]
                                            target:self
                                            action:@selector(goForward:)];
    self.forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.forwardButton.bordered = NO;
    self.forwardButton.bezelStyle = NSBezelStyleTexturedSquare;
    [self.navigationBar addSubview:self.forwardButton];

    // 创建主页按钮
    self.homeButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameHomeTemplate]
                                         target:self
                                         action:@selector(goHome:)];
    self.homeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.homeButton.bordered = NO;
    self.homeButton.bezelStyle = NSBezelStyleTexturedSquare;
    [self.navigationBar addSubview:self.homeButton];

    // 创建URL文本框
    self.urlTextField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    self.urlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.urlTextField.placeholderString = @"输入URL...";
    self.urlTextField.target = self;
    self.urlTextField.action = @selector(loadURL:);
    self.urlTextField.backgroundColor = [NSColor colorWithWhite:0.3 alpha:0.8];
    self.urlTextField.textColor = [NSColor whiteColor];
    self.urlTextField.bezelStyle = NSTextFieldRoundedBezel;
    [self.navigationBar addSubview:self.urlTextField];

    // 创建Go按钮
    self.goButton = [NSButton buttonWithTitle:@"Go" target:self action:@selector(loadURL:)];
    self.goButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.goButton.bezelStyle = NSBezelStyleRounded;
    [self.navigationBar addSubview:self.goButton];

    // 设置约束
    [self setupConstraints];
}

- (void)setupConstraints {
    NSDictionary *views = @{
        @"navigationBar": self.navigationBar,
        @"webView": self.webView,
        @"deviceSelector": self.deviceSelector,
        @"backButton": self.backButton,
        @"forwardButton": self.forwardButton,
        @"homeButton": self.homeButton,
        @"urlTextField": self.urlTextField,
        @"goButton": self.goButton
    };

    // 导航栏约束 - 移到底部
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navigationBar]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView][navigationBar(50)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];

    // WebView约束
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];

    // 导航栏内部按钮约束
    [self.navigationBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[deviceSelector(100)]-10-[backButton(30)]-5-[forwardButton(30)]-5-[homeButton(30)]-10-[urlTextField]-10-[goButton(50)]-10-|"
                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                               metrics:nil
                                                                                 views:views]];

    [self.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:self.deviceSelector
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.navigationBar
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0]];
}

#pragma mark - Actions

- (void)deviceTypeChanged:(NSPopUpButton *)sender {
    NSInteger selectedIndex = sender.indexOfSelectedItem;

    switch (selectedIndex) {
        case 0:
            self.currentDeviceType = DeviceTypeMacOS;
            break;
        case 1:
            self.currentDeviceType = DeviceTypeiPad;
            break;
        case 2:
            self.currentDeviceType = DeviceTypeiPhone;
            break;
        default:
            break;
    }

    // 更新User Agent
    self.webView.customUserAgent = [self userAgentForDeviceType:self.currentDeviceType];

    // 重新设置窗口大小
    NSRect newFrame = [self frameForDeviceType:self.currentDeviceType];
    NSRect currentFrame = self.frame;
    NSScreen *screen = self.screen ?: [NSScreen mainScreen];
    NSRect screenFrame = screen.visibleFrame;

    // 保持窗口中心位置
    CGFloat centerX = NSMidX(currentFrame);
    CGFloat centerY = NSMidY(currentFrame);

    newFrame.origin.x = centerX - newFrame.size.width / 2;
    newFrame.origin.y = centerY - newFrame.size.height / 2;

    // 确保窗口不超出屏幕边界
    if (NSMaxX(newFrame) > NSMaxX(screenFrame)) {
        newFrame.origin.x = NSMaxX(screenFrame) - newFrame.size.width;
    }
    if (newFrame.origin.x < screenFrame.origin.x) {
        newFrame.origin.x = screenFrame.origin.x;
    }
    if (NSMaxY(newFrame) > NSMaxY(screenFrame)) {
        newFrame.origin.y = NSMaxY(screenFrame) - newFrame.size.height;
    }
    if (newFrame.origin.y < screenFrame.origin.y) {
        newFrame.origin.y = screenFrame.origin.y;
    }

    [self setFrame:newFrame display:YES animate:YES];

    // 重新加载当前页面以应用新的User Agent
    [self.webView reload];
}

- (void)goBack:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goForward:(id)sender {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)goHome:(id)sender {
    [self loadHomePage];
}

- (void)loadURL:(id)sender {
    NSString *urlString = self.urlTextField.stringValue;

    if (urlString.length == 0) {
        return;
    }

    // 如果不包含协议，添加https://
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end
