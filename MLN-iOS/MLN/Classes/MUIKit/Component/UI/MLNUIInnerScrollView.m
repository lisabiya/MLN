//
//  MLNUIInnerScrollView.m
//  MLNUI
//
//  Created by MoMo on 2019/11/1.
//

#import "MLNUIInnerScrollView.h"
#import "MLNUIScrollViewDelegate.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"
#import "MLNUILuaCore.h"
#import "UIView+MLNUILayout.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIHStack.h"
#import "MLNUIVStack.h"

@interface MLNUIInnerScrollViewContentStackNode : MLNUILayoutNode

@end

@interface MLNUIInnerScrollViewContentStack : MLNUIPlaneStack

@property (nonatomic, strong) MLNUIScrollViewNodeRequestLayoutHandler requestLayout;

@end

@implementation MLNUIInnerScrollViewContentStack

- (instancetype)initWithDirection:(BOOL)horizontal requetLayoutHandler:(nonnull MLNUIScrollViewNodeRequestLayoutHandler)handler {
    if (self = [super init]) {
        self.mlnui_layoutNode.flexDirection = horizontal ? MLNUIFlexDirectionRow : MLNUIFlexDirectionColumn;
        self.clipsToBounds = YES;
        _requestLayout = handler;
    }
    return self;
}

#pragma mark - Override

- (BOOL)mlnui_isRootView {
    return YES;
}

- (BOOL)mlnui_allowVirtualLayout {
    return NO;
}

- (Class)mlnui_bindedLayoutNodeClass {
    return [MLNUIInnerScrollViewContentStackNode class];
}

- (void)setCrossAxisSize:(CGSize)size {
    MLNUILayoutNode *node = [self mlnui_layoutNode];
    switch (node.flexDirection) {
        case MLNUIFlexDirectionRow:
        case MLNUIFlexDirectionRowReverse:
            node.height = MLNUIPointValue(size.height);
            break;
        case MLNUIFlexDirectionColumn:
        case MLNUIFlexDirectionColumnReverse:
            node.width = MLNUIPointValue(size.width);
            break;
        default:
            break;
    }
}

- (void)setCrossAxisMaxSize:(CGSize)maxSize {
    MLNUILayoutNode *node = [self mlnui_layoutNode];
    switch (node.flexDirection) {
        case MLNUIFlexDirectionRow:
        case MLNUIFlexDirectionRowReverse:
            node.maxHeight = MLNUIPointValue(maxSize.height);
            break;
        case MLNUIFlexDirectionColumn:
        case MLNUIFlexDirectionColumnReverse:
            node.maxWidth = MLNUIPointValue(maxSize.width);
            break;
        default:
            break;
    }
}

@end

@implementation MLNUIInnerScrollViewContentStackNode

- (CGSize)applyLayout {
    MLNUIInnerScrollViewContentStack *stack = (MLNUIInnerScrollViewContentStack *)self.view;
    return stack.requestLayout();
}

@end


@interface MLNUIInnerScrollView()

@property (nonatomic, weak) MLNUILuaCore *mlnui_luaCore;
@property (nonatomic, strong) MLNUIScrollViewDelegate *luaui_delegate;

@end

@implementation MLNUIInnerScrollView

#pragma mark - Override

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore direction:(BOOL)horizontal requetLayoutHandler:(nonnull MLNUIScrollViewNodeRequestLayoutHandler)handler {
    if (self = [self initWithMLNUILuaCore:luaCore isHorizontal:horizontal]) {
        self.luaui_delegate = [[MLNUIScrollViewDelegate alloc] init];
        self.delegate = self.luaui_delegate;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self createStackContentViewIfNeed:horizontal requetLayoutHandler:handler];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && self.mlnui_contentView) {
        [self luaui_addSubview:self.mlnui_contentView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentSize = self.mlnui_contentView.frame.size;
}

#pragma mark - Private

- (void)createStackContentViewIfNeed:(BOOL)horizontal requetLayoutHandler:(nonnull MLNUIScrollViewNodeRequestLayoutHandler)handler {
    if (self.mlnui_contentView) {
        return;
    }
    MLNUIInnerScrollViewContentStack *stack = [[MLNUIInnerScrollViewContentStack alloc] initWithDirection:horizontal requetLayoutHandler:handler];
    self.mlnui_contentView = stack;
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) addRootnode:stack.mlnui_layoutNode];
}

#pragma mark - Override

- (BOOL)luaui_isContainer {
    return YES;
}

@end
