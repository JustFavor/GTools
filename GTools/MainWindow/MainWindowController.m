//
//  MainWindowController.m
//  GTools
//
//  Created by YYHMac on 2025/11/12.
//

#import "MainWindowController.h"
#import "MenuItemDataManager.h"

@interface MainWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) NSWindow *mainWindow;
@property (nonatomic, strong) NSVisualEffectView *visualEffectView;
@property (nonatomic, strong) NSTableView *tableView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSButton *addButton;
@property (nonatomic, strong) NSButton *deleteButton;
@property (nonatomic, strong) NSTextField *helpLabel;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *menuItems;

@end

@implementation MainWindowController

+ (instancetype)sharedController {
    static MainWindowController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[MainWindowController alloc] init];
    });
    return controller;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupWindow];
        [self loadMenuItems];
    }
    return self;
}

- (void)setupWindow {
    NSRect frame = NSMakeRect(0, 0, 800, 500);

    self.mainWindow = [[NSWindow alloc] initWithContentRect:frame
                                                  styleMask:NSWindowStyleMaskTitled |
                                                            NSWindowStyleMaskClosable |
                                                            NSWindowStyleMaskMiniaturizable |
                                                            NSWindowStyleMaskResizable
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];

    self.mainWindow.title = @"菜单项管理";
    self.mainWindow.minSize = NSMakeSize(700, 400);
    [self.mainWindow center];

    // 设置为主窗口
    self.window = self.mainWindow;

    // 设置窗口背景为透明
    self.mainWindow.backgroundColor = [NSColor clearColor];
    self.mainWindow.opaque = NO;

    // 创建模糊玻璃效果视图
    self.visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.mainWindow.contentView.bounds];
    self.visualEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.visualEffectView.material = NSVisualEffectMaterialUnderWindowBackground;
    self.visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    self.visualEffectView.state = NSVisualEffectStateActive;

    [self.mainWindow.contentView addSubview:self.visualEffectView];

    // 设置帮助标签
    [self setupHelpLabel];

    // 设置TableView
    [self setupTableView];

    // 设置按钮
    [self setupButtons];
}

- (void)setupHelpLabel {
    self.helpLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 430, 760, 50)];
    self.helpLabel.stringValue = @"操作格式说明:\nopen:/path/to/app - 打开应用 | sh:/path/to/script.sh - Shell脚本 | cmd:command - Bash命令 | as:applescript - AppleScript | sudo:cmd:command - Sudo执行";
    self.helpLabel.editable = NO;
    self.helpLabel.bordered = NO;
    self.helpLabel.backgroundColor = [NSColor clearColor];
    self.helpLabel.textColor = [NSColor whiteColor];
    self.helpLabel.font = [NSFont systemFontOfSize:11];
    self.helpLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.helpLabel.maximumNumberOfLines = 2;
    self.helpLabel.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [self.visualEffectView addSubview:self.helpLabel];
}

- (void)setupTableView {
    // 创建ScrollView
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 80, 760, 340)];
    self.scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.hasHorizontalScroller = NO;
    self.scrollView.borderType = NSBezelBorder;

    // 创建TableView
    self.tableView = [[NSTableView alloc] initWithFrame:self.scrollView.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 30;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask;

    // 添加列
    NSTableColumn *titleColumn = [[NSTableColumn alloc] initWithIdentifier:@"title"];
    titleColumn.title = @"标题";
    titleColumn.width = 200;
    titleColumn.editable = YES;
    [self.tableView addTableColumn:titleColumn];

    NSTableColumn *actionColumn = [[NSTableColumn alloc] initWithIdentifier:@"action"];
    actionColumn.title = @"操作";
    actionColumn.width = 540;
    actionColumn.editable = YES;
    [self.tableView addTableColumn:actionColumn];

    self.scrollView.documentView = self.tableView;
    [self.visualEffectView addSubview:self.scrollView];
}

- (void)setupButtons {
    // 添加按钮
    self.addButton = [[NSButton alloc] initWithFrame:NSMakeRect(20, 30, 100, 35)];
    self.addButton.title = @"添加";
    self.addButton.bezelStyle = NSBezelStyleRounded;
    self.addButton.target = self;
    self.addButton.action = @selector(addMenuItem:);
    [self.visualEffectView addSubview:self.addButton];

    // 删除按钮
    self.deleteButton = [[NSButton alloc] initWithFrame:NSMakeRect(130, 30, 100, 35)];
    self.deleteButton.title = @"删除";
    self.deleteButton.bezelStyle = NSBezelStyleRounded;
    self.deleteButton.target = self;
    self.deleteButton.action = @selector(deleteMenuItem:);
    [self.visualEffectView addSubview:self.deleteButton];
}

- (void)loadMenuItems {
    self.menuItems = [[[MenuItemDataManager sharedManager] loadMenuItems] mutableCopy];
    if (!self.menuItems) {
        self.menuItems = [NSMutableArray array];
    }
}

- (void)saveMenuItems {
    [[MenuItemDataManager sharedManager] saveMenuItems:self.menuItems];

    // 通知StatusItemManager更新菜单
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemsDidUpdate"
                                                        object:nil
                                                      userInfo:@{@"menuItems": self.menuItems}];
}

- (void)showWindow {
    [self.mainWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - Actions

- (void)addMenuItem:(id)sender {
    NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:@{
        @"title": @"新菜单项",
        @"action": @"command:echo 'Hello'"
    }];

    [self.menuItems addObject:newItem];
    [self.tableView reloadData];
    [self saveMenuItems];
}

- (void)deleteMenuItem:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.menuItems.count) {
        [self.menuItems removeObjectAtIndex:selectedRow];
        [self.tableView reloadData];
        [self saveMenuItems];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.menuItems.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.menuItems.count) {
        NSDictionary *item = self.menuItems[row];
        return item[tableColumn.identifier];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.menuItems.count) {
        NSMutableDictionary *item = self.menuItems[row];
        item[tableColumn.identifier] = object;
        [self saveMenuItems];
    }
}

#pragma mark - NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return YES;
}

@end
