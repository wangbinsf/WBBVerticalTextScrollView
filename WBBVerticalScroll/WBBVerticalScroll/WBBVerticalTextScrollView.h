//
//  WBBVerticalScrollView.h
//  WBBVerticalScroll
//
//  Created by 王宾宾 on 16/8/12.
//  Copyright © 2016年 王宾宾. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WBBVerticalTextScrollView;

@protocol WBBVerticalTextScrollViewDelegate <NSObject>

- (void)verticalTextScrollView:(WBBVerticalTextScrollView *)scr didSelectIndex:(NSInteger)index;

@end

@interface WBBVerticalTextScrollView : UIView
/**
 *  显示内容数组-只能是NSString类型
 */
@property (nonatomic, strong) NSArray *items;
/**
 *  显示内容字号
 */
@property (nonatomic, assign) UIFont *textFont;
/**
 *  显示内容颜色
 */
@property (nonatomic, assign) UIColor *textColor;
/**
 *  显示内容对齐方式
 */
@property (nonatomic, assign) NSTextAlignment textAlign;
/**
 *  用户能不能收到滑动
 */
@property (nonatomic, assign) BOOL userInteraction;
/**
 *  用于点击交互
 */
@property (nonatomic, assign) id<WBBVerticalTextScrollViewDelegate> delegate;
@end
